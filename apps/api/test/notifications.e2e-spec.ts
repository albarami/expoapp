import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import {
  AudienceType,
  NotificationPriority,
  NotificationStatus,
  PrismaClient,
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
import { AuditActions } from './../src/audit/audit-actions';

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

describeDb('Notifications module (e2e BI-04)', () => {
  let app: INestApplication<App>;
  const prisma = new PrismaClient();
  let employeeId = '';
  let managerId = '';
  let adminId = '';

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
          passwordHash,
          role: user.role,
          isActive: true,
          departmentId,
        },
      });
      if (user.email === EMPLOYEE_EMAIL) {
        employeeId = row.id;
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

  it('admin creates published notification with recipients; employee list/detail/read; stats; cancel', async () => {
    const adminLogin = await login(ADMIN_EMAIL);
    const adminToken = adminLogin.data.accessToken;

    const createResponse = await request(app.getHttpServer())
      .post('/api/v1/notifications')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        titleEn: 'BI-04 operations briefing',
        titleAr: 'إحاطة العمليات BI-04',
        bodyEn: 'All operations staff must attend the 9 AM briefing.',
        bodyAr: 'على جميع موظفي العمليات حضور الإحاطة الساعة 9 صباحًا.',
        priority: NotificationPriority.HIGH,
        audienceType: AudienceType.DEPARTMENT,
        audienceFilter: {
          departmentCodes: ['OPS'],
        },
        publishNow: true,
      })
      .expect(201);

    const created = createResponse.body as ApiSuccessResponse<{
      id: string;
      status: NotificationStatus;
      recipientCount: number;
    }>;

    expect(created.data.status).toBe(NotificationStatus.PUBLISHED);
    expect(created.data.recipientCount).toBeGreaterThanOrEqual(2);

    const notificationId = created.data.id;

    const recipientRows = await prisma.notificationRecipient.findMany({
      where: { notificationId },
    });
    expect(recipientRows.length).toBe(created.data.recipientCount);
    expect(recipientRows.every((row) => row.deliveredAt !== null)).toBe(true);

    const createdAudit = await prisma.auditLog.findFirst({
      where: {
        action: AuditActions.NotificationCreated,
        entityId: notificationId,
      },
    });
    const publishedAudit = await prisma.auditLog.findFirst({
      where: {
        action: AuditActions.NotificationPublished,
        entityId: notificationId,
      },
    });
    expect(createdAudit).not.toBeNull();
    expect(publishedAudit).not.toBeNull();

    const employeeLogin = await login(EMPLOYEE_EMAIL);
    const employeeToken = employeeLogin.data.accessToken;

    const listResponse = await request(app.getHttpServer())
      .get('/api/v1/notifications')
      .query({ unreadOnly: true, search: 'BI-04' })
      .set('Authorization', `Bearer ${employeeToken}`)
      .expect(200);

    const listBody = listResponse.body as ApiSuccessResponse<
      Array<{ id: string; readAt: string | null; titleEn: string }>
    > & {
      pagination: {
        page: number;
        pageSize: number;
        total: number;
        totalPages: number;
      };
    };

    expect(listBody.pagination.total).toBeGreaterThanOrEqual(1);
    expect(listBody.data.some((item) => item.id === notificationId)).toBe(true);

    const detailResponse = await request(app.getHttpServer())
      .get(`/api/v1/notifications/${notificationId}`)
      .set('Authorization', `Bearer ${employeeToken}`)
      .expect(200);

    const detail = detailResponse.body as ApiSuccessResponse<{
      id: string;
      readAt: string | null;
      priority: NotificationPriority;
    }>;
    expect(detail.data.id).toBe(notificationId);
    expect(detail.data.readAt).toBeNull();
    expect(detail.data.priority).toBe(NotificationPriority.HIGH);

    const readResponse = await request(app.getHttpServer())
      .patch(`/api/v1/notifications/${notificationId}/read`)
      .set('Authorization', `Bearer ${employeeToken}`)
      .expect(200);

    const readBody = readResponse.body as ApiSuccessResponse<{
      readAt: string | null;
    }>;
    expect(readBody.data.readAt).toEqual(expect.any(String));

    const readAudit = await prisma.auditLog.findFirst({
      where: {
        action: AuditActions.NotificationRead,
        entityId: notificationId,
        actorId: employeeId,
      },
    });
    expect(readAudit).not.toBeNull();

    const statsResponse = await request(app.getHttpServer())
      .get(`/api/v1/notifications/${notificationId}/stats`)
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(200);

    const stats = statsResponse.body as ApiSuccessResponse<{
      recipientCount: number;
      deliveredCount: number;
      readCount: number;
      unreadCount: number;
      readPercentage: number;
    }>;
    expect(stats.data.recipientCount).toBe(created.data.recipientCount);
    expect(stats.data.deliveredCount).toBe(created.data.recipientCount);
    expect(stats.data.readCount).toBeGreaterThanOrEqual(1);
    expect(stats.data.unreadCount).toBe(
      stats.data.recipientCount - stats.data.readCount,
    );

    const employeeStats = await request(app.getHttpServer())
      .get(`/api/v1/notifications/${notificationId}/stats`)
      .set('Authorization', `Bearer ${employeeToken}`)
      .expect(403);
    expect((employeeStats.body as ApiErrorResponse).error.code).toBe(
      'FORBIDDEN',
    );

    const cancelResponse = await request(app.getHttpServer())
      .post(`/api/v1/notifications/${notificationId}/cancel`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ reason: 'Superseded by updated briefing' })
      .expect(200);

    const cancelled = cancelResponse.body as ApiSuccessResponse<{
      id: string;
      status: NotificationStatus;
    }>;
    expect(cancelled.data.status).toBe(NotificationStatus.CANCELLED);

    const cancelAudit = await prisma.auditLog.findFirst({
      where: {
        action: AuditActions.NotificationCancelled,
        entityId: notificationId,
        actorId: adminId,
      },
    });
    expect(cancelAudit).not.toBeNull();

    await request(app.getHttpServer())
      .get(`/api/v1/notifications/${notificationId}`)
      .set('Authorization', `Bearer ${employeeToken}`)
      .expect(404);
  });

  it('rejects invalid audience filter on create', async () => {
    const adminLogin = await login(ADMIN_EMAIL);

    const response = await request(app.getHttpServer())
      .post('/api/v1/notifications')
      .set('Authorization', `Bearer ${adminLogin.data.accessToken}`)
      .send({
        titleEn: 'Bad audience',
        bodyEn: 'This should fail audience validation rules.',
        priority: NotificationPriority.NORMAL,
        audienceType: AudienceType.DEPARTMENT,
        audienceFilter: { departmentCodes: [] },
        publishNow: true,
      })
      .expect(400);

    const body = response.body as ApiErrorResponse;
    expect(body.error.code).toBe('INVALID_AUDIENCE_FILTER');
  });
});
