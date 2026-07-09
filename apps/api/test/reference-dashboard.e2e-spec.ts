import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import {
  AccessDuration,
  AccessRequestStatus,
  AccessUrgency,
  ApprovalDecision,
  ApprovalStage,
  AudienceType,
  NotificationPriority,
  NotificationStatus,
  PrismaClient,
  RiskLevel,
  UserRole,
} from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { NextFunction, Request, Response } from 'express';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from './../src/app.module';
import { GlobalExceptionFilter } from './../src/common/filters/http-exception.filter';
import { ResponseEnvelopeInterceptor } from './../src/common/interceptors/response-envelope.interceptor';
import { TraceIdMiddleware } from './../src/common/middleware/trace-id.middleware';
import {
  ApiErrorResponse,
  ApiSuccessResponse,
} from './../src/common/types/api-response';
import { LoginResponseDto } from './../src/auth/dto/auth-response.dto';
import { DashboardSummaryResponse } from './../src/dashboard/dashboard.types';
import { ReferenceDataResponse } from './../src/reference-data/reference-data.types';

const databaseUrl = process.env.DATABASE_URL;
const shouldRunDbTests =
  typeof databaseUrl === 'string' &&
  databaseUrl.length > 0 &&
  process.env.PRISMA_SKIP_DB_TESTS !== '1';

const describeDb = shouldRunDbTests ? describe : describe.skip;

const DEMO_PASSWORD = 'Password123!';
const EMPLOYEE_EMAIL = 'noura.alharbi@expo.sa';
const MANAGER_EMAIL = 'faisal.otaibi@expo.sa';
const SECURITY_EMAIL = 'reem.security@expo.sa';
const ADMIN_EMAIL = 'admin@expo.sa';

