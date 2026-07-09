import { AuditService } from './audit.service';
import { AuditActions } from './audit-actions';
import { ListAuditLogsQueryDto } from './dto/list-audit-logs-query.dto';

describe('AuditService (BU-05)', () => {
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

  it('lists audit logs with filters and pagination', async () => {
    const createdAt = new Date('2026-07-09T12:00:00.000Z');
    const count = jest.fn().mockResolvedValue(1);
    const findMany = jest.fn().mockResolvedValue([
      {
        id: 'audit-1',
        actorId: 'user-1',
        actorEmail: 'admin@expo.sa',
        action: AuditActions.NotificationPublished,
        entityType: 'Notification',
        entityId: 'notif-1',
        metadata: { recipientCount: 3 },
        ipAddress: '127.0.0.1',
        userAgent: 'jest',
        createdAt,
      },
    ]);
    const prisma = {
      $transaction: jest.fn(async (ops: unknown[]) =>
        Promise.all(ops as Promise<unknown>[]),
      ),
      auditLog: { count, findMany },
    };
    const service = new AuditService(prisma as never);

    const query = Object.assign(new ListAuditLogsQueryDto(), {
      page: 1,
      pageSize: 10,
      actorId: 'user-1',
      actorEmail: 'admin@expo.sa',
      action: AuditActions.NotificationPublished,
      entityType: 'Notification',
      entityId: 'notif-1',
      from: '2026-07-01T00:00:00.000Z',
      to: '2026-07-31T23:59:59.999Z',
    });

    const result = await service.list(query);

    expect(count).toHaveBeenCalledWith({
      where: {
        actorId: 'user-1',
        actorEmail: { equals: 'admin@expo.sa', mode: 'insensitive' },
        action: AuditActions.NotificationPublished,
        entityType: 'Notification',
        entityId: 'notif-1',
        createdAt: {
          gte: new Date('2026-07-01T00:00:00.000Z'),
          lte: new Date('2026-07-31T23:59:59.999Z'),
        },
      },
    });
    expect(findMany).toHaveBeenCalledWith({
      where: {
        actorId: 'user-1',
        actorEmail: { equals: 'admin@expo.sa', mode: 'insensitive' },
        action: AuditActions.NotificationPublished,
        entityType: 'Notification',
        entityId: 'notif-1',
        createdAt: {
          gte: new Date('2026-07-01T00:00:00.000Z'),
          lte: new Date('2026-07-31T23:59:59.999Z'),
        },
      },
      orderBy: { createdAt: 'desc' },
      skip: 0,
      take: 10,
    });
    expect(result).toEqual({
      items: [
        {
          id: 'audit-1',
          actorId: 'user-1',
          actorEmail: 'admin@expo.sa',
          action: AuditActions.NotificationPublished,
          entityType: 'Notification',
          entityId: 'notif-1',
          metadata: { recipientCount: 3 },
          ipAddress: '127.0.0.1',
          userAgent: 'jest',
          createdAt: '2026-07-09T12:00:00.000Z',
        },
      ],
      page: 1,
      pageSize: 10,
      total: 1,
    });
  });
});
