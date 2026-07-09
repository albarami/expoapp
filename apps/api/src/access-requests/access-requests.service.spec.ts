import {
  AccessDuration,
  AccessRequestStage,
  AccessRequestStatus,
  AccessUrgency,
  ApprovalDecision,
  ApprovalStage,
  UserRole,
} from '@prisma/client';
import { AuditActions } from '../audit/audit-actions';
import { AuthUser } from '../auth/types/auth-user';
import { ErrorCode } from '../common/constants/error-codes';
import { BusinessException } from '../common/exceptions/business.exception';
import type { FusionAdapter } from '../fusion/fusion-adapter.interface';
import { AccessRequestsService } from './access-requests.service';
import { AccessRequestEventType } from './access-requests.types';

function makeEmployee(overrides: Partial<AuthUser> = {}): AuthUser {
  return {
    id: 'emp-1',
    email: 'noura.alharbi@expo.sa',
    fullNameEn: 'Noura Alharbi',
    fullNameAr: 'نورة الحربي',
    role: UserRole.EMPLOYEE,
    departmentId: 'dept-ops',
    department: {
      id: 'dept-ops',
      code: 'OPS',
      nameEn: 'Operations',
      nameAr: null,
    },
    isActive: true,
    permissions: ['accessRequests:create', 'accessRequests:readOwn'],
    ...overrides,
  };
}

function makeAdmin(): AuthUser {
  return makeEmployee({
    id: 'admin-1',
    email: 'admin@expo.sa',
    fullNameEn: 'Expo System Admin',
    role: UserRole.SYSTEM_ADMIN,
    permissions: ['accessRequests:readAll'],
  });
}

