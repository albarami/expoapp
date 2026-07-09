import { HttpStatus, Injectable } from '@nestjs/common';
import {
  Notification,
  NotificationRecipient,
  NotificationStatus,
  Prisma,
  UserRole,
} from '@prisma/client';
import { Request } from 'express';
import { AuditActions } from '../audit/audit-actions';
import { AuditService } from '../audit/audit.service';
import { AuthUser } from '../auth/types/auth-user';
import { ErrorCode } from '../common/constants/error-codes';
import { BusinessException } from '../common/exceptions/business.exception';
import { PrismaService } from '../prisma/prisma.service';
import { AudienceResolver } from './audience.resolver';
import { CancelNotificationDto } from './dto/cancel-notification.dto';
import { CreateNotificationDto } from './dto/create-notification.dto';
import { ListNotificationsQueryDto } from './dto/list-notifications-query.dto';
import {
  CancelNotificationResult,
  CreateNotificationResult,
  NotificationDetail,
  NotificationListItem,
  NotificationListResult,
  NotificationStats,
} from './notifications.types';

type RecipientWithNotification = NotificationRecipient & {
  notification: Notification;
};

@Injectable()
export class NotificationsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly audienceResolver: AudienceResolver,
    private readonly auditService: AuditService,
  ) {}

  async createNotification(
    actor: AuthUser,
    dto: CreateNotificationDto,
    request?: Request,
  ): Promise<CreateNotificationResult> {
    this.assertCanManageNotifications(actor);

    const audienceFilter = this.audienceResolver.validateAndNormalizeFilter(
      dto.audienceType,
      dto.audienceFilter,
    );

    const publishNow = dto.publishNow !== false;
    const publishAt = this.resolvePublishAt(publishNow, dto.publishAt);
    const expiresAt = this.resolveExpiresAt(publishAt, dto.expiresAt);
    const status = publishNow
      ? NotificationStatus.PUBLISHED
      : NotificationStatus.SCHEDULED;

    const recipients = publishNow
      ? await this.audienceResolver.resolveAudience({
          audienceType: dto.audienceType,
          audienceFilter,
        })
      : [];

    const deliveredAt = publishNow ? new Date() : null;

    const notification = await this.prisma.$transaction(async (tx) => {
      const created = await tx.notification.create({
        data: {
          titleEn: dto.titleEn.trim(),
          titleAr: dto.titleAr?.trim() || null,
          bodyEn: dto.bodyEn.trim(),
          bodyAr: dto.bodyAr?.trim() || null,
          priority: dto.priority,
          status,
          audienceType: dto.audienceType,
          audienceFilter,
          publishAt,
          expiresAt,
          createdById: actor.id,
        },
      });

      if (recipients.length > 0) {
        await tx.notificationRecipient.createMany({
          data: recipients.map((user) => ({
            notificationId: created.id,
            userId: user.id,
            deliveredAt,
          })),
        });
      }

      return created;
    });

    await this.auditService.record({
      actorId: actor.id,
      actorEmail: actor.email,
      action: AuditActions.NotificationCreated,
      entityType: 'Notification',
      entityId: notification.id,
      ipAddress: this.extractIp(request),
      userAgent: request?.headers['user-agent'],
      metadata: {
        priority: dto.priority,
        audienceType: dto.audienceType,
        status: notification.status,
      },
    });

    if (publishNow) {
      await this.auditService.record({
        actorId: actor.id,
        actorEmail: actor.email,
        action: AuditActions.NotificationPublished,
        entityType: 'Notification',
        entityId: notification.id,
        ipAddress: this.extractIp(request),
        userAgent: request?.headers['user-agent'],
        metadata: {
          recipientCount: recipients.length,
        },
      });
    }

    return {
      id: notification.id,
      status: notification.status,
      recipientCount: recipients.length,
    };
  }

  async listForUser(
    user: AuthUser,
    query: ListNotificationsQueryDto,
  ): Promise<NotificationListResult> {
    const page = query.page;
    const pageSize = query.pageSize;
    const search = query.search?.trim();

    const where: Prisma.NotificationRecipientWhereInput = {
      userId: user.id,
      notification: {
        status: query.status ?? {
          in: [NotificationStatus.PUBLISHED, NotificationStatus.EXPIRED],
        },
        ...(query.priority ? { priority: query.priority } : {}),
        ...(search
          ? {
              OR: [
                { titleEn: { contains: search, mode: 'insensitive' } },
                { titleAr: { contains: search, mode: 'insensitive' } },
                { bodyEn: { contains: search, mode: 'insensitive' } },
                { bodyAr: { contains: search, mode: 'insensitive' } },
              ],
            }
          : {}),
      },
      ...(query.unreadOnly ? { readAt: null } : {}),
    };

    const [total, rows] = await this.prisma.$transaction([
      this.prisma.notificationRecipient.count({ where }),
      this.prisma.notificationRecipient.findMany({
        where,
        include: { notification: true },
        orderBy: [
          { notification: { createdAt: 'desc' } },
          { createdAt: 'desc' },
        ],
        skip: (page - 1) * pageSize,
        take: pageSize,
      }),
    ]);

    return {
      items: rows.map((row) => this.toListItem(row)),
      page,
      pageSize,
      total,
    };
  }

  async getForUser(
    user: AuthUser,
    notificationId: string,
  ): Promise<NotificationDetail> {
    const row = await this.findRecipientOrThrow(user.id, notificationId);
    return this.toDetail(row);
  }

  async markAsRead(
    user: AuthUser,
    notificationId: string,
    request?: Request,
  ): Promise<NotificationDetail> {
    const row = await this.findRecipientOrThrow(user.id, notificationId);

    if (row.readAt) {
      return this.toDetail(row);
    }

    const updated = await this.prisma.notificationRecipient.update({
      where: { id: row.id },
      data: { readAt: new Date() },
      include: { notification: true },
    });

    await this.auditService.record({
      actorId: user.id,
      actorEmail: user.email,
      action: AuditActions.NotificationRead,
      entityType: 'Notification',
      entityId: notificationId,
      ipAddress: this.extractIp(request),
      userAgent: request?.headers['user-agent'],
      metadata: {
        userId: user.id,
      },
    });

    return this.toDetail(updated);
  }

  async getStats(
    actor: AuthUser,
    notificationId: string,
  ): Promise<NotificationStats> {
    this.assertCanViewStats(actor);

    const notification = await this.prisma.notification.findUnique({
      where: { id: notificationId },
      select: { id: true },
    });
    if (!notification) {
      throw this.notFound();
    }

    const [recipientCount, deliveredCount, readCount] = await Promise.all([
      this.prisma.notificationRecipient.count({
        where: { notificationId },
      }),
      this.prisma.notificationRecipient.count({
        where: { notificationId, deliveredAt: { not: null } },
      }),
      this.prisma.notificationRecipient.count({
        where: { notificationId, readAt: { not: null } },
      }),
    ]);

    const unreadCount = recipientCount - readCount;
    const readPercentage =
      recipientCount === 0
        ? 0
        : Math.round((readCount / recipientCount) * 1000) / 10;

    return {
      notificationId,
      recipientCount,
      deliveredCount,
      readCount,
      unreadCount,
      readPercentage,
    };
  }

  async cancel(
    actor: AuthUser,
    notificationId: string,
    dto: CancelNotificationDto,
    request?: Request,
  ): Promise<CancelNotificationResult> {
    if (actor.role !== UserRole.SYSTEM_ADMIN) {
      throw new BusinessException({
        code: ErrorCode.FORBIDDEN,
        message: 'Insufficient permissions.',
        status: HttpStatus.FORBIDDEN,
      });
    }

    const notification = await this.prisma.notification.findUnique({
      where: { id: notificationId },
    });
    if (!notification) {
      throw this.notFound();
    }

    if (notification.status === NotificationStatus.CANCELLED) {
      return {
        id: notification.id,
        status: notification.status,
      };
    }

    if (
      notification.status !== NotificationStatus.PUBLISHED &&
      notification.status !== NotificationStatus.SCHEDULED &&
      notification.status !== NotificationStatus.DRAFT
    ) {
      throw new BusinessException({
        code: ErrorCode.VALIDATION_ERROR,
        message:
          'Only draft, scheduled, or published notifications can be cancelled.',
        status: HttpStatus.BAD_REQUEST,
      });
    }

    const updated = await this.prisma.notification.update({
      where: { id: notificationId },
      data: { status: NotificationStatus.CANCELLED },
    });

    await this.auditService.record({
      actorId: actor.id,
      actorEmail: actor.email,
      action: AuditActions.NotificationCancelled,
      entityType: 'Notification',
      entityId: notificationId,
      ipAddress: this.extractIp(request),
      userAgent: request?.headers['user-agent'],
      metadata: {
        ...(dto.reason ? { reason: dto.reason } : {}),
        previousStatus: notification.status,
      },
    });

    return {
      id: updated.id,
      status: updated.status,
    };
  }

  private async findRecipientOrThrow(
    userId: string,
    notificationId: string,
  ): Promise<RecipientWithNotification> {
    const row = await this.prisma.notificationRecipient.findUnique({
      where: {
        notificationId_userId: {
          notificationId,
          userId,
        },
      },
      include: { notification: true },
    });

    if (
      !row ||
      row.notification.status === NotificationStatus.CANCELLED ||
      row.notification.status === NotificationStatus.DRAFT ||
      row.notification.status === NotificationStatus.SCHEDULED
    ) {
      throw this.notFound();
    }

    return row;
  }

  private toListItem(row: RecipientWithNotification): NotificationListItem {
    const notification = row.notification;
    return {
      id: notification.id,
      titleEn: notification.titleEn,
      titleAr: notification.titleAr,
      bodyEn: notification.bodyEn,
      bodyAr: notification.bodyAr,
      priority: notification.priority,
      status: notification.status,
      audienceType: notification.audienceType,
      readAt: row.readAt?.toISOString() ?? null,
      createdAt: notification.createdAt.toISOString(),
    };
  }

  private toDetail(row: RecipientWithNotification): NotificationDetail {
    const notification = row.notification;
    return {
      ...this.toListItem(row),
      audienceFilter: notification.audienceFilter,
      publishAt: notification.publishAt?.toISOString() ?? null,
      expiresAt: notification.expiresAt?.toISOString() ?? null,
      deliveredAt: row.deliveredAt?.toISOString() ?? null,
    };
  }

  private resolvePublishAt(
    publishNow: boolean,
    publishAt?: string,
  ): Date | null {
    if (publishNow) {
      return new Date();
    }
    if (!publishAt) {
      throw new BusinessException({
        code: ErrorCode.VALIDATION_ERROR,
        message: 'publishAt is required when publishNow is false.',
        status: HttpStatus.BAD_REQUEST,
      });
    }
    const parsed = new Date(publishAt);
    if (Number.isNaN(parsed.getTime())) {
      throw new BusinessException({
        code: ErrorCode.VALIDATION_ERROR,
        message: 'publishAt must be a valid ISO date.',
        status: HttpStatus.BAD_REQUEST,
      });
    }
    return parsed;
  }

  private resolveExpiresAt(
    publishAt: Date | null,
    expiresAt?: string,
  ): Date | null {
    if (!expiresAt) {
      return null;
    }
    const parsed = new Date(expiresAt);
    if (Number.isNaN(parsed.getTime())) {
      throw new BusinessException({
        code: ErrorCode.VALIDATION_ERROR,
        message: 'expiresAt must be a valid ISO date.',
        status: HttpStatus.BAD_REQUEST,
      });
    }
    if (publishAt && parsed.getTime() <= publishAt.getTime()) {
      throw new BusinessException({
        code: ErrorCode.VALIDATION_ERROR,
        message: 'expiresAt must be after publish time.',
        status: HttpStatus.BAD_REQUEST,
      });
    }
    return parsed;
  }

  private assertCanManageNotifications(actor: AuthUser): void {
    if (
      actor.role !== UserRole.SYSTEM_ADMIN &&
      actor.role !== UserRole.SECURITY_ADMIN
    ) {
      throw new BusinessException({
        code: ErrorCode.FORBIDDEN,
        message: 'Insufficient permissions.',
        status: HttpStatus.FORBIDDEN,
      });
    }
  }

  private assertCanViewStats(actor: AuthUser): void {
    this.assertCanManageNotifications(actor);
  }

  private notFound(): BusinessException {
    return new BusinessException({
      code: ErrorCode.NOTIFICATION_NOT_FOUND,
      message: 'Notification not found.',
      status: HttpStatus.NOT_FOUND,
    });
  }

  private extractIp(request?: Request): string | undefined {
    if (!request) {
      return undefined;
    }
    const forwarded = request.headers['x-forwarded-for'];
    if (typeof forwarded === 'string' && forwarded.length > 0) {
      return forwarded.split(',')[0]?.trim();
    }
    return request.ip;
  }
}
