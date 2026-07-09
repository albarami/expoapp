import { AudienceType, NotificationStatus } from '@prisma/client';
import { AuditActions } from '../audit/audit-actions';
import { AudienceResolver } from './audience.resolver';
import { ScheduledNotificationsService } from './scheduled-notifications.service';

const NOW = new Date('2026-07-09T12:00:00.000Z');

function makeScheduledNotification(overrides: Record<string, unknown> = {}) {
  return {
    id: 'notif-1',
    titleEn: 'Scheduled briefing',
    titleAr: null,
    bodyEn: 'Scheduled briefing body',
    bodyAr: null,
    priority: 'NORMAL',
    status: NotificationStatus.SCHEDULED,
    audienceType: AudienceType.ALL,
    audienceFilter: { all: true },
    publishAt: new Date('2026-07-09T11:00:00.000Z'),
    expiresAt: null,
    createdById: 'admin-1',
    createdAt: new Date('2026-07-08T00:00:00.000Z'),
    updatedAt: new Date('2026-07-08T00:00:00.000Z'),
    ...overrides,
  };
}

function makeHarness(options: {
  due: unknown[];
  claimedCount?: number;
  resolveError?: Error;
}) {
  const tx = {
    notification: {
      updateMany: jest
        .fn()
        .mockResolvedValue({ count: options.claimedCount ?? 1 }),
    },
    notificationRecipient: {
      createMany: jest.fn().mockResolvedValue({ count: 2 }),
    },
  };
  const prisma = {
    notification: {
      findMany: jest.fn().mockResolvedValue(options.due),
    },
    $transaction: jest.fn((fn: (client: typeof tx) => unknown) => fn(tx)),
  };
  const audienceResolver = {
    resolveAudience: options.resolveError
      ? jest.fn().mockRejectedValue(options.resolveError)
      : jest.fn().mockResolvedValue([{ id: 'u1' }, { id: 'u2' }]),
  };
  const auditService = {
    record: jest.fn().mockResolvedValue(undefined),
  };
  const configService = {
    get: jest.fn().mockReturnValue('test'),
  };

  const service = new ScheduledNotificationsService(
    prisma as never,
    audienceResolver as unknown as AudienceResolver,
    auditService as never,
    configService as never,
  );

  return { service, prisma, tx, audienceResolver, auditService };
}

describe('ScheduledNotificationsService', () => {
  it('publishes due scheduled notifications with recipients + audit (happy path)', async () => {
    const { service, prisma, tx, auditService } = makeHarness({
      due: [makeScheduledNotification()],
    });

    const summary = await service.publishDueNotifications(NOW);

    expect(summary).toEqual({ published: 1, failed: 0 });
    expect(prisma.notification.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          status: NotificationStatus.SCHEDULED,
          publishAt: { lte: NOW },
        },
      }),
    );
    expect(tx.notification.updateMany).toHaveBeenCalledWith({
      where: { id: 'notif-1', status: NotificationStatus.SCHEDULED },
      data: { status: NotificationStatus.PUBLISHED },
    });
    expect(tx.notificationRecipient.createMany).toHaveBeenCalledWith(
      expect.objectContaining({
        data: [
          expect.objectContaining({ notificationId: 'notif-1', userId: 'u1' }),
          expect.objectContaining({ notificationId: 'notif-1', userId: 'u2' }),
        ],
        skipDuplicates: true,
      }),
    );
    expect(auditService.record).toHaveBeenCalledWith(
      expect.objectContaining({
        actorId: 'admin-1',
        action: AuditActions.NotificationPublished,
        entityId: 'notif-1',
        metadata: expect.objectContaining({
          recipientCount: 2,
          scheduled: true,
        }) as object,
      }),
    );
  });

  it('skips notifications claimed by a concurrent publisher (edge)', async () => {
    const { service, tx, auditService } = makeHarness({
      due: [makeScheduledNotification()],
      claimedCount: 0,
    });

    const summary = await service.publishDueNotifications(NOW);

    expect(summary).toEqual({ published: 0, failed: 0 });
    expect(tx.notificationRecipient.createMany).not.toHaveBeenCalled();
    expect(auditService.record).not.toHaveBeenCalled();
  });

  it('does nothing when no notifications are due (edge)', async () => {
    const { service, prisma, auditService } = makeHarness({ due: [] });

    const summary = await service.publishDueNotifications(NOW);

    expect(summary).toEqual({ published: 0, failed: 0 });
    expect(prisma.$transaction).not.toHaveBeenCalled();
    expect(auditService.record).not.toHaveBeenCalled();
  });

  it('records a failure but continues when audience resolution throws (failure path)', async () => {
    const { service, auditService } = makeHarness({
      due: [
        makeScheduledNotification(),
        makeScheduledNotification({ id: 'notif-2' }),
      ],
      resolveError: new Error('resolver exploded'),
    });

    const summary = await service.publishDueNotifications(NOW);

    expect(summary).toEqual({ published: 0, failed: 2 });
    expect(auditService.record).not.toHaveBeenCalled();
  });
});
