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

type SubmitResult = {
  id: string;
  requestNumber: string;
  status: AccessRequestStatus;
  currentStage: AccessRequestStage;
  nextApprover: {
    id: string;
    fullNameEn: string;
  } | null;
};

type ListItem = {
  id: string;
  requestNumber: string;
  requester: { id: string; email: string };
};

type DetailResult = {
  id: string;
  requestNumber: string;
  status: AccessRequestStatus;
  timeline: Array<{ eventType: string; messageEn: string }>;
  nextApprover: { id: string; fullNameEn: string } | null;
};

describeDb('Access requests module (e2e BI-05 / BU-03)', () => {
  let app: INestApplication<App>;
  const prisma = new PrismaClient();
  let employeeId = '';
  let otherEmployeeId = '';
  let managerId = '';
  let adminId = '';
  let systemId = '';
  let roleId = '';
  let inactiveRoleId = '';
  let uniqueRoleId = '';
  let securityOnlyRoleId = '';

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
      if (user.email === ADMIN_EMAIL) {
        adminId = row.id;
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

    const role = await prisma.securityRoleCatalog.upsert({
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
    roleId = role.id;

    const inactiveRole = await prisma.securityRoleCatalog.upsert({
      where: {
        systemId_code: {
          systemId,
          code: 'FUSION_INACTIVE_ROLE',
        },
      },
      create: {
        systemId,
        code: 'FUSION_INACTIVE_ROLE',
        nameEn: 'Inactive Role',
        riskLevel: RiskLevel.LOW,
        requiresManagerApproval: true,
        requiresSecurityApproval: true,
        isActive: false,
      },
      update: { isActive: false },
    });
    inactiveRoleId = inactiveRole.id;

    const uniqueRole = await prisma.securityRoleCatalog.upsert({
      where: {
        systemId_code: {
          systemId,
          code: 'FUSION_E2E_UNIQUE',
        },
      },
      create: {
        systemId,
        code: 'FUSION_E2E_UNIQUE',
        nameEn: 'E2E Unique Role',
        riskLevel: RiskLevel.LOW,
        requiresManagerApproval: true,
        requiresSecurityApproval: true,
        isActive: true,
      },
      update: { isActive: true },
    });
    uniqueRoleId = uniqueRole.id;

    const securityOnlyRole = await prisma.securityRoleCatalog.upsert({
      where: {
        systemId_code: {
          systemId,
          code: 'FUSION_SECURITY_ONLY',
        },
      },
      create: {
        systemId,
        code: 'FUSION_SECURITY_ONLY',
        nameEn: 'Security-Only Approval Role',
        riskLevel: RiskLevel.LOW,
        requiresManagerApproval: false,
        requiresSecurityApproval: true,
        isActive: true,
      },
      update: {
        isActive: true,
        requiresManagerApproval: false,
        requiresSecurityApproval: true,
      },
    });
    securityOnlyRoleId = securityOnlyRole.id;

    const priorAdminRequests = await prisma.accessRequest.findMany({
      where: {
        requesterId: adminId,
        securityRoleId: securityOnlyRoleId,
      },
      select: { id: true },
    });
    const priorAdminIds = priorAdminRequests.map((row) => row.id);
    if (priorAdminIds.length > 0) {
      await prisma.accessRequestEvent.deleteMany({
        where: { accessRequestId: { in: priorAdminIds } },
      });
      await prisma.approvalTask.deleteMany({
        where: { accessRequestId: { in: priorAdminIds } },
      });
      await prisma.auditLog.deleteMany({
        where: {
          entityType: 'AccessRequest',
          entityId: { in: priorAdminIds },
        },
      });
      await prisma.accessRequest.deleteMany({
        where: { id: { in: priorAdminIds } },
      });
    }

    const prior = await prisma.accessRequest.findMany({
      where: {
        requesterId: employeeId,
        securityRoleId: uniqueRoleId,
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

  it('submits access request to MANAGER_PENDING with task, timeline, and audit', async () => {
    const token = await login(EMPLOYEE_EMAIL);

    const response = await request(app.getHttpServer())
      .post(`${API}/access-requests`)
      .set('Authorization', `Bearer ${token}`)
      .send({
        systemId,
        securityRoleId: uniqueRoleId,
        businessJustification:
          'Need temporary inquiry access to validate vendor invoice status for ops.',
        accessDuration: AccessDuration.TEMPORARY,
        startDate: '2026-07-10T00:00:00.000Z',
        endDate: '2026-08-10T00:00:00.000Z',
        urgency: AccessUrgency.NORMAL,
      })
      .expect(201);

    const body = response.body as ApiSuccessResponse<SubmitResult>;
    expect(body.data.status).toBe(AccessRequestStatus.MANAGER_PENDING);
    expect(body.data.currentStage).toBe(AccessRequestStage.MANAGER);
    expect(body.data.requestNumber).toMatch(/^AR-\d{4}-\d{6}$/);
    expect(body.data.nextApprover?.id).toBe(managerId);

    const task = await prisma.approvalTask.findFirst({
      where: {
        accessRequestId: body.data.id,
        stage: ApprovalStage.MANAGER,
        decision: ApprovalDecision.PENDING,
      },
    });
    expect(task?.assigneeId).toBe(managerId);

    const events = await prisma.accessRequestEvent.findMany({
      where: { accessRequestId: body.data.id },
      orderBy: { createdAt: 'asc' },
    });
    expect(events.map((event) => event.eventType)).toEqual(
      expect.arrayContaining(['SUBMITTED', 'MANAGER_TASK_ASSIGNED']),
    );

    const audit = await prisma.auditLog.findFirst({
      where: {
        action: AuditActions.AccessRequestSubmitted,
        entityType: 'AccessRequest',
        entityId: body.data.id,
      },
    });
    expect(audit).not.toBeNull();

    const detailResponse = await request(app.getHttpServer())
      .get(`${API}/access-requests/${body.data.id}`)
      .set('Authorization', `Bearer ${token}`)
      .expect(200);
    const detail = detailResponse.body as ApiSuccessResponse<DetailResult>;
    expect(detail.data.timeline.length).toBeGreaterThanOrEqual(2);
    expect(detail.data.nextApprover?.id).toBe(managerId);
  });

  it('lists requests scoped to requester for employee', async () => {
    const employeeToken = await login(EMPLOYEE_EMAIL);
    const otherToken = await login(OTHER_EMPLOYEE_EMAIL);

    const employeeList = await request(app.getHttpServer())
      .get(`${API}/access-requests`)
      .set('Authorization', `Bearer ${employeeToken}`)
      .expect(200);
    const employeeBody = employeeList.body as ApiSuccessResponse<ListItem[]> & {
      pagination: { total: number };
    };
    expect(
      employeeBody.data.every((item) => item.requester.id === employeeId),
    ).toBe(true);

    const otherList = await request(app.getHttpServer())
      .get(`${API}/access-requests`)
      .set('Authorization', `Bearer ${otherToken}`)
      .expect(200);
    const otherBody = otherList.body as ApiSuccessResponse<ListItem[]>;
    expect(
      otherBody.data.every((item) => item.requester.id === otherEmployeeId),
    ).toBe(true);
  });

  it('allows manager to see direct-report requests', async () => {
    const managerToken = await login(MANAGER_EMAIL);
    const response = await request(app.getHttpServer())
      .get(`${API}/access-requests`)
      .set('Authorization', `Bearer ${managerToken}`)
      .expect(200);
    const body = response.body as ApiSuccessResponse<ListItem[]>;
    expect(body.data.some((item) => item.requester.id === employeeId)).toBe(
      true,
    );
  });

  it('cancels MANAGER_PENDING request by requester', async () => {
    const token = await login(EMPLOYEE_EMAIL);
    const cancelRole = await prisma.securityRoleCatalog.upsert({
      where: {
        systemId_code: { systemId, code: 'FUSION_E2E_CANCEL' },
      },
      create: {
        systemId,
        code: 'FUSION_E2E_CANCEL',
        nameEn: 'E2E Cancel Role',
        riskLevel: RiskLevel.LOW,
        requiresManagerApproval: true,
        requiresSecurityApproval: true,
        isActive: true,
      },
      update: { isActive: true },
    });

    const prior = await prisma.accessRequest.findMany({
      where: { requesterId: employeeId, securityRoleId: cancelRole.id },
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
      await prisma.accessRequest.deleteMany({
        where: { id: { in: priorIds } },
      });
    }

    const created = await request(app.getHttpServer())
      .post(`${API}/access-requests`)
      .set('Authorization', `Bearer ${token}`)
      .send({
        systemId,
        securityRoleId: cancelRole.id,
        businessJustification:
          'Need cancelable access request for automated e2e coverage path.',
        accessDuration: AccessDuration.PERMANENT,
        startDate: '2026-07-10T00:00:00.000Z',
        urgency: AccessUrgency.NORMAL,
      })
      .expect(201);

    const createdBody = created.body as ApiSuccessResponse<SubmitResult>;

    const cancelResponse = await request(app.getHttpServer())
      .patch(`${API}/access-requests/${createdBody.data.id}/cancel`)
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    const cancelBody = cancelResponse.body as ApiSuccessResponse<{
      status: AccessRequestStatus;
    }>;
    expect(cancelBody.data.status).toBe(AccessRequestStatus.CANCELLED);

    const audit = await prisma.auditLog.findFirst({
      where: {
        action: AuditActions.AccessRequestCancelled,
        entityId: createdBody.data.id,
      },
    });
    expect(audit).not.toBeNull();
  });

  it('rejects cancel of completed request', async () => {
    const token = await login(EMPLOYEE_EMAIL);
    const completed = await prisma.accessRequest.create({
      data: {
        requestNumber: `AR-2026-9${String(Date.now()).slice(-5)}`,
        requesterId: employeeId,
        systemId,
        securityRoleId: roleId,
        businessJustification: 'Completed fixture for cancel rejection test.',
        accessDuration: AccessDuration.PERMANENT,
        startDate: new Date('2026-01-01T00:00:00.000Z'),
        urgency: AccessUrgency.NORMAL,
        status: AccessRequestStatus.COMPLETED,
        currentStage: AccessRequestStage.COMPLETE,
        submittedAt: new Date('2026-01-01T00:00:00.000Z'),
        completedAt: new Date('2026-01-02T00:00:00.000Z'),
      },
    });

    const response = await request(app.getHttpServer())
      .patch(`${API}/access-requests/${completed.id}/cancel`)
      .set('Authorization', `Bearer ${token}`)
      .expect(400);

    const body = response.body as ApiErrorResponse;
    expect(body.error.code).toBe(ErrorCode.REQUEST_NOT_CANCELABLE);

    await prisma.accessRequest.delete({ where: { id: completed.id } });
  });

  it('returns ROLE_NOT_REQUESTABLE for inactive role', async () => {
    const token = await login(EMPLOYEE_EMAIL);
    const response = await request(app.getHttpServer())
      .post(`${API}/access-requests`)
      .set('Authorization', `Bearer ${token}`)
      .send({
        systemId,
        securityRoleId: inactiveRoleId,
        businessJustification:
          'Trying to request an inactive role should fail validation.',
        accessDuration: AccessDuration.PERMANENT,
        startDate: '2026-07-10T00:00:00.000Z',
        urgency: AccessUrgency.NORMAL,
      })
      .expect(400);

    const body = response.body as ApiErrorResponse;
    expect(body.error.code).toBe(ErrorCode.ROLE_NOT_REQUESTABLE);
  });

  it('returns VALIDATION_ERROR for short justification', async () => {
    const token = await login(EMPLOYEE_EMAIL);
    const response = await request(app.getHttpServer())
      .post(`${API}/access-requests`)
      .set('Authorization', `Bearer ${token}`)
      .send({
        systemId,
        securityRoleId: roleId,
        businessJustification: 'too short',
        accessDuration: AccessDuration.PERMANENT,
        startDate: '2026-07-10T00:00:00.000Z',
        urgency: AccessUrgency.NORMAL,
      })
      .expect(400);

    const body = response.body as ApiErrorResponse;
    expect(body.error.code).toBe(ErrorCode.VALIDATION_ERROR);
  });

  it('returns INVALID_ACCESS_DATES when endDate precedes startDate', async () => {
    const token = await login(EMPLOYEE_EMAIL);
    const response = await request(app.getHttpServer())
      .post(`${API}/access-requests`)
      .set('Authorization', `Bearer ${token}`)
      .send({
        systemId,
        securityRoleId: roleId,
        businessJustification:
          'Temporary access with inverted dates should fail validation.',
        accessDuration: AccessDuration.TEMPORARY,
        startDate: '2026-08-10T00:00:00.000Z',
        endDate: '2026-07-10T00:00:00.000Z',
        urgency: AccessUrgency.NORMAL,
      })
      .expect(400);

    const body = response.body as ApiErrorResponse;
    expect(body.error.code).toBe(ErrorCode.INVALID_ACCESS_DATES);
  });

  it('returns DUPLICATE_ACTIVE_REQUEST for same active role', async () => {
    const token = await login(EMPLOYEE_EMAIL);

    // Ensure a known active request exists for this role before asserting duplicate.
    const prior = await prisma.accessRequest.findMany({
      where: {
        requesterId: employeeId,
        securityRoleId: uniqueRoleId,
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

    await request(app.getHttpServer())
      .post(`${API}/access-requests`)
      .set('Authorization', `Bearer ${token}`)
      .send({
        systemId,
        securityRoleId: uniqueRoleId,
        businessJustification:
          'First active request used to set up duplicate detection coverage.',
        accessDuration: AccessDuration.TEMPORARY,
        startDate: '2026-07-10T00:00:00.000Z',
        endDate: '2026-08-10T00:00:00.000Z',
        urgency: AccessUrgency.NORMAL,
      })
      .expect(201);

    const response = await request(app.getHttpServer())
      .post(`${API}/access-requests`)
      .set('Authorization', `Bearer ${token}`)
      .send({
        systemId,
        securityRoleId: uniqueRoleId,
        businessJustification:
          'Duplicate active request for the same role should be blocked.',
        accessDuration: AccessDuration.TEMPORARY,
        startDate: '2026-07-10T00:00:00.000Z',
        endDate: '2026-08-10T00:00:00.000Z',
        urgency: AccessUrgency.NORMAL,
      })
      .expect(400);

    const body = response.body as ApiErrorResponse;
    expect(body.error.code).toBe(ErrorCode.DUPLICATE_ACTIVE_REQUEST);
  });

  it('returns MANAGER_NOT_FOUND when manager approval required and missing', async () => {
    const orphanEmail = 'orphan.e2e@expo.sa';
    const passwordHash = await bcrypt.hash(DEMO_PASSWORD, 10);
    const ops = await prisma.department.findUnique({ where: { code: 'OPS' } });
    if (!ops) {
      throw new Error('OPS department missing');
    }

    const orphan = await prisma.user.upsert({
      where: { email: orphanEmail },
      create: {
        email: orphanEmail,
        externalRef: 'ext-orphan-e2e',
        employeeNumber: 'E1999',
        fullNameEn: 'Orphan Employee',
        role: UserRole.EMPLOYEE,
        departmentId: ops.id,
        passwordHash,
        isActive: true,
        managerId: null,
      },
      update: {
        passwordHash,
        isActive: true,
        managerId: null,
      },
    });

    const orphanRole = await prisma.securityRoleCatalog.upsert({
      where: {
        systemId_code: { systemId, code: 'FUSION_E2E_ORPHAN' },
      },
      create: {
        systemId,
        code: 'FUSION_E2E_ORPHAN',
        nameEn: 'E2E Orphan Role',
        riskLevel: RiskLevel.LOW,
        requiresManagerApproval: true,
        requiresSecurityApproval: true,
        isActive: true,
      },
      update: { isActive: true },
    });

    const token = await login(orphanEmail);
    const response = await request(app.getHttpServer())
      .post(`${API}/access-requests`)
      .set('Authorization', `Bearer ${token}`)
      .send({
        systemId,
        securityRoleId: orphanRole.id,
        businessJustification:
          'Orphan employee without manager should fail manager routing.',
        accessDuration: AccessDuration.PERMANENT,
        startDate: '2026-07-10T00:00:00.000Z',
        urgency: AccessUrgency.NORMAL,
      })
      .expect(400);

    const body = response.body as ApiErrorResponse;
    expect(body.error.code).toBe(ErrorCode.MANAGER_NOT_FOUND);

    await prisma.user
      .delete({ where: { id: orphan.id } })
      .catch(() => undefined);
  });

  it('forbids employee from reading another employee request detail', async () => {
    const employeeToken = await login(EMPLOYEE_EMAIL);
    const otherToken = await login(OTHER_EMPLOYEE_EMAIL);

    const list = await request(app.getHttpServer())
      .get(`${API}/access-requests`)
      .set('Authorization', `Bearer ${employeeToken}`)
      .expect(200);
    const listBody = list.body as ApiSuccessResponse<ListItem[]>;
    const target = listBody.data[0];
    if (!target) {
      throw new Error('Expected employee to have at least one access request');
    }

    const response = await request(app.getHttpServer())
      .get(`${API}/access-requests/${target.id}`)
      .set('Authorization', `Bearer ${otherToken}`)
      .expect(403);

    const body = response.body as ApiErrorResponse;
    expect(body.error.code).toBe(ErrorCode.FORBIDDEN);
  });

  it('allows system admin to submit an own access request (doc 06 matrix, ADR-C013)', async () => {
    const adminToken = await login(ADMIN_EMAIL);

    const response = await request(app.getHttpServer())
      .post(`${API}/access-requests`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        systemId,
        securityRoleId: securityOnlyRoleId,
        businessJustification:
          'System admin needs security-only access to validate audit tooling.',
        accessDuration: AccessDuration.PERMANENT,
        startDate: '2026-07-10T00:00:00.000Z',
        urgency: AccessUrgency.NORMAL,
      })
      .expect(201);

    const body = response.body as ApiSuccessResponse<SubmitResult>;
    expect(body.data.requestNumber).toMatch(/^AR-\d{4}-\d{6}$/);
    expect(body.data.status).toBe(AccessRequestStatus.SECURITY_PENDING);
    expect(body.data.currentStage).toBe(AccessRequestStage.SECURITY);

    const stored = await prisma.accessRequest.findUniqueOrThrow({
      where: { id: body.data.id },
    });
    expect(stored.requesterId).toBe(adminId);
  });
});
