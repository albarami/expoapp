import { AuditService } from './audit.service';
import { AuditActions } from './audit-actions';

describe('AuditService (BU-05 scaffold for notifications)', () => {
  it('records expected fields without secrets', async () => {
    const create = jest.fn().mockResolvedValue({ id: 'audit-1' });
    const prisma = {
      auditLog: { create },
    };
    const service = new AuditService(prisma as never);

    await service.record({
      actorId: 'user-1',
      actorEmail: 'admin@expo.sa',
      action: AuditActions.NotificationPublished,
      entityType: 'Notification',
      entityId: 'notif-1',
      metadata: { recipientCount: 3 },
    });

    expect(create).toHaveBeenCalledWith({
      data: {
        actorId: 'user-1',
        actorEmail: 'admin@expo.sa',
        action: AuditActions.NotificationPublished,
        entityType: 'Notification',
        entityId: 'notif-1',
        ipAddress: undefined,
        userAgent: undefined,
        metadata: { recipientCount: 3 },
      },
    });
  });

  it('swallows write failures so callers are not blocked', async () => {
    const prisma = {
      auditLog: {
        create: jest.fn().mockRejectedValue(new Error('db down')),
      },
    };
    const service = new AuditService(prisma as never);

    await expect(
      service.record({
        action: AuditActions.NotificationCreated,
        entityType: 'Notification',
      }),
    ).resolves.toBeUndefined();
  });
});
