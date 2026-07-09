import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import {
  AccessDuration,
  AccessRequestStage,
  AccessRequestStatus,
  AccessUrgency,
  ApprovalDecision,
  ApprovalStage,
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
  };
};

type ApprovalListItem = {
  id: string;
  stage: ApprovalStage;
  decision: ApprovalDecision;
  accessRequest: {
    id: string;
    requestNumber: string;
    status: AccessRequestStatus;
  };
};

describeDb('Approvals module (e2e BI-06 / BU-04)', () => {
  let app: INestApplication<App>;
  const prisma = new PrismaClient();
  let employeeId = '';
  let otherEmployeeId = '';
  let managerId = '';
  let securityId = '';
  let systemId = '';
  let roleWithSecurityId = '';
  let roleManagerOnlyId = '';

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
      const row = await prisma.user.upsert({
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
          fullNameEn: user.fullNameEn,
          externalRef: user.externalRef,
        },
      });
      if (user.email === EMPLOYEE_EMAIL) {
        employeeId = row.id;
      }
      if (user.email === OTHER_EMPLOYEE_EMAIL) {
        otherEmployeeId = row.id;
      }
      if (user.email === MANAGER_EMAIL) {
        managerId = row.id;
      }
      if (user.email === SECURITY_EMAIL) {
        securityId = row.id;
      }
    }

    await prisma.user.update({
      where: { id: employeeId },
      data: { managerId },
    });
    await prisma.user.update({
      where: { id: otherEmployeeId },
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

    const eventSystem = await prisma.appSystem.upsert({
      where: { code: 'EVENT_OPS' },
      create: {
        code: 'EVENT_OPS',
        nameEn: 'Event Operations',
        nameAr: 'عمليات الفعاليات',
        isActive: true,
      },
      update: { isActive: true },
    });

    const roleWithSecurity = await prisma.securityRoleCatalog.upsert({
      where: {
        systemId_code: {
          systemId,
          code: 'FUSION_AP_INQUIRY',
        },
      },
      create: {
        systemId,
        code: 'FUSION_AP_INQUIRY',
        nameEn: 'AP Inquiry',
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
    roleWithSecurityId = roleWithSecurity.id;

    const roleManagerOnly = await prisma.securityRoleCatalog.upsert({
      where: {
        systemId_code: {
          systemId: eventSystem.id,
          code: 'EVENT_OPS_DASHBOARD_VIEWER',
        },
      },
      create: {
        systemId: eventSystem.id,
        code: 'EVENT_OPS_DASHBOARD_VIEWER',
        nameEn: 'Dashboard Viewer',
        riskLevel: RiskLevel.LOW,
        requiresManagerApproval: true,
        requiresSecurityApproval: false,
        isActive: true,
      },
      update: {
        isActive: true,
        requiresManagerApproval: true,
        requiresSecurityApproval: false,
      },
    });
    roleManagerOnlyId = roleManagerOnly.id;

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

  let requestNumberSeq = 0;

  function uniqueRequestNumber(): string {
    requestNumberSeq += 1;
    const n =
      ((Date.now() % 800000) +
        requestNumberSeq * 17 +
        Math.floor(Math.random() * 50)) %
      900000;
    return `AR-2026-${String(100000 + n).slice(0, 6)}`;
  }

  async function createPendingManagerRequest(params: {
    requesterId: string;
    securityRoleId: string;
    systemIdForRole: string;
    requestNumber?: string;
  }): Promise<{ requestId: string; taskId: string }> {
    const requestNumber = params.requestNumber ?? uniqueRequestNumber();

    const existing = await prisma.accessRequest.findUnique({
      where: { requestNumber },
      select: { id: true },
    });
    if (existing) {
      const priorTasks = await prisma.approvalTask.findMany({
        where: { accessRequestId: existing.id },
        select: { id: true },
      });
      const priorTaskIds = priorTasks.map((task) => task.id);

      await prisma.accessRequestEvent.deleteMany({
        where: { accessRequestId: existing.id },
      });
      await prisma.approvalTask.deleteMany({
        where: { accessRequestId: existing.id },
      });
      await prisma.auditLog.deleteMany({
        where: {
          OR: [
            { entityType: 'AccessRequest', entityId: existing.id },
            ...(priorTaskIds.length > 0
              ? [{ entityType: 'ApprovalTask', entityId: { in: priorTaskIds } }]
              : []),
          ],
        },
      });
      await prisma.accessRequest.delete({ where: { id: existing.id } });
    }

    const accessRequest = await prisma.accessRequest.create({
      data: {
        requestNumber,
        requesterId: params.requesterId,
        systemId: params.systemIdForRole,
        securityRoleId: params.securityRoleId,
        businessJustification:
          'Need temporary inquiry access to validate vendor invoice status for ops.',
        accessDuration: AccessDuration.TEMPORARY,
        startDate: new Date('2026-07-10T00:00:00.000Z'),
        endDate: new Date('2026-08-10T00:00:00.000Z'),
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

    return { requestId: accessRequest.id, taskId: task.id };
  }

  it('lists pending approvals for the assigned manager', async () => {
    const { taskId } = await createPendingManagerRequest({
      requesterId: employeeId,
      securityRoleId: roleWithSecurityId,
      systemIdForRole: systemId,
    });

    const managerToken = await login(MANAGER_EMAIL);
    const response = await request(app.getHttpServer())
      .get(`${API}/approvals`)
      .query({ status: ApprovalDecision.PENDING })
      .set('Authorization', `Bearer ${managerToken}`)
      .expect(200);

    const body = response.body as ApiSuccessResponse<ApprovalListItem[]> & {
      pagination: { total: number };
    };
    expect(body.data.some((item) => item.id === taskId)).toBe(true);

    const employeeToken = await login(EMPLOYEE_EMAIL);
    await request(app.getHttpServer())
      .get(`${API}/approvals`)
      .set('Authorization', `Bearer ${employeeToken}`)
      .expect(403);
  });

  it('manager approve creates security task; wrong assignee gets 403', async () => {
    const { requestId, taskId } = await createPendingManagerRequest({
      requesterId: employeeId,
      securityRoleId: roleWithSecurityId,
      systemIdForRole: systemId,
    });

    const securityToken = await login(SECURITY_EMAIL);
    const forbidden = await request(app.getHttpServer())
      .post(`${API}/approvals/${taskId}/decision`)
      .set('Authorization', `Bearer ${securityToken}`)
      .send({ decision: 'APPROVED' })
      .expect(403);

    const forbiddenBody = forbidden.body as ApiErrorResponse;
    expect(forbiddenBody.error.code).toBe(ErrorCode.NOT_TASK_ASSIGNEE);

    const managerToken = await login(MANAGER_EMAIL);
    const response = await request(app.getHttpServer())
      .post(`${API}/approvals/${taskId}/decision`)
      .set('Authorization', `Bearer ${managerToken}`)
      .send({ decision: 'APPROVED', comment: 'Approved for operational need.' })
      .expect(200);

    const body = response.body as ApiSuccessResponse<DecisionResult>;
    expect(body.data.decision).toBe(ApprovalDecision.APPROVED);
    expect(body.data.request.status).toBe(AccessRequestStatus.SECURITY_PENDING);
    expect(body.data.request.currentStage).toBe(AccessRequestStage.SECURITY);

    const securityTask = await prisma.approvalTask.findFirst({
      where: {
        accessRequestId: requestId,
        stage: ApprovalStage.SECURITY,
        decision: ApprovalDecision.PENDING,
      },
    });
    expect(securityTask).not.toBeNull();
    expect(securityTask?.assigneeId).toBe(securityId);

    const audit = await prisma.auditLog.findFirst({
      where: {
        action: AuditActions.ApprovalManagerApproved,
        entityId: taskId,
      },
      orderBy: { createdAt: 'desc' },
    });
    expect(audit).not.toBeNull();
  });

  it('security approve completes request in mock mode with outbox', async () => {
    const { requestId, taskId } = await createPendingManagerRequest({
      requesterId: employeeId,
      securityRoleId: roleWithSecurityId,
      systemIdForRole: systemId,
    });

    const managerToken = await login(MANAGER_EMAIL);
    await request(app.getHttpServer())
      .post(`${API}/approvals/${taskId}/decision`)
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
    const response = await request(app.getHttpServer())
      .post(`${API}/approvals/${securityTask.id}/decision`)
      .set('Authorization', `Bearer ${securityToken}`)
      .send({ decision: 'APPROVED' })
      .expect(200);

    const body = response.body as ApiSuccessResponse<DecisionResult>;
    expect(body.data.request.status).toBe(AccessRequestStatus.COMPLETED);
    expect(body.data.request.currentStage).toBe(AccessRequestStage.COMPLETE);

    const updated = await prisma.accessRequest.findUniqueOrThrow({
      where: { id: requestId },
    });
    expect(updated.status).toBe(AccessRequestStatus.COMPLETED);
    expect(updated.externalFusionRequestId).toMatch(/^MOCK-FUSION-/);
    expect(updated.completedAt).not.toBeNull();

    const outbox = await prisma.integrationOutbox.findFirst({
      where: {
        type: 'ACCESS_PROVISIONING',
      },
      orderBy: { createdAt: 'desc' },
    });
    expect(outbox).not.toBeNull();
    expect(outbox?.status).toBe('COMPLETED');

    const completedAudit = await prisma.auditLog.findFirst({
      where: {
        action: AuditActions.AccessRequestCompleted,
        entityId: requestId,
      },
      orderBy: { createdAt: 'desc' },
    });
    expect(completedAudit).not.toBeNull();
  });

  it('manager reject sets MANAGER_REJECTED; already decided returns business error', async () => {
    const { taskId } = await createPendingManagerRequest({
      requesterId: employeeId,
      securityRoleId: roleWithSecurityId,
      systemIdForRole: systemId,
    });

    const managerToken = await login(MANAGER_EMAIL);
    const rejected = await request(app.getHttpServer())
      .post(`${API}/approvals/${taskId}/decision`)
      .set('Authorization', `Bearer ${managerToken}`)
      .send({
        decision: 'REJECTED',
        comment: 'Business justification is insufficient for this role.',
      })
      .expect(200);

    const body = rejected.body as ApiSuccessResponse<DecisionResult>;
    expect(body.data.request.status).toBe(AccessRequestStatus.MANAGER_REJECTED);
    expect(body.data.request.currentStage).toBe(AccessRequestStage.COMPLETE);

    const second = await request(app.getHttpServer())
      .post(`${API}/approvals/${taskId}/decision`)
      .set('Authorization', `Bearer ${managerToken}`)
      .send({ decision: 'APPROVED' })
      .expect(400);

    const errorBody = second.body as ApiErrorResponse;
    expect(errorBody.error.code).toBe(ErrorCode.APPROVAL_TASK_NOT_PENDING);
  });

  it('security reject sets SECURITY_REJECTED', async () => {
    const { requestId, taskId } = await createPendingManagerRequest({
      requesterId: employeeId,
      securityRoleId: roleWithSecurityId,
      systemIdForRole: systemId,
    });

    const managerToken = await login(MANAGER_EMAIL);
    await request(app.getHttpServer())
      .post(`${API}/approvals/${taskId}/decision`)
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
    const response = await request(app.getHttpServer())
      .post(`${API}/approvals/${securityTask.id}/decision`)
      .set('Authorization', `Bearer ${securityToken}`)
      .send({
        decision: 'REJECTED',
        comment: 'Risk profile does not meet security policy.',
      })
      .expect(200);

    const body = response.body as ApiSuccessResponse<DecisionResult>;
    expect(body.data.request.status).toBe(
      AccessRequestStatus.SECURITY_REJECTED,
    );
  });

  it('manager-only role completes on manager approve without security task', async () => {
    const eventSystem = await prisma.appSystem.findUniqueOrThrow({
      where: { code: 'EVENT_OPS' },
    });

    const { requestId, taskId } = await createPendingManagerRequest({
      requesterId: employeeId,
      securityRoleId: roleManagerOnlyId,
      systemIdForRole: eventSystem.id,
    });

    const managerToken = await login(MANAGER_EMAIL);
    const response = await request(app.getHttpServer())
      .post(`${API}/approvals/${taskId}/decision`)
      .set('Authorization', `Bearer ${managerToken}`)
      .send({ decision: 'APPROVED' })
      .expect(200);

    const body = response.body as ApiSuccessResponse<DecisionResult>;
    expect(body.data.request.status).toBe(AccessRequestStatus.COMPLETED);

    const securityTasks = await prisma.approvalTask.count({
      where: {
        accessRequestId: requestId,
        stage: ApprovalStage.SECURITY,
      },
    });
    expect(securityTasks).toBe(0);

    const updated = await prisma.accessRequest.findUniqueOrThrow({
      where: { id: requestId },
    });
    expect(updated.externalFusionRequestId).toMatch(/^MOCK-FUSION-/);
  });
});
