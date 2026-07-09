import {
  AccessDuration,
  AccessRequestStage,
  AccessRequestStatus,
  AccessUrgency,
  ApprovalDecision,
  ApprovalStage,
  RiskLevel,
  UserRole,
} from '@prisma/client';
import { AuditActions } from '../audit/audit-actions';
import { AuthUser } from '../auth/types/auth-user';
import { ErrorCode } from '../common/constants/error-codes';
import { BusinessException } from '../common/exceptions/business.exception';
import type { FusionAdapter } from '../fusion/fusion-adapter.interface';
import { ApprovalsService } from './approvals.service';
import { ApprovalDecisionInput, ApprovalEventType } from './approvals.types';

function makeManager(overrides: Partial<AuthUser> = {}): AuthUser {
  return {
    id: 'mgr-1',
    email: 'faisal.otaibi@expo.sa',
    fullNameEn: 'Faisal Otaibi',
    fullNameAr: 'فيصل العتيبي',
    role: UserRole.MANAGER,
    departmentId: 'dept-ops',
    department: {
      id: 'dept-ops',
      code: 'OPS',
      nameEn: 'Operations',
      nameAr: null,
    },
    isActive: true,
    permissions: ['approvals:decide'],
    ...overrides,
  };
}

function makeSecurity(): AuthUser {
  return makeManager({
    id: 'sec-1',
    email: 'reem.security@expo.sa',
    fullNameEn: 'Reem Almutairi',
    fullNameAr: 'ريم المطيري',
    role: UserRole.SECURITY_ADMIN,
  });
}

function baseTask(overrides: Record<string, unknown> = {}) {
  return {
    id: 'task-1',
    accessRequestId: 'ar-1',
    stage: ApprovalStage.MANAGER,
    assigneeId: 'mgr-1',
    decision: ApprovalDecision.PENDING,
    comment: null,
    decidedAt: null,
    createdAt: new Date('2026-07-09T10:00:00.000Z'),
    updatedAt: new Date('2026-07-09T10:00:00.000Z'),
    assignee: {
      id: 'mgr-1',
      fullNameEn: 'Faisal Otaibi',
      fullNameAr: 'فيصل العتيبي',
      email: 'faisal.otaibi@expo.sa',
      externalRef: 'ext-m2001',
    },
    accessRequest: {
      id: 'ar-1',
      requestNumber: 'AR-2026-000010',
      status: AccessRequestStatus.MANAGER_PENDING,
      currentStage: AccessRequestStage.MANAGER,
      businessJustification:
        'Need temporary inquiry access to validate vendor invoice status.',
      urgency: AccessUrgency.NORMAL,
      accessDuration: AccessDuration.TEMPORARY,
      startDate: new Date('2026-07-10T00:00:00.000Z'),
      endDate: new Date('2026-08-10T00:00:00.000Z'),
      submittedAt: new Date('2026-07-09T10:00:00.000Z'),
      system: {
        id: 'sys-1',
        code: 'ORACLE_FUSION_ERP',
        nameEn: 'Oracle Fusion ERP',
        nameAr: null,
      },
      securityRole: {
        id: 'role-1',
        code: 'FUSION_AP_INQUIRY',
        nameEn: 'Accounts Payable Inquiry',
        nameAr: null,
        riskLevel: RiskLevel.MEDIUM,
        requiresManagerApproval: true,
        requiresSecurityApproval: true,
      },
      requester: {
        id: 'emp-1',
        fullNameEn: 'Noura Alharbi',
        fullNameAr: 'نورة الحربي',
        email: 'noura.alharbi@expo.sa',
        externalRef: 'ext-e1001',
      },
    },
    ...overrides,
  };
}

