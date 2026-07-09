import { Test, TestingModule } from '@nestjs/testing';
import {
  AccessRequestStatus,
  AccessUrgency,
  NotificationPriority,
  NotificationStatus,
  UserRole,
} from '@prisma/client';
import { AuthUser } from '../auth/types/auth-user';
import { PrismaService } from '../prisma/prisma.service';
import { DashboardService } from './dashboard.service';

describe('DashboardService', () => {
  let service: DashboardService;

  const notificationRecipientCount = jest.fn();
  const notificationRecipientFindMany = jest.fn();
  const accessRequestCount = jest.fn();
  const accessRequestFindMany = jest.fn();
  const approvalTaskCount = jest.fn();
  const notificationCount = jest.fn();
  const auditLogFindMany = jest.fn();

  const employee: AuthUser = {
    id: 'user-employee',
    email: 'noura.alharbi@expo.sa',
    fullNameEn: 'Noura Alharbi',
    fullNameAr: 'نورة الحربي',
    role: UserRole.EMPLOYEE,
    departmentId: 'dept-1',
    department: {
      id: 'dept-1',
      code: 'OPS',
      nameEn: 'Operations',
      nameAr: 'العمليات',
    },
    isActive: true,
    permissions: [],
  };

  beforeEach(async () => {
    jest.clearAllMocks();

    notificationRecipientCount.mockResolvedValue(4);
    accessRequestCount.mockResolvedValue(2);
    approvalTaskCount.mockResolvedValue(0);
    notificationRecipientFindMany.mockResolvedValue([
      {
        readAt: null,
        notification: {
          id: 'n1',
          titleEn: 'Hello',
          titleAr: null,
          priority: NotificationPriority.HIGH,
          status: NotificationStatus.PUBLISHED,
          createdAt: new Date('2026-07-01T00:00:00.000Z'),
        },
      },
    ]);
    accessRequestFindMany.mockResolvedValue([
      {
        id: 'ar1',
        requestNumber: 'AR-2026-000001',
        status: AccessRequestStatus.MANAGER_PENDING,
        urgency: AccessUrgency.NORMAL,
        submittedAt: new Date('2026-07-02T00:00:00.000Z'),
        createdAt: new Date('2026-07-02T00:00:00.000Z'),
        system: { code: 'ORACLE_FUSION_ERP', nameEn: 'Oracle Fusion ERP' },
        securityRole: { code: 'FUSION_AP_INQUIRY', nameEn: 'AP Inquiry' },
      },
    ]);
    notificationCount.mockResolvedValue(6);
    auditLogFindMany.mockResolvedValue([]);

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        DashboardService,
        {
          provide: PrismaService,
          useValue: {
            notificationRecipient: {
              count: notificationRecipientCount,
              findMany: notificationRecipientFindMany,
            },
            accessRequest: {
              count: accessRequestCount,
              findMany: accessRequestFindMany,
            },
            approvalTask: {
              count: approvalTaskCount,
            },
            notification: {
              count: notificationCount,
            },
            auditLog: {
              findMany: auditLogFindMany,
            },
          },
        },
      ],
    }).compile();

    service = module.get(DashboardService);
  });

  it('returns employee summary with core counters and latest lists', async () => {
    // open + completed use accessRequest.count sequentially via Promise.all
    accessRequestCount
      .mockResolvedValueOnce(2) // open
      .mockResolvedValueOnce(5); // completed

    const summary = await service.getSummary(employee);

    expect(summary.role).toBe(UserRole.EMPLOYEE);
    expect(summary.unreadNotifications).toBe(4);
    expect(summary.openAccessRequests).toBe(2);
    expect(summary.completedRequests).toBe(5);
    expect(summary.pendingApprovals).toBe(0);
    expect(summary.latestNotifications).toHaveLength(1);
    expect(summary.latestRequests[0]?.requestNumber).toBe('AR-2026-000001');
    expect(summary.notificationStats).toBeUndefined();
    expect(summary.recentAuditEvents).toBeUndefined();
  });

  it('includes teamOpenRequests for managers', async () => {
    accessRequestCount
      .mockResolvedValueOnce(1) // open own
      .mockResolvedValueOnce(0) // completed own
      .mockResolvedValueOnce(3); // team open

    const manager: AuthUser = { ...employee, role: UserRole.MANAGER };
    const summary = await service.getSummary(manager);

    expect(summary.teamOpenRequests).toBe(3);
  });

  it('includes security widgets for security admins', async () => {
    accessRequestCount
      .mockResolvedValueOnce(0) // open own
      .mockResolvedValueOnce(0) // completed own
      .mockResolvedValueOnce(2); // high risk
    approvalTaskCount
      .mockResolvedValueOnce(1) // pending for assignee
      .mockResolvedValueOnce(4); // pending security stage
    auditLogFindMany.mockResolvedValue([
      {
        id: 'a1',
        action: 'LOGIN_SUCCESS',
        entityType: 'User',
        entityId: 'u1',
        actorEmail: 'reem.security@expo.sa',
        createdAt: new Date('2026-07-03T00:00:00.000Z'),
      },
    ]);

    const security: AuthUser = {
      ...employee,
      role: UserRole.SECURITY_ADMIN,
    };
    const summary = await service.getSummary(security);

    expect(summary.pendingSecurityApprovals).toBe(4);
    expect(summary.highRiskOpenRequests).toBe(2);
    expect(summary.recentAuditEvents).toHaveLength(1);
  });

  it('includes admin notification and workflow stats', async () => {
    accessRequestCount
      .mockResolvedValueOnce(0) // open own
      .mockResolvedValueOnce(0) // completed own
      .mockResolvedValueOnce(7) // workflow open
      .mockResolvedValueOnce(1); // workflow completed
    approvalTaskCount
      .mockResolvedValueOnce(0) // pending for assignee
      .mockResolvedValueOnce(2) // pending manager
      .mockResolvedValueOnce(3); // pending security
    notificationRecipientCount
      .mockResolvedValueOnce(0) // unread for user
      .mockResolvedValueOnce(20) // recipients
      .mockResolvedValueOnce(10); // read

    const admin: AuthUser = { ...employee, role: UserRole.SYSTEM_ADMIN };
    const summary = await service.getSummary(admin);

    expect(summary.notificationStats).toEqual({
      publishedCount: 6,
      recipientCount: 20,
      readCount: 10,
      readPercentage: 50,
    });
    expect(summary.accessWorkflowStats).toEqual({
      openAccessRequests: 7,
      pendingManagerApprovals: 2,
      pendingSecurityApprovals: 3,
      completedRequests: 1,
    });
  });
});
