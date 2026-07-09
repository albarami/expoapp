import { Injectable, Logger } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { ListAuditLogsQueryDto } from './dto/list-audit-logs-query.dto';
import {
  AuditInput,
  AuditLogListItem,
  AuditLogListResult,
} from './audit.types';

@Injectable()
export class AuditService {
  private readonly logger = new Logger(AuditService.name);

  constructor(private readonly prisma: PrismaService) {}

  async record(input: AuditInput): Promise<void> {
    try {
      const metadata: Prisma.InputJsonValue | undefined =
        input.metadata === undefined
          ? undefined
          : (input.metadata as Prisma.InputJsonValue);

      await this.prisma.auditLog.create({
        data: {
          actorId: input.actorId,
          actorEmail: input.actorEmail,
          action: input.action,
          entityType: input.entityType,
          entityId: input.entityId,
          ipAddress: input.ipAddress,
          userAgent: input.userAgent,
          metadata,
        },
      });
    } catch (error) {
      this.logger.warn(
        `Failed to write audit log action=${input.action} entityType=${input.entityType}`,
        error instanceof Error ? error.stack : undefined,
      );
    }
  }

  async list(query: ListAuditLogsQueryDto): Promise<AuditLogListResult> {
    const page = query.page;
    const pageSize = query.pageSize;
    const where = this.buildListWhere(query);

    const [total, rows] = await this.prisma.$transaction([
      this.prisma.auditLog.count({ where }),
      this.prisma.auditLog.findMany({
        where,
        orderBy: { createdAt: 'desc' },
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

  private buildListWhere(
    query: ListAuditLogsQueryDto,
  ): Prisma.AuditLogWhereInput {
    const createdAt: Prisma.DateTimeFilter = {};
    if (query.from) {
      createdAt.gte = new Date(query.from);
    }
    if (query.to) {
      createdAt.lte = new Date(query.to);
    }

    return {
      ...(query.actorId ? { actorId: query.actorId } : {}),
      ...(query.actorEmail
        ? { actorEmail: { equals: query.actorEmail, mode: 'insensitive' } }
        : {}),
      ...(query.action ? { action: query.action } : {}),
      ...(query.entityType ? { entityType: query.entityType } : {}),
      ...(query.entityId ? { entityId: query.entityId } : {}),
      ...(query.from || query.to ? { createdAt } : {}),
    };
  }

  private toListItem(row: {
    id: string;
    actorId: string | null;
    actorEmail: string | null;
    action: string;
    entityType: string;
    entityId: string | null;
    metadata: Prisma.JsonValue | null;
    ipAddress: string | null;
    userAgent: string | null;
    createdAt: Date;
  }): AuditLogListItem {
    return {
      id: row.id,
      actorId: row.actorId,
      actorEmail: row.actorEmail,
      action: row.action,
      entityType: row.entityType,
      entityId: row.entityId,
      metadata: this.toMetadataRecord(row.metadata),
      ipAddress: row.ipAddress,
      userAgent: row.userAgent,
      createdAt: row.createdAt.toISOString(),
    };
  }

  private toMetadataRecord(
    metadata: Prisma.JsonValue | null,
  ): Record<string, unknown> | null {
    if (metadata === null) {
      return null;
    }
    if (typeof metadata === 'object' && !Array.isArray(metadata)) {
      return Object.fromEntries(Object.entries(metadata));
    }
    return { value: metadata };
  }
}
