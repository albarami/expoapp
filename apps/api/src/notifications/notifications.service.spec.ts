import {
  AudienceType,
  NotificationPriority,
  NotificationStatus,
  UserRole,
} from '@prisma/client';
import { AuditActions } from '../audit/audit-actions';
import { AuthUser } from '../auth/types/auth-user';
import { ErrorCode } from '../common/constants/error-codes';
import { BusinessException } from '../common/exceptions/business.exception';
import { AudienceResolver } from './audience.resolver';
import { NotificationsService } from './notifications.service';

function makeAdmin(): AuthUser {
  return {
    id: 'admin-1',
    email: 'admin@expo.sa',
    fullNameEn: 'Admin',
    fullNameAr: null,
    role: UserRole.SYSTEM_ADMIN,
    departmentId: 'dept-tech',
    department: {
      id: 'dept-tech',
      code: 'TECH',
      nameEn: 'Technology',
      nameAr: null,
    },
    isActive: true,
    permissions: ['notifications:create', 'notifications:publish'],
  };
}

function makeEmployee(): AuthUser {
  return {
    id: 'emp-1',
    email: 'noura.alharbi@expo.sa',
    fullNameEn: 'Noura',
    fullNameAr: null,
    role: UserRole.EMPLOYEE,
    departmentId: 'dept-ops',
    department: {
      id: 'dept-ops',
      code: 'OPS',
      nameEn: 'Operations',
      nameAr: null,
    },
    isActive: true,
    permissions: ['notifications:read'],
  };
}

describe('NotificationsService', () => {
  it('creates and publishes with recipients + audit', async () => {
    const created = {
      id: 'notif-1',
      status: NotificationStatus.PUBLISHED,
    };
    const tx = {
      notification: {
        create: jest.fn().mockResolvedValue(created),
      },
      notificationRecipient: {
        createMany: jest.fn().mockResolvedValue({ count: 2 }),
      },
    };
    const prisma = {
      $transaction: jest.fn((fn: (client: typeof tx) => unknown) => fn(tx)),
    };
    const audienceResolver = {
      validateAndNormalizeFilter: jest.fn().mockReturnValue({ all: true }),
      resolveAudience: jest
        .fn()
        .mockResolvedValue([{ id: 'u1' }, { id: 'u2' }]),
    };
    const auditService = {
      record: jest.fn().mockResolvedValue(undefined),
    };

    const service = new NotificationsService(
      prisma as never,
      audienceResolver as unknown as AudienceResolver,
      auditService as never,
    );

    const result = await service.createNotification(makeAdmin(), {
      titleEn: 'Ops briefing',
      bodyEn: 'Please attend the morning briefing today.',
      priority: NotificationPriority.HIGH,
      audienceType: AudienceType.ALL,
      audienceFilter: { all: true },
      publishNow: true,
    });

    expect(result).toEqual({
      id: 'notif-1',
      status: NotificationStatus.PUBLISHED,
      recipientCount: 2,
    });
    expect(tx.notificationRecipient.createMany).toHaveBeenCalled();
    expect(auditService.record).toHaveBeenCalledWith(
      expect.objectContaining({
        action: AuditActions.NotificationCreated,
      }),
    );
    expect(auditService.record).toHaveBeenCalledWith(
      expect.objectContaining({
        action: AuditActions.NotificationPublished,
        metadata: { recipientCount: 2 },
      }),
    );
  });

  it('marks unread notification as read and audits', async () => {
    const notification = {
      id: 'notif-1',
      titleEn: 'Hello',
      titleAr: null,
      bodyEn: 'Body text here',
      bodyAr: null,
      priority: NotificationPriority.NORMAL,
      status: NotificationStatus.PUBLISHED,
      audienceType: AudienceType.ALL,
      audienceFilter: { all: true },
      publishAt: new Date('2026-07-01T00:00:00.000Z'),
      expiresAt: null,
      createdAt: new Date('2026-07-01T00:00:00.000Z'),
    };
    const recipient = {
      id: 'rec-1',
      notificationId: 'notif-1',
      userId: 'emp-1',
      deliveredAt: new Date('2026-07-01T00:00:00.000Z'),
      readAt: null,
      createdAt: new Date('2026-07-01T00:00:00.000Z'),
      notification,
    };
    const updated = {
      ...recipient,
      readAt: new Date('2026-07-02T00:00:00.000Z'),
    };

    const prisma = {
      notificationRecipient: {
        findUnique: jest.fn().mockResolvedValue(recipient),
        update: jest.fn().mockResolvedValue(updated),
      },
    };
    const auditService = {
      record: jest.fn().mockResolvedValue(undefined),
    };
    const service = new NotificationsService(
      prisma as never,
      {} as AudienceResolver,
      auditService as never,
    );

    const detail = await service.markAsRead(makeEmployee(), 'notif-1');
    expect(detail.readAt).toBe('2026-07-02T00:00:00.000Z');
    expect(auditService.record).toHaveBeenCalledWith(
      expect.objectContaining({
        action: AuditActions.NotificationRead,
        metadata: { userId: 'emp-1' },
      }),
    );
  });

  it('returns NOTIFICATION_NOT_FOUND when recipient missing', async () => {
    const prisma = {
      notificationRecipient: {
        findUnique: jest.fn().mockResolvedValue(null),
      },
    };
    const service = new NotificationsService(
      prisma as never,
      {} as AudienceResolver,
      { record: jest.fn() } as never,
    );

    try {
      await service.getForUser(makeEmployee(), 'missing');
      fail('expected throw');
    } catch (error) {
      expect(error).toBeInstanceOf(BusinessException);
      expect((error as BusinessException).code).toBe(
        ErrorCode.NOTIFICATION_NOT_FOUND,
      );
    }
  });
});
