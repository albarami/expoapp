import { Test, TestingModule } from '@nestjs/testing';
import {
  AccessDuration,
  AccessUrgency,
  NotificationPriority,
  RiskLevel,
  UserRole,
} from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { ReferenceDataService } from './reference-data.service';

describe('ReferenceDataService', () => {
  let service: ReferenceDataService;

  const departmentFindMany = jest.fn();
  const appSystemFindMany = jest.fn();
  const securityRoleFindMany = jest.fn();

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ReferenceDataService,
        {
          provide: PrismaService,
          useValue: {
            department: { findMany: departmentFindMany },
            appSystem: { findMany: appSystemFindMany },
            securityRoleCatalog: { findMany: securityRoleFindMany },
          },
        },
      ],
    }).compile();

    service = module.get(ReferenceDataService);
  });

  it('returns departments, systems, security roles, and enum catalogs', async () => {
    departmentFindMany.mockResolvedValue([
      {
        id: 'dept-1',
        code: 'OPS',
        nameEn: 'Operations',
        nameAr: 'العمليات',
      },
    ]);
    appSystemFindMany.mockResolvedValue([
      {
        id: 'sys-1',
        code: 'ORACLE_FUSION_ERP',
        nameEn: 'Oracle Fusion ERP',
        nameAr: null,
        description: 'ERP',
        isActive: true,
      },
    ]);
    securityRoleFindMany.mockResolvedValue([
      {
        id: 'role-1',
        systemId: 'sys-1',
        code: 'FUSION_AP_INQUIRY',
        nameEn: 'AP Inquiry',
        nameAr: null,
        description: null,
        riskLevel: RiskLevel.MEDIUM,
        requiresManagerApproval: true,
        requiresSecurityApproval: true,
        isActive: true,
        system: { code: 'ORACLE_FUSION_ERP' },
      },
    ]);

    const result = await service.getReferenceData();

    expect(result.departments).toHaveLength(1);
    expect(result.systems[0]?.code).toBe('ORACLE_FUSION_ERP');
    expect(result.securityRoles[0]).toEqual(
      expect.objectContaining({
        code: 'FUSION_AP_INQUIRY',
        systemCode: 'ORACLE_FUSION_ERP',
        riskLevel: RiskLevel.MEDIUM,
      }),
    );
    expect(result.roles).toEqual(Object.values(UserRole));
    expect(result.notificationPriorities).toEqual(
      Object.values(NotificationPriority),
    );
    expect(result.accessUrgencies).toEqual(Object.values(AccessUrgency));
    expect(result.accessDurations).toEqual(Object.values(AccessDuration));
    expect(securityRoleFindMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { isActive: true },
      }),
    );
  });
});