describeDb('Reference data + dashboard (e2e T-API-05)', () => {
  let app: INestApplication<App>;
  const prisma = new PrismaClient();

  beforeAll(async () => {
    const passwordHash = await bcrypt.hash(DEMO_PASSWORD, 10);

    for (const code of ['OPS', 'SEC', 'TECH'] as const) {
      await prisma.department.upsert({
        where: { code },
        create: {
          code,
          nameEn: code,
          nameAr: code,
        },
        update: {},
      });
    }

    const departments = await prisma.department.findMany({
      where: { code: { in: ['OPS', 'SEC', 'TECH'] } },
    });
    const departmentIdByCode = new Map(
      departments.map((department) => [department.code, department.id]),
    );

    const users: Array<{
      email: string;
      role: UserRole;
      employeeNumber: string;
      externalRef: string;
      fullNameEn: string;
      departmentCode: string;
    }> = [
      {
        email: EMPLOYEE_EMAIL,
        role: UserRole.EMPLOYEE,
        employeeNumber: 'E1001',
        externalRef: 'ext-e1001',
        fullNameEn: 'Noura Alharbi',
        departmentCode: 'OPS',
      },
      {
        email: MANAGER_EMAIL,
        role: UserRole.MANAGER,
        employeeNumber: 'M2001',
        externalRef: 'ext-m2001',
        fullNameEn: 'Faisal Otaibi',
        departmentCode: 'OPS',
      },
      {
        email: SECURITY_EMAIL,
        role: UserRole.SECURITY_ADMIN,
        employeeNumber: 'S3001',
        externalRef: 'ext-s3001',
        fullNameEn: 'Reem Almutairi',
        departmentCode: 'SEC',
      },
      {
        email: ADMIN_EMAIL,
        role: UserRole.SYSTEM_ADMIN,
        employeeNumber: 'A9001',
        externalRef: 'ext-a9001',
        fullNameEn: 'Expo System Admin',
        departmentCode: 'TECH',
      },
    ];

    for (const user of users) {
      const departmentId = departmentIdByCode.get(user.departmentCode);
      if (!departmentId) {
        throw new Error(`Missing department ${user.departmentCode}`);
      }
      await prisma.user.upsert({
        where: { email: user.email },
        create: {
          email: user.email,
          externalRef: user.externalRef,
          employeeNumber: user.employeeNumber,
          fullNameEn: user.fullNameEn,
          fullNameAr: user.fullNameEn,
          role: user.role,
          departmentId,
          passwordHash,
          isActive: true,
        },
        update: {
          passwordHash,
          role: user.role,
          isActive: true,
          departmentId,
        },
      });
    }

    const employee = await prisma.user.findUniqueOrThrow({
      where: { email: EMPLOYEE_EMAIL },
    });
    const manager = await prisma.user.findUniqueOrThrow({
      where: { email: MANAGER_EMAIL },
    });
    const admin = await prisma.user.findUniqueOrThrow({
      where: { email: ADMIN_EMAIL },
    });

    await prisma.user.update({
      where: { id: employee.id },
      data: { managerId: manager.id },
    });

    const system = await prisma.appSystem.upsert({
      where: { code: 'ORACLE_FUSION_ERP' },
      create: {
        code: 'ORACLE_FUSION_ERP',
        nameEn: 'Oracle Fusion ERP',
        nameAr: 'أوراكل فيوجن ERP',
        description: 'ERP',
        isActive: true,
      },
      update: { isActive: true },
    });

    const securityRole = await prisma.securityRoleCatalog.upsert({
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
        nameAr: 'استعلام المدفوعات',
        riskLevel: RiskLevel.HIGH,
        requiresManagerApproval: true,
        requiresSecurityApproval: true,
        isActive: true,
      },
      update: {
        riskLevel: RiskLevel.HIGH,
        isActive: true,
      },
    });

    const notification = await prisma.notification.findFirst({
      where: {
        createdById: admin.id,
        titleEn: 'T-API-05 dashboard notification',
      },
    });
    const notificationRow =
      notification ??
      (await prisma.notification.create({
        data: {
          titleEn: 'T-API-05 dashboard notification',
          titleAr: 'إشعار لوحة التحكم',
          bodyEn: 'Dashboard e2e fixture',
          bodyAr: 'بيانات اختبار',
          priority: NotificationPriority.HIGH,
          status: NotificationStatus.PUBLISHED,
          audienceType: AudienceType.USERS,
          audienceFilter: { userIds: [employee.id] },
          createdById: admin.id,
          publishAt: new Date(),
        },
      }));

    await prisma.notificationRecipient.upsert({
      where: {
        notificationId_userId: {
          notificationId: notificationRow.id,
          userId: employee.id,
        },
      },
      create: {
        notificationId: notificationRow.id,
        userId: employee.id,
        deliveredAt: new Date(),
        readAt: null,
      },
      update: {
        readAt: null,
      },
    });

    const dashboardRequestNumber = `AR-2026-${String(
      700000 + (Date.now() % 99999),
    ).slice(0, 6)}`;
    const existingRequest = await prisma.accessRequest.findFirst({
      where: { requestNumber: dashboardRequestNumber },
    });
    const accessRequest =
      existingRequest ??
      (await prisma.accessRequest.create({
        data: {
          requestNumber: dashboardRequestNumber,
          requesterId: employee.id,
          systemId: system.id,
          securityRoleId: securityRole.id,
          businessJustification:
            'T-API-05 e2e fixture justification for dashboard open request.',
          accessDuration: AccessDuration.TEMPORARY,
          urgency: AccessUrgency.NORMAL,
          status: AccessRequestStatus.MANAGER_PENDING,
          currentStage: 'MANAGER',
          submittedAt: new Date(),
          startDate: new Date(),
          endDate: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
        },
      }));

    const existingTask = await prisma.approvalTask.findFirst({
      where: {
        accessRequestId: accessRequest.id,
        assigneeId: manager.id,
        stage: ApprovalStage.MANAGER,
      },
    });
    if (!existingTask) {
      await prisma.approvalTask.create({
        data: {
          accessRequestId: accessRequest.id,
          assigneeId: manager.id,
          stage: ApprovalStage.MANAGER,
          decision: ApprovalDecision.PENDING,
        },
      });
    }

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
  });

  afterAll(async () => {
    await app.close();
    await prisma.$disconnect();
  });

  async function login(
    email: string,
  ): Promise<ApiSuccessResponse<LoginResponseDto>> {
    const response = await request(app.getHttpServer())
      .post('/api/v1/auth/login')
      .send({ email, password: DEMO_PASSWORD })
      .expect(200);

    return response.body as ApiSuccessResponse<LoginResponseDto>;
  }

  it('rejects unauthenticated reference-data and dashboard calls with 401', async () => {
    const referenceResponse = await request(app.getHttpServer())
      .get('/api/v1/reference-data')
      .expect(401);
    expect((referenceResponse.body as ApiErrorResponse).error.code).toBe(
      'UNAUTHORIZED',
    );

    const dashboardResponse = await request(app.getHttpServer())
      .get('/api/v1/dashboard/summary')
      .expect(401);
    expect((dashboardResponse.body as ApiErrorResponse).error.code).toBe(
      'UNAUTHORIZED',
    );
  });

  it('returns complete reference-data payload', async () => {
    const loginBody = await login(EMPLOYEE_EMAIL);

    const response = await request(app.getHttpServer())
      .get('/api/v1/reference-data')
      .set('Authorization', `Bearer ${loginBody.data.accessToken}`)
      .expect(200);

    const body = response.body as ApiSuccessResponse<ReferenceDataResponse>;
    expect(body.data.departments.length).toBeGreaterThan(0);
    expect(body.data.systems.some((s) => s.code === 'ORACLE_FUSION_ERP')).toBe(
      true,
    );
    expect(
      body.data.securityRoles.some((r) => r.code === 'FUSION_AP_INQUIRY'),
    ).toBe(true);
    expect(body.data.roles).toEqual(
      expect.arrayContaining(Object.values(UserRole)),
    );
    expect(body.data.notificationPriorities).toEqual(
      Object.values(NotificationPriority),
    );
    expect(body.data.accessUrgencies).toEqual(Object.values(AccessUrgency));
    expect(body.data.accessDurations).toEqual(Object.values(AccessDuration));
  });

  it('returns employee dashboard summary counters', async () => {
    const loginBody = await login(EMPLOYEE_EMAIL);

    const response = await request(app.getHttpServer())
      .get('/api/v1/dashboard/summary')
      .set('Authorization', `Bearer ${loginBody.data.accessToken}`)
      .expect(200);

    const body = response.body as ApiSuccessResponse<DashboardSummaryResponse>;
    expect(body.data.role).toBe(UserRole.EMPLOYEE);
    expect(body.data.unreadNotifications).toBeGreaterThanOrEqual(1);
    expect(body.data.openAccessRequests).toBeGreaterThanOrEqual(1);
    expect(body.data.pendingApprovals).toBe(0);
    expect(Array.isArray(body.data.latestNotifications)).toBe(true);
    expect(Array.isArray(body.data.latestRequests)).toBe(true);
    expect(body.data.notificationStats).toBeUndefined();
  });

  it('returns manager dashboard with pending approvals and team summary', async () => {
    const loginBody = await login(MANAGER_EMAIL);

    const response = await request(app.getHttpServer())
      .get('/api/v1/dashboard/summary')
      .set('Authorization', `Bearer ${loginBody.data.accessToken}`)
      .expect(200);

    const body = response.body as ApiSuccessResponse<DashboardSummaryResponse>;
    expect(body.data.role).toBe(UserRole.MANAGER);
    expect(body.data.pendingApprovals).toBeGreaterThanOrEqual(1);
    expect(body.data.teamOpenRequests).toBeGreaterThanOrEqual(1);
  });

  it('returns security admin dashboard with security widgets', async () => {
    const loginBody = await login(SECURITY_EMAIL);

    const response = await request(app.getHttpServer())
      .get('/api/v1/dashboard/summary')
      .set('Authorization', `Bearer ${loginBody.data.accessToken}`)
      .expect(200);

    const body = response.body as ApiSuccessResponse<DashboardSummaryResponse>;
    expect(body.data.role).toBe(UserRole.SECURITY_ADMIN);
    expect(typeof body.data.pendingSecurityApprovals).toBe('number');
    expect(typeof body.data.highRiskOpenRequests).toBe('number');
    expect(Array.isArray(body.data.recentAuditEvents)).toBe(true);
  });

  it('returns system admin dashboard with notification and workflow stats', async () => {
    const loginBody = await login(ADMIN_EMAIL);

    const response = await request(app.getHttpServer())
      .get('/api/v1/dashboard/summary')
      .set('Authorization', `Bearer ${loginBody.data.accessToken}`)
      .expect(200);

    const body = response.body as ApiSuccessResponse<DashboardSummaryResponse>;
    expect(body.data.role).toBe(UserRole.SYSTEM_ADMIN);
    expect(body.data.notificationStats).toBeDefined();
    const notificationStats = body.data.notificationStats;
    expect(Number.isFinite(notificationStats.publishedCount)).toBe(true);
    expect(Number.isFinite(notificationStats.recipientCount)).toBe(true);
    expect(Number.isFinite(notificationStats.readCount)).toBe(true);
    expect(Number.isFinite(notificationStats.readPercentage)).toBe(true);
    expect(body.data.accessWorkflowStats).toBeDefined();
    const accessWorkflowStats = body.data.accessWorkflowStats;
    expect(Number.isFinite(accessWorkflowStats.openAccessRequests)).toBe(true);
    expect(Number.isFinite(accessWorkflowStats.pendingManagerApprovals)).toBe(
      true,
    );
    expect(Number.isFinite(accessWorkflowStats.pendingSecurityApprovals)).toBe(
      true,
    );
    expect(Number.isFinite(accessWorkflowStats.completedRequests)).toBe(true);
    expect(Array.isArray(body.data.recentAuditEvents)).toBe(true);
  });
});
