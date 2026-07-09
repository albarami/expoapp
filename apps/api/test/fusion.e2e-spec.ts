import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { PrismaClient, RiskLevel, UserRole } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { NextFunction, Request, Response } from 'express';
import { App } from 'supertest/types';
import { AppModule } from './../src/app.module';
import { GlobalExceptionFilter } from './../src/common/filters/http-exception.filter';
import { ResponseEnvelopeInterceptor } from './../src/common/interceptors/response-envelope.interceptor';
import { TraceIdMiddleware } from './../src/common/middleware/trace-id.middleware';
import { ErrorCode } from './../src/common/constants/error-codes';
import { FusionAdapter } from './../src/fusion/fusion-adapter.interface';
import {
  FUSION_ADAPTER,
  MOCK_FUSION_ID_PREFIX,
} from './../src/fusion/fusion.constants';
import { OracleFusionAdapter } from './../src/fusion/oracle-fusion.adapter';

const databaseUrl = process.env.DATABASE_URL;
const shouldRunDbTests =
  typeof databaseUrl === 'string' &&
  databaseUrl.length > 0 &&
  process.env.PRISMA_SKIP_DB_TESTS !== '1';

const describeDb = shouldRunDbTests ? describe : describe.skip;

const DEMO_PASSWORD = 'Password123!';
const EMPLOYEE_EMAIL = 'noura.alharbi@expo.sa';

describeDb('Fusion adapter (e2e FUS-01)', () => {
  let app: INestApplication<App>;
  let adapter: FusionAdapter;
  const prisma = new PrismaClient();

  beforeAll(async () => {
    const passwordHash = await bcrypt.hash(DEMO_PASSWORD, 10);

    await prisma.department.upsert({
      where: { code: 'OPS' },
      create: { code: 'OPS', nameEn: 'Operations', nameAr: 'العمليات' },
      update: {},
    });
    const department = await prisma.department.findUniqueOrThrow({
      where: { code: 'OPS' },
    });

    await prisma.user.upsert({
      where: { email: EMPLOYEE_EMAIL },
      create: {
        email: EMPLOYEE_EMAIL,
        externalRef: 'ext-e1001',
        employeeNumber: 'E1001',
        fullNameEn: 'Noura Alharbi',
        fullNameAr: 'نورة الحربي',
        role: UserRole.EMPLOYEE,
        departmentId: department.id,
        passwordHash,
        isActive: true,
      },
      update: {
        externalRef: 'ext-e1001',
        employeeNumber: 'E1001',
        passwordHash,
        isActive: true,
        departmentId: department.id,
      },
    });

    await prisma.appSystem.upsert({
      where: { code: 'ORACLE_FUSION_ERP' },
      create: {
        code: 'ORACLE_FUSION_ERP',
        nameEn: 'Oracle Fusion ERP',
        nameAr: 'أوراكل فيوجن',
        isActive: true,
      },
      update: { isActive: true },
    });
    const system = await prisma.appSystem.findUniqueOrThrow({
      where: { code: 'ORACLE_FUSION_ERP' },
    });

    await prisma.securityRoleCatalog.upsert({
      where: {
        systemId_code: {
          systemId: system.id,
          code: 'FUSION_AP_INQUIRY',
        },
      },
      create: {
        systemId: system.id,
        code: 'FUSION_AP_INQUIRY',
        nameEn: 'AP Inquiry',
        riskLevel: RiskLevel.LOW,
        isActive: true,
        requiresManagerApproval: true,
        requiresSecurityApproval: true,
      },
      update: { isActive: true },
    });

    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix('api/v1');
    const traceMiddleware = new TraceIdMiddleware();
    app.use((req: Request, res: Response, next: NextFunction) => {
      traceMiddleware.use(req, res, next);
    });
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
      }),
    );
    app.useGlobalFilters(new GlobalExceptionFilter());
    app.useGlobalInterceptors(new ResponseEnvelopeInterceptor());
    await app.init();

    adapter = app.get<FusionAdapter>(FUSION_ADAPTER);
  });

  afterAll(async () => {
    await app.close();
    await prisma.$disconnect();
  });

  it('resolves mock adapter and provisions with MOCK-FUSION-* id', async () => {
    expect(adapter).toBeDefined();
    expect(adapter).not.toBeInstanceOf(OracleFusionAdapter);

    const profile = await adapter.getEmployeeProfile('ext-e1001');
    expect(profile.email).toBe(EMPLOYEE_EMAIL);

    const roles = await adapter.listAvailableSecurityRoles({
      systemCode: 'ORACLE_FUSION_ERP',
    });
    expect(roles.some((role) => role.code === 'FUSION_AP_INQUIRY')).toBe(true);

    const validation = await adapter.validateAccessRequest({
      requesterExternalRef: 'ext-e1001',
      systemCode: 'ORACLE_FUSION_ERP',
      roleCode: 'FUSION_AP_INQUIRY',
    });
    expect(validation.valid).toBe(true);

    const provisioned = await adapter.submitAccessProvisioning({
      requestNumber: 'AR-2026-000099',
      requesterExternalRef: 'ext-e1001',
      systemCode: 'ORACLE_FUSION_ERP',
      roleCode: 'FUSION_AP_INQUIRY',
      justification:
        'Need temporary inquiry access for vendor invoice validation.',
      approvedByExternalRefs: ['ext-m2001'],
    });

    expect(provisioned.externalRequestId).toBe(
      `${MOCK_FUSION_ID_PREFIX}AR-2026-000099`,
    );
    expect(provisioned.status).toBe('COMPLETED');

    const status = await adapter.getProvisioningStatus(
      provisioned.externalRequestId,
    );
    expect(status.status).toBe('COMPLETED');
  });

  it('oracle scaffold reports FUSION_CONFIGURATION_MISSING without env', async () => {
    const oracle = app.get(OracleFusionAdapter);

    await expect(oracle.getEmployeeProfile('ext-e1001')).rejects.toMatchObject({
      code: ErrorCode.FUSION_CONFIGURATION_MISSING,
    });
  });
});
