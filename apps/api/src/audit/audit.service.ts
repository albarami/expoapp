import { Injectable, Logger } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { AuditInput } from './audit.types';

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
}
