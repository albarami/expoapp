import { ErrorCode } from '../common/constants/error-codes';
import { BusinessException } from '../common/exceptions/business.exception';
import { MOCK_FUSION_ID_PREFIX } from './fusion.constants';
import { MockFusionAdapter } from './mock-fusion.adapter';

describe('MockFusionAdapter (BU-06 / FUS-01)', () => {
  const activeUser = {
    externalRef: 'ext-e1001',
    employeeNumber: 'E1001',
    fullNameEn: 'Noura Alharbi',
    fullNameAr: 'نورة الحربي',
    email: 'noura.alharbi@expo.sa',
    isActive: true,
    department: { code: 'OPS' },
    manager: { externalRef: 'ext-m2001' },
  };

  const activeRole = {
    id: 'role-1',
    code: 'FUSION_AP_INQUIRY',
    nameEn: 'AP Inquiry',
    nameAr: null,
    description: 'Inquiry role',
    riskLevel: 'LOW' as const,
    system: { code: 'ORACLE_FUSION_ERP' },
  };

  function createAdapter(overrides?: {
    user?: typeof activeUser | null;
    roles?: Array<typeof activeRole>;
    roleLookup?: typeof activeRole | null;
    requester?: { id: string; isActive: boolean } | null;
  }) {
    const prisma = {
      user: {
        findUnique: jest
          .fn()
          .mockImplementation(
            (args: { where: { externalRef?: string; id?: string } }) => {
              if (args.where.externalRef !== undefined) {
                if (args.where.externalRef === activeUser.externalRef) {
                  return Promise.resolve(
                    overrides && 'user' in overrides
                      ? overrides.user
                      : activeUser,
                  );
                }
                return Promise.resolve(
                  overrides && 'user' in overrides ? overrides.user : null,
                );
              }
              if (overrides?.requester !== undefined) {
                return Promise.resolve(overrides.requester);
              }
              return Promise.resolve(activeUser);
            },
          ),
      },
      securityRoleCatalog: {
        findMany: jest.fn().mockResolvedValue(overrides?.roles ?? [activeRole]),
        findFirst: jest
          .fn()
          .mockResolvedValue(
            overrides && 'roleLookup' in overrides
              ? overrides.roleLookup
              : activeRole,
          ),
      },
    };

    return {
      adapter: new MockFusionAdapter(prisma as never),
      prisma,
    };
  }

  it('returns seeded employee profile', async () => {
    const { adapter } = createAdapter();
    const profile = await adapter.getEmployeeProfile('ext-e1001');

    expect(profile).toEqual({
      externalRef: 'ext-e1001',
      employeeNumber: 'E1001',
      fullNameEn: 'Noura Alharbi',
      fullNameAr: 'نورة الحربي',
      email: 'noura.alharbi@expo.sa',
      departmentCode: 'OPS',
      managerExternalRef: 'ext-m2001',
    });
  });

  it('throws NOT_FOUND for missing employee profile', async () => {
    const { adapter } = createAdapter({ user: null });

    await expect(adapter.getEmployeeProfile('missing')).rejects.toBeInstanceOf(
      BusinessException,
    );
  });

  it('lists available security roles from seed catalog', async () => {
    const { adapter, prisma } = createAdapter();
    const roles = await adapter.listAvailableSecurityRoles({
      systemCode: 'ORACLE_FUSION_ERP',
      search: 'AP',
    });

    expect(prisma.securityRoleCatalog.findMany).toHaveBeenCalled();
    expect(roles).toEqual([
      {
        externalRoleId: 'role-1',
        systemCode: 'ORACLE_FUSION_ERP',
        code: 'FUSION_AP_INQUIRY',
        nameEn: 'AP Inquiry',
        nameAr: undefined,
        description: 'Inquiry role',
        riskLevel: 'LOW',
      },
    ]);
  });

  it('validates access request when role and requester are active', async () => {
    const { adapter } = createAdapter({
      requester: { id: 'u1', isActive: true },
    });

    await expect(
      adapter.validateAccessRequest({
        requesterExternalRef: 'ext-e1001',
        systemCode: 'ORACLE_FUSION_ERP',
        roleCode: 'FUSION_AP_INQUIRY',
      }),
    ).resolves.toEqual({ valid: true });
  });

  it('rejects validation when role is inactive/missing', async () => {
    const { adapter } = createAdapter({ roleLookup: null });

    await expect(
      adapter.validateAccessRequest({
        requesterExternalRef: 'ext-e1001',
        systemCode: 'ORACLE_FUSION_ERP',
        roleCode: 'MISSING',
      }),
    ).resolves.toEqual({
      valid: false,
      code: ErrorCode.ROLE_NOT_REQUESTABLE,
      message: 'Role MISSING is not active for system ORACLE_FUSION_ERP',
    });
  });

  it('provisions with MOCK-FUSION-* id and completed status (FUS-01)', async () => {
    const { adapter } = createAdapter({
      requester: { id: 'u1', isActive: true },
    });

    const result = await adapter.submitAccessProvisioning({
      requestNumber: 'AR-2026-000001',
      requesterExternalRef: 'ext-e1001',
      systemCode: 'ORACLE_FUSION_ERP',
      roleCode: 'FUSION_AP_INQUIRY',
      justification:
        'Need temporary inquiry access for vendor invoice validation.',
      approvedByExternalRefs: ['ext-m2001', 'ext-s3001'],
    });

    expect(result).toEqual({
      externalRequestId: `${MOCK_FUSION_ID_PREFIX}AR-2026-000001`,
      status: 'COMPLETED',
      message: 'Mock Fusion provisioning completed',
    });
  });

  it('returns completed status for mock ids', async () => {
    const { adapter } = createAdapter();
    const status = await adapter.getProvisioningStatus(
      `${MOCK_FUSION_ID_PREFIX}AR-2026-000001`,
    );

    expect(status).toEqual({
      externalRequestId: `${MOCK_FUSION_ID_PREFIX}AR-2026-000001`,
      status: 'COMPLETED',
      message: 'Mock Fusion provisioning completed',
    });
  });
});
