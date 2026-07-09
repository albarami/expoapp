import { Injectable } from '@nestjs/common';
import { OutboxStatus, Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { OUTBOX_TYPE_ACCESS_PROVISIONING } from './fusion.constants';
import { SubmitFusionProvisioningInput } from './fusion-adapter.interface';

export type EnqueueAccessProvisioningInput = {
  payload: SubmitFusionProvisioningInput;
  nextAttemptAt?: Date;
};

@Injectable()
export class IntegrationOutboxService {
  constructor(private readonly prisma: PrismaService) {}

  async enqueueAccessProvisioning(
    input: EnqueueAccessProvisioningInput,
  ): Promise<{ id: string }> {
    const row = await this.prisma.integrationOutbox.create({
      data: {
        type: OUTBOX_TYPE_ACCESS_PROVISIONING,
        payload: input.payload as unknown as Prisma.InputJsonValue,
        status: OutboxStatus.PENDING,
        nextAttemptAt: input.nextAttemptAt ?? new Date(),
      },
      select: { id: true },
    });

    return row;
  }

  async markCompleted(id: string): Promise<void> {
    await this.prisma.integrationOutbox.update({
      where: { id },
      data: {
        status: OutboxStatus.COMPLETED,
        lastError: null,
      },
    });
  }

  async markFailed(params: {
    id: string;
    error: string;
    nextAttemptAt?: Date | null;
    terminal?: boolean;
  }): Promise<void> {
    await this.prisma.integrationOutbox.update({
      where: { id: params.id },
      data: {
        status: params.terminal ? OutboxStatus.FAILED : OutboxStatus.PENDING,
        lastError: params.error,
        attempts: { increment: 1 },
        nextAttemptAt: params.nextAttemptAt ?? null,
      },
    });
  }
}
