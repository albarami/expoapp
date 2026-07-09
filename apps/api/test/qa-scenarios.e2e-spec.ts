import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import {
  AccessDuration,
  AccessRequestStage,
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
import { AuditActions } from './../src/audit/audit-actions';
import { LoginResponseDto } from './../src/auth/dto/auth-response.dto';
import { ErrorCode } from './../src/common/constants/error-codes';
import { GlobalExceptionFilter } from './../src/common/filters/http-exception.filter';
import { ResponseEnvelopeInterceptor } from './../src/common/interceptors/response-envelope.interceptor';
import { TraceIdMiddleware } from './../src/common/middleware/trace-id.middleware';
import {
  ApiErrorResponse,
  ApiSuccessResponse,
} from './../src/common/types/api-response';

/**
 * T-QA-01 — Demo scenarios 1–3 + stakeholder demo chain + RBAC matrix probes.
 * Source: docs/28_TESTING_QA_ACCEPTANCE.md, docs/32_ACCEPTANCE_CRITERIA_DEMO.md
 */

const databaseUrl = process.env.DATABASE_URL;
const shouldRunDbTests =
  typeof databaseUrl === 'string' &&
  databaseUrl.length > 0 &&
  process.env.PRISMA_SKIP_DB_TESTS !== '1';

const describeDb = shouldRunDbTests ? describe : describe.skip;

const DEMO_PASSWORD = 'Password123!';
const EMPLOYEE_EMAIL = 'noura.alharbi@expo.sa';
const OTHER_EMPLOYEE_EMAIL = 'salem.alqahtani@expo.sa';
const MANAGER_EMAIL = 'faisal.otaibi@expo.sa';
const OTHER_MANAGER_EMAIL = 'qa.manager2@expo.sa';
const SECURITY_EMAIL = 'reem.security@expo.sa';
const ADMIN_EMAIL = 'admin@expo.sa';
const API = '/api/v1';

type DecisionResult = {
  taskId: string;
  decision: ApprovalDecision;
  request: {
    id: string;
    requestNumber: string;
    status: AccessRequestStatus;
    currentStage: AccessRequestStage;
    externalFusionRequestId?: string | null;
  };
};

describeDb('T-QA-01 demo scenarios (MAN-01..03 / MAN-05 / RBAC)', () => {
  let app: INestApplication<App>;
  const prisma = new PrismaClient();
  let employeeId = '';
  let managerId = '';
  let otherManagerId = '';
  let securityId = '';
  let systemId = '';
  let roleWithSecurityId = '';

  beforeAll(async () => {
    const passwordHash = await bcrypt.hash(DEMO_PASSWORD, 10);

    for (const code of ['OPS', 'SEC', 'TECH'] as const) {
      await prisma.department.upsert({
        where: { code },
        create: { code, nameEn: code, nameAr: code },
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
        email: OTHER_EMPLOYEE_EMAIL,
        role: UserRole.EMPLOYEE,
        employeeNumber: 'E1002',
        externalRef: 'ext-e1002',
        fullNameEn: 'Salem Alqahtani',
        departmentCode: 'OPS',
      },
      {
        email: MANAGER_EMAIL,
        role: UserRole.MANAGER,
        employeeNumber: 'M2001',
        externalRef: 'ext-m2001',
        fullNameEn: 'Faisal Alotaibi',
        departmentCode: 'OPS',
      },
      {
        email: OTHER_MANAGER_EMAIL,
        role: UserRole.MANAGER,
        employeeNumber: 'M2099',
        externalRef: 'ext-m2099',
        fullNameEn: 'QA Second Manager',
        departmentCode: 'TECH',
      },
      {
        email: SECURITY_EMAIL,
        role: UserRole.SECURITY_ADMIN,
        employeeNumber: 'S3001',
        externalRef: 'ext-s3001',
        fullNameEn: 'Reem Security',
        departmentCode: 'SEC',
      },
      {
        email: ADMIN_EMAIL,
        role: UserRole.SYSTEM_ADMIN,
        employeeNumber: 'A9001',
        externalRef: 'ext-a9001',
        fullNameEn: 'System Admin',
        departmentCode: 'TECH',
      },
    ];

    for (const user of users) {
      await prisma.user.upsert({
        where: { email: user.email },
        create: {
          email: user.email,
          passwordHash,
          role: user.role,
          employeeNumber: user.employeeNumber,
          externalRef: user.externalRef,
          fullNameEn: user.fullNameEn,
          fullNameAr: user.fullNameEn,
          departmentId: departmentIdByCode.get(user.departmentCode)!,
          isActive: true,
        },
        update: {
          passwordHash,
          role: user.role,
          isActive: true,
          departmentId: departmentIdByCode.get(user.departmentCode)!,
        },
      });
    }

    const employee = await prisma.user.findUniqueOrThrow({
      where: { email: EMPLOYEE_EMAIL },
    });
    const manager = await prisma.user.findUniqueOrThrow({
      where: { email: MANAGER_EMAIL },
    });
    const otherManager = await prisma.user.findUniqueOrThrow({
      where: { email: OTHER_MANAGER_EMAIL },
    });
    const security = await prisma.user.findUniqueOrThrow({
      where: { email: SECURITY_EMAIL },
    });

    employeeId = employee.id;
    managerId = manager.id;
    otherManagerId = otherManager.id;
    securityId = security.id;

    await prisma.user.update({
      where: { id: employeeId },
      data: { managerId },
    });
    await prisma.user.update({
      where: { email: OTHER_EMPLOYEE_EMAIL },
      data: { managerId },
    });

    const system = await prisma.appSystem.upsert({
      where: { code: 'ORACLE_FUSION_ERP' },
      create: {
        code: 'ORACLE_FUSION_ERP',
        nameEn: 'Oracle Fusion ERP',
        nameAr: 'أوراكل فيوجن',
        isActive: true,
      },
      update: { isActive: true },
    });
    systemId = system.id;

    const role = await prisma.securityRoleCatalog.upsert({
      where: {
        systemId_code: { systemId, code: 'FUSION_QA_AP_INQUIRY' },
      },
      create: {
        systemId,
        code: 'FUSION_QA_AP_INQUIRY',
        nameEn: 'AP Inquiry',
        nameAr: 'استعلام الموردين',
        riskLevel: RiskLevel.MEDIUM,
        requiresManagerApproval: true,
        requiresSecurityApproval: true,
        isActive: true,
      },
      update: {
        isActive: true,
        requiresManagerApproval: true,
        requiresSecurityApproval: true,
      },
    });
    roleWithSecurityId = role.id;

    const prior = await prisma.accessRequest.findMany({
      where: {
        requesterId: employeeId,
        securityRoleId: roleWithSecurityId,
      },
      select: { id: true },
    });
    const priorIds = prior.map((row) => row.id);
    if (priorIds.length > 0) {
      await prisma.accessRequestEvent.deleteMany({
        where: { accessRequestId: { in: priorIds } },
      });
      await prisma.approvalTask.deleteMany({
        where: { accessRequestId: { in: priorIds } },
      });
      await prisma.auditLog.deleteMany({
        where: {
          entityType: 'AccessRequest',
          entityId: { in: priorIds },
        },
      });
      await prisma.accessRequest.deleteMany({
        where: { id: { in: priorIds } },
      });
    }

    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix('api/v1');
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
        transformOptions: { enableImplicitConversion: true },
      }),
    );
    app.useGlobalFilters(new GlobalExceptionFilter());
    app.useGlobalInterceptors(new ResponseEnvelopeInterceptor());
    const traceMiddleware = new TraceIdMiddleware();
    app.use((req: Request, res: Response, next: NextFunction) => {
      traceMiddleware.use(req, res, next);
    });
    await app.init();
  });

  afterAll(async () => {
    if (app) {
      await app.close();
    }
    await prisma.$disconnect();
  });

  async function login(email: string): Promise<string> {
    const response = await request(app.getHttpServer())
      .post(`${API}/auth/login`)
      .send({ email, password: DEMO_PASSWORD })
      .expect(200);
    const body = response.body as ApiSuccessResponse<LoginResponseDto>;
    return body.data.accessToken;
  }

  async function dashboardUnread(token: string): Promise<number> {
    const response = await request(app.getHttpServer())
      .get(`${API}/dashboard/summary`)
      .set('Authorization', `Bearer ${token}`)
      .expect(200);
    const body = response.body as ApiSuccessResponse<{
      unreadNotifications: number;
    }>;
    return body.data.unreadNotifications;
  }

  async function cleanPriorAccessRequestsForRole(): Promise<void> {
    const prior = await prisma.accessRequest.findMany({
      where: {
        requesterId: employeeId,
        securityRoleId: roleWithSecurityId,
      },
      select: { id: true },
    });
    const priorIds = prior.map((row) => row.id);
    if (priorIds.length === 0) {
      return;
    }
    await prisma.accessRequestEvent.deleteMany({
      where: { accessRequestId: { in: priorIds } },
    });
    await prisma.approvalTask.deleteMany({
      where: { accessRequestId: { in: priorIds } },
    });
    await prisma.auditLog.deleteMany({
      where: {
        entityType: 'AccessRequest',
        entityId: { in: priorIds },
      },
    });
    await prisma.accessRequest.deleteMany({
      where: { id: { in: priorIds } },
    });
  }

  let qaRequestSeq = 0;
  function uniqueRequestNumber(): string {
    qaRequestSeq += 1;
    const n =
      ((Date.now() % 800000) +
        qaRequestSeq * 23 +
        Math.floor(Math.random() * 40)) %
      900000;
    return `AR-2026-${String(100000 + n).slice(0, 6)}`;
  }

  it('MAN-01 Scenario 1: admin notify → employee read → unread decreases + audit', async () => {
    const adminToken = await login(ADMIN_EMAIL);
    const employeeToken = await login(EMPLOYEE_EMAIL);
    const unreadBefore = await dashboardUnread(employeeToken);

    const createResponse = await request(app.getHttpServer())
      .post(`${API}/notifications`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        titleEn: 'MAN-01 stakeholder briefing',
        titleAr: 'إحاطة أصحاب المصلحة',
        bodyEn: 'All users should review the Phase 1 demo notification.',
        bodyAr: 'يجب على جميع المستخدمين مراجعة إشعار العرض التوضيحي.',
        priority: NotificationPriority.HIGH,
        audienceType: AudienceType.ALL,
        audienceFilter: { all: true },
        publishNow: true,
      })
      .expect(201);

    const created = createResponse.body as ApiSuccessResponse<{
      id: string;
      status: NotificationStatus;
      recipientCount: number;
    }>;
    expect(created.data.status).toBe(NotificationStatus.PUBLISHED);
    expect(created.data.recipientCount).toBeGreaterThanOrEqual(1);

    const notificationId = created.data.id;
    const recipient = await prisma.notificationRecipient.findFirst({
      where: { notificationId, userId: employeeId },
    });
    expect(recipient).not.toBeNull();

    const listResponse = await request(app.getHttpServer())
      .get(`${API}/notifications`)
      .query({ unreadOnly: true, search: 'MAN-01' })
      .set('Authorization', `Bearer ${employeeToken}`)
      .expect(200);
    const listBody = listResponse.body as ApiSuccessResponse<
      Array<{ id: string }>
    >;
    expect(listBody.data.some((item) => item.id === notificationId)).toBe(true);

    await request(app.getHttpServer())
      .get(`${API}/notifications/${notificationId}`)
      .set('Authorization', `Bearer ${employeeToken}`)
      .expect(200);

    await request(app.getHttpServer())
      .patch(`${API}/notifications/${notificationId}/read`)
      .set('Authorization', `Bearer ${employeeToken}`)
      .expect(200);

    const updatedRecipient = await prisma.notificationRecipient.findFirst({
      where: { notificationId, userId: employeeId },
    });
    expect(updatedRecipient?.readAt).not.toBeNull();

    const unreadAfter = await dashboardUnread(employeeToken);
    expect(unreadAfter).toBeLessThanOrEqual(unreadBefore);

    const readAudit = await prisma.auditLog.findFirst({
      where: {
        action: AuditActions.NotificationRead,
        entityId: notificationId,
      },
      orderBy: { createdAt: 'desc' },
    });
    expect(readAudit).not.toBeNull();
  });

  it('MAN-02 Scenario 2: request → manager → security → completed + Fusion mock ID', async () => {
    await cleanPriorAccessRequestsForRole();
    const employeeToken = await login(EMPLOYEE_EMAIL);

    const submitResponse = await request(app.getHttpServer())
      .post(`${API}/access-requests`)
      .set('Authorization', `Bearer ${employeeToken}`)
      .send({
        systemId,
        securityRoleId: roleWithSecurityId,
        businessJustification:
          'Need Oracle Fusion AP Inquiry access for vendor invoice validation during close.',
        accessDuration: AccessDuration.TEMPORARY,
        startDate: '2026-07-10T00:00:00.000Z',
        endDate: '2026-08-10T00:00:00.000Z',
        urgency: AccessUrgency.NORMAL,
      })
      .expect(201);

    const submitted = submitResponse.body as ApiSuccessResponse<{
      id: string;
      requestNumber: string;
      status: AccessRequestStatus;
      currentStage: AccessRequestStage;
    }>;
    expect(submitted.data.status).toBe(AccessRequestStatus.MANAGER_PENDING);
    expect(submitted.data.currentStage).toBe(AccessRequestStage.MANAGER);
    expect(submitted.data.requestNumber).toMatch(/^AR-\d{4}-\d{6}$/);

    const managerTask = await prisma.approvalTask.findFirstOrThrow({
      where: {
        accessRequestId: submitted.data.id,
        stage: ApprovalStage.MANAGER,
        decision: ApprovalDecision.PENDING,
      },
    });
    expect(managerTask.assigneeId).toBe(managerId);

    const managerToken = await login(MANAGER_EMAIL);
    await request(app.getHttpServer())
      .post(`${API}/approvals/${managerTask.id}/decision`)
      .set('Authorization', `Bearer ${managerToken}`)
      .send({ decision: 'APPROVED', comment: 'Approved for ops close.' })
      .expect(200);

    const afterManager = await prisma.accessRequest.findUniqueOrThrow({
      where: { id: submitted.data.id },
    });
    expect(afterManager.status).toBe(AccessRequestStatus.SECURITY_PENDING);

    const securityTask = await prisma.approvalTask.findFirstOrThrow({
      where: {
        accessRequestId: submitted.data.id,
        stage: ApprovalStage.SECURITY,
        decision: ApprovalDecision.PENDING,
      },
    });
    expect(securityTask.assigneeId).toBe(securityId);

    const securityToken = await login(SECURITY_EMAIL);
    const securityDecision = await request(app.getHttpServer())
      .post(`${API}/approvals/${securityTask.id}/decision`)
      .set('Authorization', `Bearer ${securityToken}`)
      .send({ decision: 'APPROVED', comment: 'Security cleared.' })
      .expect(200);

    const completed =
      securityDecision.body as ApiSuccessResponse<DecisionResult>;
    expect(completed.data.request.status).toBe(AccessRequestStatus.COMPLETED);

    const finalRequest = await prisma.accessRequest.findUniqueOrThrow({
      where: { id: submitted.data.id },
    });
    expect(finalRequest.externalFusionRequestId).toMatch(/^MOCK-FUSION-/);
    expect(finalRequest.completedAt).not.toBeNull();

    const submitAudit = await prisma.auditLog.findFirst({
      where: {
        action: AuditActions.AccessRequestSubmitted,
        entityId: submitted.data.id,
      },
    });
    const managerAudit = await prisma.auditLog.findFirst({
      where: {
        action: AuditActions.ApprovalManagerApproved,
        entityId: managerTask.id,
      },
    });
    const securityAudit = await prisma.auditLog.findFirst({
      where: {
        action: AuditActions.ApprovalSecurityApproved,
        entityId: securityTask.id,
      },
    });
    const completedAudit = await prisma.auditLog.findFirst({
      where: {
        action: AuditActions.AccessRequestCompleted,
        entityId: submitted.data.id,
      },
    });
    expect(submitAudit).not.toBeNull();
    expect(managerAudit).not.toBeNull();
    expect(securityAudit).not.toBeNull();
    expect(completedAudit).not.toBeNull();

    const adminToken = await login(ADMIN_EMAIL);
    await request(app.getHttpServer())
      .get(`${API}/audit-logs`)
      .query({ page: 1, pageSize: 20 })
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(200);
  });

  it('MAN-03 Scenario 3: employee blocked from audit UI path + API 403', async () => {
    const employeeToken = await login(EMPLOYEE_EMAIL);

    const auditForbidden = await request(app.getHttpServer())
      .get(`${API}/audit-logs`)
      .set('Authorization', `Bearer ${employeeToken}`)
      .expect(403);
    expect((auditForbidden.body as ApiErrorResponse).error.code).toBe(
      'FORBIDDEN',
    );

    const approvalsForbidden = await request(app.getHttpServer())
      .get(`${API}/approvals`)
      .set('Authorization', `Bearer ${employeeToken}`)
      .expect(403);
    expect((approvalsForbidden.body as ApiErrorResponse).error.code).toBe(
      'FORBIDDEN',
    );

    const createForbidden = await request(app.getHttpServer())
      .post(`${API}/notifications`)
      .set('Authorization', `Bearer ${employeeToken}`)
      .send({
        titleEn: 'Should fail',
        bodyEn: 'Employees cannot create notifications.',
        priority: NotificationPriority.NORMAL,
        audienceType: AudienceType.ALL,
        audienceFilter: { all: true },
        publishNow: true,
      })
      .expect(403);
    expect((createForbidden.body as ApiErrorResponse).error.code).toBe(
      'FORBIDDEN',
    );
  });

  it('MAN-05 demo script chain: notify + access workflow + governance audit', async () => {
    const adminToken = await login(ADMIN_EMAIL);

    const notify = await request(app.getHttpServer())
      .post(`${API}/notifications`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        titleEn: 'MAN-05 demo broadcast',
        bodyEn: 'Stakeholder demo notification for Operations audience.',
        priority: NotificationPriority.NORMAL,
        audienceType: AudienceType.DEPARTMENT,
        audienceFilter: { departmentCodes: ['OPS'] },
        publishNow: true,
      })
      .expect(201);

    const notificationId = (notify.body as ApiSuccessResponse<{ id: string }>)
      .data.id;

    const stats = await request(app.getHttpServer())
      .get(`${API}/notifications/${notificationId}/stats`)
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(200);
    expect(
      (stats.body as ApiSuccessResponse<{ recipientCount: number }>).data
        .recipientCount,
    ).toBeGreaterThanOrEqual(1);

    const employeeToken = await login(EMPLOYEE_EMAIL);
    await request(app.getHttpServer())
      .patch(`${API}/notifications/${notificationId}/read`)
      .set('Authorization', `Bearer ${employeeToken}`)
      .expect(200);

    await cleanPriorAccessRequestsForRole();
    const submit = await request(app.getHttpServer())
      .post(`${API}/access-requests`)
      .set('Authorization', `Bearer ${employeeToken}`)
      .send({
        systemId,
        securityRoleId: roleWithSecurityId,
        businessJustification:
          'Stakeholder demo access request for Oracle Fusion AP Inquiry role.',
        accessDuration: AccessDuration.PERMANENT,
        startDate: '2026-07-10T00:00:00.000Z',
        urgency: AccessUrgency.URGENT,
      })
      .expect(201);

    const requestId = (submit.body as ApiSuccessResponse<{ id: string }>).data
      .id;

    const managerTask = await prisma.approvalTask.findFirstOrThrow({
      where: {
        accessRequestId: requestId,
        stage: ApprovalStage.MANAGER,
        decision: ApprovalDecision.PENDING,
      },
    });

    const managerToken = await login(MANAGER_EMAIL);
    await request(app.getHttpServer())
      .post(`${API}/approvals/${managerTask.id}/decision`)
      .set('Authorization', `Bearer ${managerToken}`)
      .send({ decision: 'APPROVED' })
      .expect(200);

    const securityTask = await prisma.approvalTask.findFirstOrThrow({
      where: {
        accessRequestId: requestId,
        stage: ApprovalStage.SECURITY,
        decision: ApprovalDecision.PENDING,
      },
    });

    const securityToken = await login(SECURITY_EMAIL);
    await request(app.getHttpServer())
      .post(`${API}/approvals/${securityTask.id}/decision`)
      .set('Authorization', `Bearer ${securityToken}`)
      .send({ decision: 'APPROVED' })
      .expect(200);

    const completed = await prisma.accessRequest.findUniqueOrThrow({
      where: { id: requestId },
    });
    expect(completed.status).toBe(AccessRequestStatus.COMPLETED);
    expect(completed.externalFusionRequestId).toMatch(/^MOCK-FUSION-/);

    const audit = await request(app.getHttpServer())
      .get(`${API}/audit-logs`)
      .query({ page: 1, pageSize: 20 })
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(200);
    expect(
      (audit.body as ApiSuccessResponse<unknown[]>).data.length,
    ).toBeGreaterThan(0);
  });

  it('RBAC-01 permission matrix probes for key endpoints', async () => {
    const employeeToken = await login(EMPLOYEE_EMAIL);
    const managerToken = await login(MANAGER_EMAIL);
    const securityToken = await login(SECURITY_EMAIL);
    const adminToken = await login(ADMIN_EMAIL);

    await request(app.getHttpServer())
      .get(`${API}/dashboard/summary`)
      .set('Authorization', `Bearer ${employeeToken}`)
      .expect(200);
    await request(app.getHttpServer())
      .get(`${API}/notifications`)
      .set('Authorization', `Bearer ${employeeToken}`)
      .expect(200);

    await request(app.getHttpServer())
      .post(`${API}/notifications`)
      .set('Authorization', `Bearer ${managerToken}`)
      .send({
        titleEn: 'Manager cannot create',
        bodyEn: 'Managers must not create notifications.',
        priority: NotificationPriority.LOW,
        audienceType: AudienceType.ALL,
        audienceFilter: { all: true },
        publishNow: true,
      })
      .expect(403);

    await request(app.getHttpServer())
      .get(`${API}/approvals`)
      .set('Authorization', `Bearer ${managerToken}`)
      .expect(200);
    await request(app.getHttpServer())
      .get(`${API}/approvals`)
      .set('Authorization', `Bearer ${securityToken}`)
      .expect(200);
    await request(app.getHttpServer())
      .get(`${API}/approvals`)
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(200);

    await request(app.getHttpServer())
      .get(`${API}/audit-logs`)
      .set('Authorization', `Bearer ${managerToken}`)
      .expect(403);
    await request(app.getHttpServer())
      .get(`${API}/audit-logs`)
      .set('Authorization', `Bearer ${securityToken}`)
      .expect(200);
    await request(app.getHttpServer())
      .get(`${API}/audit-logs`)
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(200);

    await request(app.getHttpServer())
      .post(`${API}/notifications`)
      .set('Authorization', `Bearer ${securityToken}`)
      .send({
        titleEn: 'Security optional create',
        bodyEn: 'Security admin may create notifications when allowed.',
        priority: NotificationPriority.LOW,
        audienceType: AudienceType.USERS,
        audienceFilter: { userIds: [securityId] },
        publishNow: true,
      })
      .expect(201);
  });

  it('RBAC-03 manager cannot decide a task assigned to another manager', async () => {
    const accessRequest = await prisma.accessRequest.create({
      data: {
        requestNumber: uniqueRequestNumber(),
        requesterId: employeeId,
        systemId,
        securityRoleId: roleWithSecurityId,
        businessJustification:
          'Fixture for non-assignee manager decision rejection coverage.',
        accessDuration: AccessDuration.PERMANENT,
        startDate: new Date('2026-07-10T00:00:00.000Z'),
        urgency: AccessUrgency.NORMAL,
        status: AccessRequestStatus.MANAGER_PENDING,
        currentStage: AccessRequestStage.MANAGER,
        submittedAt: new Date(),
      },
    });

    const task = await prisma.approvalTask.create({
      data: {
        accessRequestId: accessRequest.id,
        stage: ApprovalStage.MANAGER,
        assigneeId: managerId,
        decision: ApprovalDecision.PENDING,
      },
    });

    const otherManagerToken = await login(OTHER_MANAGER_EMAIL);
    const forbidden = await request(app.getHttpServer())
      .post(`${API}/approvals/${task.id}/decision`)
      .set('Authorization', `Bearer ${otherManagerToken}`)
      .send({ decision: 'APPROVED', comment: 'Wrong manager.' })
      .expect(403);

    expect((forbidden.body as ApiErrorResponse).error.code).toBe(
      ErrorCode.NOT_TASK_ASSIGNEE,
    );
    expect(otherManagerId).not.toBe(managerId);
  });
});