describe('ApprovalsService (BU-04)', () => {
  it('manager approve creates security task when required', async () => {
    const task = baseTask();
    const tx = {
      approvalTask: {
        update: jest.fn().mockResolvedValue({}),
        create: jest.fn().mockResolvedValue({ id: 'task-sec' }),
      },
      accessRequest: {
        update: jest.fn().mockResolvedValue({
          id: 'ar-1',
          requestNumber: 'AR-2026-000010',
          status: AccessRequestStatus.SECURITY_PENDING,
          currentStage: AccessRequestStage.SECURITY,
        }),
      },
      accessRequestEvent: {
        create: jest.fn().mockResolvedValue({ id: 'evt-1' }),
      },
    };

    const prisma = {
      approvalTask: {
        findUnique: jest.fn().mockResolvedValue(task),
      },
      user: {
        findFirst: jest.fn().mockResolvedValue({
          id: 'sec-1',
          fullNameEn: 'Reem Almutairi',
          fullNameAr: 'ريم المطيري',
        }),
      },
      $transaction: jest.fn((fn: (client: typeof tx) => unknown) => fn(tx)),
    };

    const auditService = { record: jest.fn().mockResolvedValue(undefined) };
    const outboxService = {
      enqueueAccessProvisioning: jest.fn(),
      markCompleted: jest.fn(),
      markFailed: jest.fn(),
    };
    const fusionAdapter: Pick<FusionAdapter, 'submitAccessProvisioning'> = {
      submitAccessProvisioning: jest.fn(),
    };
    const configService = {
      get: jest.fn().mockReturnValue('mock'),
    };

    const service = new ApprovalsService(
      prisma as never,
      auditService as never,
      configService as never,
      outboxService as never,
      fusionAdapter as FusionAdapter,
    );

    const result = await service.decide(makeManager(), 'task-1', {
      decision: ApprovalDecisionInput.APPROVED,
    });

    expect(result).toEqual({
      taskId: 'task-1',
      decision: ApprovalDecision.APPROVED,
      request: {
        id: 'ar-1',
        requestNumber: 'AR-2026-000010',
        status: AccessRequestStatus.SECURITY_PENDING,
        currentStage: AccessRequestStage.SECURITY,
      },
    });
    expect(tx.approvalTask.create).toHaveBeenCalledWith({
      data: {
        accessRequestId: 'ar-1',
        stage: ApprovalStage.SECURITY,
        assigneeId: 'sec-1',
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
        ApprovalEventType.ManagerApproved,
        ApprovalEventType.SecurityTaskAssigned,
      ]),
    );
    expect(auditService.record).toHaveBeenCalledWith(
      expect.objectContaining({
        action: AuditActions.ApprovalManagerApproved,
        entityType: 'ApprovalTask',
        entityId: 'task-1',
      }),
    );
    expect(outboxService.enqueueAccessProvisioning).not.toHaveBeenCalled();
  });

  it('manager reject sets MANAGER_REJECTED', async () => {
    const task = baseTask();
    const tx = {
      approvalTask: {
        update: jest.fn().mockResolvedValue({}),
      },
      accessRequest: {
        update: jest.fn().mockResolvedValue({
          id: 'ar-1',
          requestNumber: 'AR-2026-000010',
          status: AccessRequestStatus.MANAGER_REJECTED,
          currentStage: AccessRequestStage.COMPLETE,
        }),
      },
      accessRequestEvent: {
        create: jest.fn().mockResolvedValue({ id: 'evt-1' }),
      },
    };

    const prisma = {
      approvalTask: {
        findUnique: jest.fn().mockResolvedValue(task),
      },
      $transaction: jest.fn((fn: (client: typeof tx) => unknown) => fn(tx)),
    };

    const auditService = { record: jest.fn().mockResolvedValue(undefined) };
    const service = new ApprovalsService(
      prisma as never,
      auditService as never,
      { get: jest.fn() } as never,
      {
        enqueueAccessProvisioning: jest.fn(),
        markCompleted: jest.fn(),
        markFailed: jest.fn(),
      } as never,
      { submitAccessProvisioning: jest.fn() } as never,
    );

    const result = await service.decide(makeManager(), 'task-1', {
      decision: ApprovalDecisionInput.REJECTED,
      comment: 'Business justification is insufficient for this role.',
    });

    expect(result.request.status).toBe(AccessRequestStatus.MANAGER_REJECTED);
    expect(auditService.record).toHaveBeenCalledWith(
      expect.objectContaining({
        action: AuditActions.ApprovalManagerRejected,
      }),
    );
  });

  it('security approve provisions and completes in mock mode', async () => {
    const task = baseTask({
      id: 'task-sec',
      stage: ApprovalStage.SECURITY,
      assigneeId: 'sec-1',
      accessRequest: {
        ...baseTask().accessRequest,
        status: AccessRequestStatus.SECURITY_PENDING,
        currentStage: AccessRequestStage.SECURITY,
      },
      assignee: {
        id: 'sec-1',
        fullNameEn: 'Reem Almutairi',
        fullNameAr: 'ريم المطيري',
        email: 'reem.security@expo.sa',
        externalRef: 'ext-s3001',
      },
    });

    const tx = {
      approvalTask: {
        update: jest.fn().mockResolvedValue({}),
      },
      accessRequest: {
        update: jest.fn().mockResolvedValue({
          id: 'ar-1',
          requestNumber: 'AR-2026-000010',
          status: AccessRequestStatus.PROVISIONING,
          currentStage: AccessRequestStage.PROVISIONING,
        }),
      },
      accessRequestEvent: {
        create: jest.fn().mockResolvedValue({ id: 'evt-1' }),
      },
      integrationOutbox: {
        create: jest.fn().mockResolvedValue({ id: 'outbox-1' }),
      },
    };

    const prisma = {
      approvalTask: {
        findUnique: jest.fn().mockResolvedValue(task),
        findMany: jest.fn().mockResolvedValue([
          {
            assignee: { externalRef: 'ext-m2001' },
          },
        ]),
      },
      accessRequest: {
        update: jest.fn().mockResolvedValue({}),
      },
      $transaction: jest.fn((fn: (client: typeof tx) => unknown) => fn(tx)),
    };

    const auditService = { record: jest.fn().mockResolvedValue(undefined) };
    const outboxService = {
      enqueueAccessProvisioning: jest.fn(),
      markCompleted: jest.fn().mockResolvedValue(undefined),
      markFailed: jest.fn(),
    };
    const fusionAdapter: Pick<FusionAdapter, 'submitAccessProvisioning'> = {
      submitAccessProvisioning: jest.fn().mockResolvedValue({
        externalRequestId: 'MOCK-FUSION-AR-2026-000010',
        status: 'COMPLETED',
        message: 'Mock Fusion provisioning completed',
      }),
    };

    const service = new ApprovalsService(
      prisma as never,
      auditService as never,
      { get: jest.fn().mockReturnValue('mock') } as never,
      outboxService as never,
      fusionAdapter as FusionAdapter,
    );

    const result = await service.decide(makeSecurity(), 'task-sec', {
      decision: ApprovalDecisionInput.APPROVED,
    });

    expect(result.request.status).toBe(AccessRequestStatus.COMPLETED);
    expect(result.request.currentStage).toBe(AccessRequestStage.COMPLETE);
    expect(fusionAdapter.submitAccessProvisioning).toHaveBeenCalled();
    expect(tx.integrationOutbox.create).toHaveBeenCalled();
    expect(outboxService.markCompleted).toHaveBeenCalledWith('outbox-1');
    expect(auditService.record).toHaveBeenCalledWith(
      expect.objectContaining({
        action: AuditActions.ApprovalSecurityApproved,
      }),
    );
    expect(auditService.record).toHaveBeenCalledWith(
      expect.objectContaining({
        action: AuditActions.AccessRequestCompleted,
      }),
    );
  });

  it('security reject sets SECURITY_REJECTED', async () => {
    const task = baseTask({
      id: 'task-sec',
      stage: ApprovalStage.SECURITY,
      assigneeId: 'sec-1',
      accessRequest: {
        ...baseTask().accessRequest,
        status: AccessRequestStatus.SECURITY_PENDING,
        currentStage: AccessRequestStage.SECURITY,
      },
      assignee: {
        id: 'sec-1',
        fullNameEn: 'Reem Almutairi',
        fullNameAr: 'ريم المطيري',
        email: 'reem.security@expo.sa',
        externalRef: 'ext-s3001',
      },
    });

    const tx = {
      approvalTask: {
        update: jest.fn().mockResolvedValue({}),
      },
      accessRequest: {
        update: jest.fn().mockResolvedValue({
          id: 'ar-1',
          requestNumber: 'AR-2026-000010',
          status: AccessRequestStatus.SECURITY_REJECTED,
          currentStage: AccessRequestStage.COMPLETE,
        }),
      },
      accessRequestEvent: {
        create: jest.fn().mockResolvedValue({ id: 'evt-1' }),
      },
    };

    const prisma = {
      approvalTask: {
        findUnique: jest.fn().mockResolvedValue(task),
      },
      $transaction: jest.fn((fn: (client: typeof tx) => unknown) => fn(tx)),
    };

    const auditService = { record: jest.fn().mockResolvedValue(undefined) };
    const service = new ApprovalsService(
      prisma as never,
      auditService as never,
      { get: jest.fn() } as never,
      {
        enqueueAccessProvisioning: jest.fn(),
        markCompleted: jest.fn(),
        markFailed: jest.fn(),
      } as never,
      { submitAccessProvisioning: jest.fn() } as never,
    );

    const result = await service.decide(makeSecurity(), 'task-sec', {
      decision: ApprovalDecisionInput.REJECTED,
      comment: 'Risk level too high for this requester.',
    });

    expect(result.request.status).toBe(AccessRequestStatus.SECURITY_REJECTED);
    expect(auditService.record).toHaveBeenCalledWith(
      expect.objectContaining({
        action: AuditActions.ApprovalSecurityRejected,
      }),
    );
  });

  it('rejects already decided tasks with APPROVAL_TASK_NOT_PENDING', async () => {
    const prisma = {
      approvalTask: {
        findUnique: jest
          .fn()
          .mockResolvedValue(baseTask({ decision: ApprovalDecision.APPROVED })),
      },
    };

    const service = new ApprovalsService(
      prisma as never,
      { record: jest.fn() } as never,
      { get: jest.fn() } as never,
      {
        enqueueAccessProvisioning: jest.fn(),
        markCompleted: jest.fn(),
        markFailed: jest.fn(),
      } as never,
      { submitAccessProvisioning: jest.fn() } as never,
    );

    await expect(
      service.decide(makeManager(), 'task-1', {
        decision: ApprovalDecisionInput.APPROVED,
      }),
    ).rejects.toMatchObject({
      code: ErrorCode.APPROVAL_TASK_NOT_PENDING,
    } satisfies Partial<BusinessException>);
  });

  it('rejects wrong assignee with NOT_TASK_ASSIGNEE', async () => {
    const prisma = {
      approvalTask: {
        findUnique: jest.fn().mockResolvedValue(baseTask()),
      },
    };

    const service = new ApprovalsService(
      prisma as never,
      { record: jest.fn() } as never,
      { get: jest.fn() } as never,
      {
        enqueueAccessProvisioning: jest.fn(),
        markCompleted: jest.fn(),
        markFailed: jest.fn(),
      } as never,
      { submitAccessProvisioning: jest.fn() } as never,
    );

    await expect(
      service.decide(makeSecurity(), 'task-1', {
        decision: ApprovalDecisionInput.APPROVED,
      }),
    ).rejects.toMatchObject({
      code: ErrorCode.NOT_TASK_ASSIGNEE,
    } satisfies Partial<BusinessException>);
  });

  it('manager approve without security requirement provisions immediately', async () => {
    const task = baseTask({
      accessRequest: {
        ...baseTask().accessRequest,
        securityRole: {
          ...baseTask().accessRequest.securityRole,
          code: 'EVENT_OPS_DASHBOARD_VIEWER',
          requiresSecurityApproval: false,
        },
        system: {
          id: 'sys-event',
          code: 'EVENT_OPS',
          nameEn: 'Event Ops',
          nameAr: null,
        },
      },
    });

    const tx = {
      approvalTask: {
        update: jest.fn().mockResolvedValue({}),
      },
      accessRequest: {
        update: jest.fn().mockResolvedValue({
          id: 'ar-1',
          requestNumber: 'AR-2026-000010',
          status: AccessRequestStatus.PROVISIONING,
          currentStage: AccessRequestStage.PROVISIONING,
        }),
      },
      accessRequestEvent: {
        create: jest.fn().mockResolvedValue({ id: 'evt-1' }),
      },
      integrationOutbox: {
        create: jest.fn().mockResolvedValue({ id: 'outbox-2' }),
      },
    };

    const prisma = {
      approvalTask: {
        findUnique: jest.fn().mockResolvedValue(task),
      },
      accessRequest: {
        update: jest.fn().mockResolvedValue({}),
      },
      $transaction: jest.fn((fn: (client: typeof tx) => unknown) => fn(tx)),
    };

    const outboxService = {
      enqueueAccessProvisioning: jest.fn(),
      markCompleted: jest.fn().mockResolvedValue(undefined),
      markFailed: jest.fn(),
    };
    const fusionAdapter: Pick<FusionAdapter, 'submitAccessProvisioning'> = {
      submitAccessProvisioning: jest.fn().mockResolvedValue({
        externalRequestId: 'MOCK-FUSION-AR-2026-000010',
        status: 'COMPLETED',
      }),
    };
    const auditService = { record: jest.fn().mockResolvedValue(undefined) };

    const service = new ApprovalsService(
      prisma as never,
      auditService as never,
      { get: jest.fn().mockReturnValue('mock') } as never,
      outboxService as never,
      fusionAdapter as FusionAdapter,
    );

    const result = await service.decide(makeManager(), 'task-1', {
      decision: ApprovalDecisionInput.APPROVED,
    });

    expect(result.request.status).toBe(AccessRequestStatus.COMPLETED);
    expect(fusionAdapter.submitAccessProvisioning).toHaveBeenCalled();
    expect(tx.integrationOutbox.create).toHaveBeenCalled();
    expect(outboxService.markCompleted).toHaveBeenCalledWith('outbox-2');
  });
});
