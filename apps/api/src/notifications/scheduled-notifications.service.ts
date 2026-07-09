import {
  Injectable,
  Logger,
  OnModuleDestroy,
  OnModuleInit,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Notification, NotificationStatus } from '@prisma/client';
import { AuditActions } from '../audit/audit-actions';
import { AuditService } from '../audit/audit.service';
import { PrismaService } from '../prisma/prisma.service';
import { AudienceResolver } from './audience.resolver';

export const DEFAULT_SCHEDULER_INTERVAL_MS = 30_000;

export interface ScheduledPublishSummary {
  published: number;
  failed: number;
}

/**
 * Publishes due SCHEDULED notifications (docs 15 + 20: admins may schedule a
 * future publish time; recipients must be generated when it is reached).
 *
 * Runs a lightweight interval loop instead of an external cron so Phase 1
 * needs no extra dependency. The loop is disabled under NODE_ENV=test;
 * tests invoke {@link publishDueNotifications} directly.
 */
@Injectable()
export class ScheduledNotificationsService
  implements OnModuleInit, OnModuleDestroy
{
  private readonly logger = new Logger(ScheduledNotificationsService.name);
  private timer: NodeJS.Timeout | null = null;
  private running = false;

  constructor(
    private readonly prisma: PrismaService,
    private readonly audienceResolver: AudienceResolver,
    private readonly auditService: AuditService,
    private readonly configService: ConfigService,
  ) {}

  onModuleInit(): void {
    if (this.configService.get<string>('NODE_ENV') === 'test') {
      return;
    }
    const intervalMs = this.resolveIntervalMs();
    this.timer = setInterval(() => {
      void this.tick();
    }, intervalMs);
    this.timer.unref();
    this.logger.log(
      `Scheduled notification publisher started (every ${intervalMs}ms)`,
    );
  }

  onModuleDestroy(): void {
    if (this.timer) {
      clearInterval(this.timer);
      this.timer = null;
    }
  }

  /**
   * Publishes every SCHEDULED notification whose publishAt is due.
   *
   * Failures on one notification are logged and do not block the rest.
   */
  async publishDueNotifications(
    now: Date = new Date(),
  ): Promise<ScheduledPublishSummary> {
    const due = await this.prisma.notification.findMany({
      where: {
        status: NotificationStatus.SCHEDULED,
        publishAt: { lte: now },
      },
      orderBy: { publishAt: 'asc' },
    });

    let published = 0;
    let failed = 0;
    for (const notification of due) {
      try {
        const didPublish = await this.publishOne(notification);
        if (didPublish) {
          published += 1;
        }
      } catch (error) {
        failed += 1;
        this.logger.error(
          `Failed to publish scheduled notification ${notification.id}`,
          error instanceof Error ? error.stack : String(error),
        );
      }
    }

    return { published, failed };
  }

  private async publishOne(notification: Notification): Promise<boolean> {
    const recipients = await this.audienceResolver.resolveAudience({
      audienceType: notification.audienceType,
      audienceFilter: notification.audienceFilter,
    });

    const deliveredAt = new Date();
    const didPublish = await this.prisma.$transaction(async (tx) => {
      // Status guard keeps concurrent ticks (or an admin cancel) from
      // double-publishing the same notification.
      const claimed = await tx.notification.updateMany({
        where: {
          id: notification.id,
          status: NotificationStatus.SCHEDULED,
        },
        data: { status: NotificationStatus.PUBLISHED },
      });
      if (claimed.count === 0) {
        return false;
      }

      if (recipients.length > 0) {
        await tx.notificationRecipient.createMany({
          data: recipients.map((user) => ({
            notificationId: notification.id,
            userId: user.id,
            deliveredAt,
          })),
          skipDuplicates: true,
        });
      }
      return true;
    });

    if (!didPublish) {
      return false;
    }

    await this.auditService.record({
      actorId: notification.createdById,
      action: AuditActions.NotificationPublished,
      entityType: 'Notification',
      entityId: notification.id,
      metadata: {
        recipientCount: recipients.length,
        scheduled: true,
        publishAt: notification.publishAt?.toISOString() ?? null,
      },
    });

    return true;
  }

  private async tick(): Promise<void> {
    if (this.running) {
      return;
    }
    this.running = true;
    try {
      const summary = await this.publishDueNotifications();
      if (summary.published > 0 || summary.failed > 0) {
        this.logger.log(
          `Scheduled publish tick: published=${summary.published} failed=${summary.failed}`,
        );
      }
    } catch (error) {
      this.logger.error(
        'Scheduled publish tick failed',
        error instanceof Error ? error.stack : String(error),
      );
    } finally {
      this.running = false;
    }
  }

  private resolveIntervalMs(): number {
    const raw = this.configService.get<string | number>(
      'NOTIFICATION_SCHEDULER_INTERVAL_MS',
    );
    const parsed =
      typeof raw === 'number' ? raw : Number.parseInt(raw ?? '', 10);
    if (Number.isInteger(parsed) && parsed >= 1_000) {
      return parsed;
    }
    return DEFAULT_SCHEDULER_INTERVAL_MS;
  }
}
