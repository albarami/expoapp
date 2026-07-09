import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { PrismaClient, UserRole } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { NextFunction, Request, Response } from 'express';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from './../src/app.module';
import { AuditActions } from './../src/audit/audit-actions';
import { LoginResponseDto } from './../src/auth/dto/auth-response.dto';
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
const MANAGER_EMAIL = 'faisal.otaibi@expo.sa';
const SECURITY_EMAIL = 'reem.security@expo.sa';
const ADMIN_EMAIL = 'admin@expo.sa';

type AuditLogItem = {
  id: string;
  actorId: string | null;
  actorEmail: string | null;
  action: string;
  entityType: string;
  entityId: string | null;
  metadata: Record<string, unknown> | null;
  ipAddress: string | null;
  userAgent: string | null;
  createdAt: string;
};

describeDb('Audit logs module (e2e BI-07 / AUD)', () => {
  let app: INestApplication<App>;
  const prisma = new PrismaClient();
  let adminId = '';
  let securityId = '';
  let markerEntityId = '';

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
          externalRef: user.externalRef,
          employeeNumber: user.employeeNumber,
          fullNameEn: user.fullNameEn,
          role: user.role,
          departmentId,
          passwordHash,
          isActive: true,
        },
      });
      if (user.email === ADMIN_EMAIL) {
        adminId = row.id;
      }
      if (user.email === SECURITY_EMAIL) {
        securityId = row.id;
      }
    }

    markerEntityId = `audit-e2e-${Date.now()}`;
    const baseTime = new Date('2026-07-09T10:00:00.000Z');

    await prisma.auditLog.createMany({
      data: [
        {
          actorId: adminId,
          actorEmail: ADMIN_EMAIL,
          action: AuditActions.NotificationCreated,
          entityType: 'Notification',
          entityId: markerEntityId,
          metadata: { priority: 'HIGH', audienceType: 'ALL' },
          createdAt: new Date(baseTime.getTime()),
        },
        {
          actorId: adminId,
          actorEmail: ADMIN_EMAIL,
          action: AuditActions.NotificationPublished,
          entityType: 'Notification',
          entityId: markerEntityId,
          metadata: { recipientCount: 4 },
          createdAt: new Date(baseTime.getTime() + 60_000),
        },
        {
          actorId: securityId,
          actorEmail: SECURITY_EMAIL,
          action: AuditActions.NotificationCancelled,
          entityType: 'Notification',
          entityId: markerEntityId,
          metadata: { reason: 'stale' },
          createdAt: new Date(baseTime.getTime() + 120_000),
        },
      ],
    });

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
    app.use((req: Request, res: Response, next: NextFunction) => {
      new TraceIdMiddleware().use(req, res, next);
    });
    await app.init();
  });

  afterAll(async () => {
    await prisma.auditLog.deleteMany({
      where: { entityId: markerEntityId },
    });
    await app.close();
    await prisma.$disconnect();
  });

  async function login(email: string): Promise<LoginResponseDto> {
    const response = await request(app.getHttpServer())
      .post('/api/v1/auth/login')
      .send({ email, password: DEMO_PASSWORD })
      .expect(200);
    const body = response.body as ApiSuccessResponse<LoginResponseDto>;
    return body.data;
  }

  it('rejects missing token with 401', async () => {
    const response = await request(app.getHttpServer())
      .get('/api/v1/audit-logs')
      .expect(401);

    const body = response.body as ApiErrorResponse;
    expect(body.error.code).toBe('UNAUTHORIZED');
  });

  it('rejects employee and manager with 403 (BI-03)', async () => {
    for (const email of [EMPLOYEE_EMAIL, MANAGER_EMAIL]) {
      const loginBody = await login(email);
      const response = await request(app.getHttpServer())
        .get('/api/v1/audit-logs')
        .set('Authorization', `Bearer ${loginBody.accessToken}`)
        .expect(403);

      const body = response.body as ApiErrorResponse;
      expect(body.error.code).toBe('FORBIDDEN');
    }
  });

  it('lists filtered audit logs for security admin (BI-07)', async () => {
    const loginBody = await login(SECURITY_EMAIL);

    const response = await request(app.getHttpServer())
      .get('/api/v1/audit-logs')
      .query({
        entityId: markerEntityId,
        action: AuditActions.NotificationPublished,
        page: 1,
        pageSize: 10,
      })
      .set('Authorization', `Bearer ${loginBody.accessToken}`)
      .expect(200);

    const body = response.body as ApiSuccessResponse<AuditLogItem[]> & {
      pagination: {
        page: number;
        pageSize: number;
        total: number;
        totalPages: number;
      };
    };

    expect(body.pagination.total).toBe(1);
    expect(body.pagination.page).toBe(1);
    expect(body.pagination.pageSize).toBe(10);
    expect(body.data).toHaveLength(1);
    expect(body.data[0]).toMatchObject({
      actorEmail: ADMIN_EMAIL,
      action: AuditActions.NotificationPublished,
      entityType: 'Notification',
      entityId: markerEntityId,
      metadata: { recipientCount: 4 },
    });
    expect(body.data[0].createdAt).toEqual(expect.any(String));
  });

  it('supports actorEmail, entityType, from/to filters and pagination', async () => {
    const loginBody = await login(ADMIN_EMAIL);

    const filtered = await request(app.getHttpServer())
      .get('/api/v1/audit-logs')
      .query({
        entityId: markerEntityId,
        actorEmail: ADMIN_EMAIL,
        entityType: 'Notification',
        from: '2026-07-09T10:00:00.000Z',
        to: '2026-07-09T10:01:30.000Z',
        page: 1,
        pageSize: 50,
      })
      .set('Authorization', `Bearer ${loginBody.accessToken}`)
      .expect(200);

    const filteredBody = filtered.body as ApiSuccessResponse<AuditLogItem[]> & {
      pagination: { total: number };
    };
    expect(filteredBody.pagination.total).toBe(2);
    expect(
      filteredBody.data.every((item) => item.actorEmail === ADMIN_EMAIL),
    ).toBe(true);

    const pageOne = await request(app.getHttpServer())
      .get('/api/v1/audit-logs')
      .query({
        entityId: markerEntityId,
        page: 1,
        pageSize: 2,
      })
      .set('Authorization', `Bearer ${loginBody.accessToken}`)
      .expect(200);

    const pageOneBody = pageOne.body as ApiSuccessResponse<AuditLogItem[]> & {
      pagination: { total: number; totalPages: number; pageSize: number };
    };
    expect(pageOneBody.pagination.total).toBe(3);
    expect(pageOneBody.pagination.totalPages).toBe(2);
    expect(pageOneBody.data).toHaveLength(2);
    expect(pageOneBody.data[0].createdAt >= pageOneBody.data[1].createdAt).toBe(
      true,
    );
  });

  it('audits login success/failure without secrets (AUD-01 / AUD-04)', async () => {
    await request(app.getHttpServer())
      .post('/api/v1/auth/login')
      .send({ email: ADMIN_EMAIL, password: 'bad-password' })
      .expect(401);

    const successLogin = await login(ADMIN_EMAIL);

    const response = await request(app.getHttpServer())
      .get('/api/v1/audit-logs')
      .query({
        action: AuditActions.AuthLogin,
        actorEmail: ADMIN_EMAIL,
        page: 1,
        pageSize: 20,
      })
      .set('Authorization', `Bearer ${successLogin.accessToken}`)
      .expect(200);

    const body = response.body as ApiSuccessResponse<AuditLogItem[]>;
    expect(body.data.length).toBeGreaterThanOrEqual(1);

    const serialized = JSON.stringify(body.data);
    expect(serialized.toLowerCase()).not.toContain('password');
    expect(serialized.toLowerCase()).not.toContain('token');
    expect(serialized).not.toContain(DEMO_PASSWORD);

    const successEntry = body.data.find(
      (item) => item.metadata?.success === true,
    );
    const failureEntry = body.data.find(
      (item) => item.metadata?.success === false,
    );
    expect(successEntry).toBeDefined();
    expect(failureEntry).toBeDefined();
  });
});