describe('AccessRequestsService (BU-03 / BI-05 unit)', () => {
  const baseDto = {
    systemId: 'sys-1',
    securityRoleId: 'role-1',
    businessJustification:
      'I need temporary inquiry access to validate vendor invoice status.',
    accessDuration: AccessDuration.TEMPORARY,
    startDate: '2026-07-10T00:00:00.000Z',
    endDate: '2026-08-10T00:00:00.000Z',
    urgency: AccessUrgency.NORMAL,
  };

  it('submits request with manager task, events, numbering, and audit', async () => {
    const created = {
      id: 'ar-1',
      requestNumber: 'AR-2026-000005',
      status: AccessRequestStatus.MANAGER_PENDING,
      currentStage: AccessRequestStage.MANAGER,
      systemId: baseDto.systemId,
      securityRoleId: baseDto.securityRoleId,
    };

    const tx = {
      accessRequest: {
        findFirst: jest.fn().mockResolvedValue({
          requestNumber: 'AR-2026-000004',
        }),
        create: jest.fn().mockResolvedValue(created),
      },
      accessRequestEvent: {
        create: jest.fn().mockResolvedValue({ id: 'evt-1' }),
      },
      approvalTask: {
        create: jest.fn().mockResolvedValue({ id: 'task-1' }),
      },
    };

    const prisma = {
      user: {
        findUnique: jest.fn().mockResolvedValue({
          id: 'emp-1',
          email: 'noura.alharbi@expo.sa',
          fullNameEn: 'Noura Alharbi',
          fullNameAr: 'نورة الحربي',
          externalRef: 'ext-e1001',
          isActive: true,
          managerId: 'mgr-1',
          manager: {
            id: 'mgr-1',
            fullNameEn: 'Faisal Otaibi',
            fullNameAr: 'فيصل العتيبي',
            isActive: true,
            role: UserRole.MANAGER,
          },
        }),
      },
      securityRoleCatalog: {
        findFirst: jest.fn().mockResolvedValue({
          id: 'role-1',
          code: 'FUSION_AP_INQUIRY',
          isActive: true,
          requiresManagerApproval: true,
          requiresSecurityApproval: true,
          system: { id: 'sys-1', code: 'ORACLE_FUSION_ERP', isActive: true },
        }),
      },
      accessRequest: {
        findFirst: jest.fn().mockResolvedValue(null),
      },
      $transaction: jest.fn((fn: (client: typeof tx) => unknown) => fn(tx)),
    };

    const fusionAdapter: Pick<FusionAdapter, 'validateAccessRequest'> = {
      validateAccessRequest: jest.fn().mockResolvedValue({ valid: true }),
    };

    const auditService = {
      record: jest.fn().mockResolvedValue(undefined),
    };

    const service = new AccessRequestsService(
      prisma as never,
      auditService as never,
      fusionAdapter as FusionAdapter,
    );

    const result = await service.createRequest(makeEmployee(), baseDto);

    expect(result).toEqual({
      id: 'ar-1',
      requestNumber: 'AR-2026-000005',
      status: AccessRequestStatus.MANAGER_PENDING,
      currentStage: AccessRequestStage.MANAGER,
      nextApprover: {
        id: 'mgr-1',
        fullNameEn: 'Faisal Otaibi',
        fullNameAr: 'فيصل العتيبي',
      },
    });
    expect(tx.approvalTask.create).toHaveBeenCalledWith({
      data: {
        accessRequestId: 'ar-1',
        stage: ApprovalStage.MANAGER,
        assigneeId: 'mgr-1',
        decision: ApprovalDecision.PENDING,
      },
    });
    const eventTypes = (
      tx.accessRequestEvent.create.mock.calls as Array<
        [{ data: { eventType: string } }]
      >
    ).map((call) => call[0].data.eventType);
    expect(eventTypes).toEqual(
      expect.arrayContaining([
        AccessRequestEventType.Submitted,
        AccessRequestEventType.ManagerTaskAssigned,
      ]),
    );
    expect(auditService.record).toHaveBeenCalledWith(
      expect.objectContaining({
        action: AuditActions.AccessRequestSubmitted,
        entityType: 'AccessRequest',
        entityId: 'ar-1',
      }),
    );
  });

  it('rejects inactive role with ROLE_NOT_REQUESTABLE', async () => {
    const prisma = {
      user: {
        findUnique: jest.fn().mockResolvedValue({
          id: 'emp-1',
          externalRef: 'ext-e1001',
          isActive: true,
          fullNameEn: 'Noura',
          fullNameAr: null,
          manager: null,
        }),
      },
      securityRoleCatalog: {
        findFirst: jest.fn().mockResolvedValue({
          id: 'role-1',
          code: 'INACTIVE',
          isActive: false,
          requiresManagerApproval: true,
          requiresSecurityApproval: true,
          system: { id: 'sys-1', code: 'ERP', isActive: true },
        }),
      },
      accessRequest: { findFirst: jest.fn() },
      $transaction: jest.fn(),
    };
    const fusionAdapter = {
      validateAccessRequest: jest.fn(),
    };
    const service = new AccessRequestsService(
      prisma as never,
      { record: jest.fn() } as never,
      fusionAdapter as never,
    );

    await expect(
      service.createRequest(makeEmployee(), baseDto),
    ).rejects.toMatchObject({
      code: ErrorCode.ROLE_NOT_REQUESTABLE,
    } satisfies Partial<BusinessException>);
    expect(fusionAdapter.validateAccessRequest).not.toHaveBeenCalled();
  });

  it('rejects missing manager with MANAGER_NOT_FOUND', async () => {
    const prisma = {
      user: {
        findUnique: jest.fn().mockResolvedValue({
          id: 'emp-1',
          externalRef: 'ext-e1001',
          isActive: true,
          fullNameEn: 'Noura',
          fullNameAr: null,
          managerId: null,
          manager: null,
        }),
      },
      securityRoleCatalog: {
        findFirst: jest.fn().mockResolvedValue({
          id: 'role-1',
          code: 'FUSION_AP_INQUIRY',
          isActive: true,
          requiresManagerApproval: true,
          requiresSecurityApproval: true,
          system: { id: 'sys-1', code: 'ORACLE_FUSION_ERP', isActive: true },
        }),
      },
      accessRequest: { findFirst: jest.fn().mockResolvedValue(null) },
      $transaction: jest.fn(),
    };
    const fusionAdapter = {
      validateAccessRequest: jest.fn().mockResolvedValue({ valid: true }),
    };
    const service = new AccessRequestsService(
      prisma as never,
      { record: jest.fn() } as never,
      fusionAdapter as never,
    );

    await expect(
      service.createRequest(makeEmployee(), baseDto),
    ).rejects.toMatchObject({
      code: ErrorCode.MANAGER_NOT_FOUND,
    });
  });

  it('rejects invalid temporary dates with INVALID_ACCESS_DATES', async () => {
    const prisma = {
      user: {
        findUnique: jest.fn().mockResolvedValue({
          id: 'emp-1',
          externalRef: 'ext-e1001',
          isActive: true,
          fullNameEn: 'Noura',
          fullNameAr: null,
          manager: {
            id: 'mgr-1',
            fullNameEn: 'Faisal',
            fullNameAr: null,
            isActive: true,
          },
        }),
      },
      securityRoleCatalog: { findFirst: jest.fn() },
      accessRequest: { findFirst: jest.fn() },
      $transaction: jest.fn(),
    };
    const service = new AccessRequestsService(
      prisma as never,
      { record: jest.fn() } as never,
      { validateAccessRequest: jest.fn() } as never,
    );

    await expect(
      service.createRequest(makeEmployee(), {
        ...baseDto,
        endDate: '2026-07-01T00:00:00.000Z',
      }),
    ).rejects.toMatchObject({
      code: ErrorCode.INVALID_ACCESS_DATES,
    });
  });

  it('rejects duplicate active request', async () => {
    const prisma = {
      user: {
        findUnique: jest.fn().mockResolvedValue({
          id: 'emp-1',
          externalRef: 'ext-e1001',
          isActive: true,
          fullNameEn: 'Noura',
          fullNameAr: null,
          manager: {
            id: 'mgr-1',
            fullNameEn: 'Faisal',
            fullNameAr: null,
            isActive: true,
          },
        }),
      },
      securityRoleCatalog: {
        findFirst: jest.fn().mockResolvedValue({
          id: 'role-1',
          code: 'FUSION_AP_INQUIRY',
          isActive: true,
          requiresManagerApproval: true,
          requiresSecurityApproval: true,
          system: { id: 'sys-1', code: 'ORACLE_FUSION_ERP', isActive: true },
        }),
      },
      accessRequest: {
        findFirst: jest.fn().mockResolvedValue({
          id: 'ar-existing',
          requestNumber: 'AR-2026-000001',
        }),
      },
      $transaction: jest.fn(),
    };
    const service = new AccessRequestsService(
      prisma as never,
      { record: jest.fn() } as never,
      {
        validateAccessRequest: jest.fn().mockResolvedValue({ valid: true }),
      } as never,
    );

    await expect(
      service.createRequest(makeEmployee(), baseDto),
    ).rejects.toMatchObject({
      code: ErrorCode.DUPLICATE_ACTIVE_REQUEST,
    });
  });

  it('cancels pending request and writes audit', async () => {
    const tx = {
      accessRequest: {
        update: jest.fn().mockResolvedValue({
          id: 'ar-1',
          requestNumber: 'AR-2026-000001',
          status: AccessRequestStatus.CANCELLED,
          currentStage: AccessRequestStage.REQUESTER,
        }),
      },
      approvalTask: {
        updateMany: jest.fn().mockResolvedValue({ count: 1 }),
      },
      accessRequestEvent: {
        create: jest.fn().mockResolvedValue({ id: 'evt-cancel' }),
      },
    };
    const prisma = {
      accessRequest: {
        findUnique: jest.fn().mockResolvedValue({
          id: 'ar-1',
          requestNumber: 'AR-2026-000001',
          requesterId: 'emp-1',
          status: AccessRequestStatus.MANAGER_PENDING,
          currentStage: AccessRequestStage.MANAGER,
        }),
      },
      $transaction: jest.fn((fn: (client: typeof tx) => unknown) => fn(tx)),
    };
    const auditService = { record: jest.fn().mockResolvedValue(undefined) };
    const service = new AccessRequestsService(
      prisma as never,
      auditService as never,
      { validateAccessRequest: jest.fn() } as never,
    );

    const result = await service.cancelRequest(makeEmployee(), 'ar-1');

    expect(result.status).toBe(AccessRequestStatus.CANCELLED);
    expect(auditService.record).toHaveBeenCalledWith(
      expect.objectContaining({
        action: AuditActions.AccessRequestCancelled,
        entityId: 'ar-1',
      }),
    );
  });

  it('rejects cancel when status is not cancelable', async () => {
    const prisma = {
      accessRequest: {
        findUnique: jest.fn().mockResolvedValue({
          id: 'ar-1',
          requestNumber: 'AR-2026-000001',
          requesterId: 'emp-1',
          status: AccessRequestStatus.COMPLETED,
          currentStage: AccessRequestStage.COMPLETE,
        }),
      },
      $transaction: jest.fn(),
    };
    const service = new AccessRequestsService(
      prisma as never,
      { record: jest.fn() } as never,
      { validateAccessRequest: jest.fn() } as never,
    );

    await expect(
      service.cancelRequest(makeEmployee(), 'ar-1'),
    ).rejects.toMatchObject({
      code: ErrorCode.REQUEST_NOT_CANCELABLE,
    });
  });

  it('lists only own requests for employee', async () => {
    const count = jest.fn().mockResolvedValue(1);
    const findMany = jest.fn().mockResolvedValue([
      {
        id: 'ar-1',
        requestNumber: 'AR-2026-000001',
        status: AccessRequestStatus.MANAGER_PENDING,
        currentStage: AccessRequestStage.MANAGER,
        urgency: AccessUrgency.NORMAL,
        accessDuration: AccessDuration.TEMPORARY,
        submittedAt: new Date('2026-07-01T00:00:00.000Z'),
        createdAt: new Date('2026-07-01T00:00:00.000Z'),
        system: { id: 'sys-1', code: 'ERP', nameEn: 'ERP', nameAr: null },
        securityRole: { id: 'role-1', code: 'AP', nameEn: 'AP', nameAr: null },
        requester: {
          id: 'emp-1',
          fullNameEn: 'Noura',
          fullNameAr: null,
          email: 'noura.alharbi@expo.sa',
        },
      },
    ]);
    const listPrisma = {
      accessRequest: { count, findMany },
      $transaction: jest.fn((ops: unknown[]) => Promise.all(ops)),
    };

    const service = new AccessRequestsService(
      listPrisma as never,
      { record: jest.fn() } as never,
      { validateAccessRequest: jest.fn() } as never,
    );

    const result = await service.listRequests(makeEmployee(), {
      page: 1,
      pageSize: 20,
    });

    expect(result.total).toBe(1);
    expect(result.items[0]?.requestNumber).toBe('AR-2026-000001');
    expect(count).toHaveBeenCalledWith({
      where: { requesterId: 'emp-1' },
    });
  });

  it('allows system admin to list all requests', async () => {
    const count = jest.fn().mockResolvedValue(0);
    const findMany = jest.fn().mockResolvedValue([]);
    const listPrisma = {
      accessRequest: { count, findMany },
      $transaction: jest.fn((ops: unknown[]) => Promise.all(ops)),
    };
    const service = new AccessRequestsService(
      listPrisma as never,
      { record: jest.fn() } as never,
      { validateAccessRequest: jest.fn() } as never,
    );

    await service.listRequests(makeAdmin(), { page: 1, pageSize: 20 });

    expect(count).toHaveBeenCalledWith({ where: {} });
  });
});
