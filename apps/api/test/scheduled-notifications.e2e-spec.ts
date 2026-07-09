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
import { AuditActions } from './../src/audit/audit-actions';
import { LoginResponseDto } from './../src/auth/dto/auth-response.dto';
import { GlobalExceptionFilter } from './../src/common/filters/http-exception.filter';
import { ResponseEnvelopeInterceptor } from './../src/common/interceptors/response-envelope.interceptor';
import { TraceIdMiddleware } from './../src/common/middleware/trace-id.middleware';
import { ApiSuccessResponse } from './../src/common/types/api-response';
import { ScheduledNotificationsService } from './../src/notifications/scheduled-notifications.service';

const databaseUrl = process.env.DATABASE_URL;
const shouldRunDbTests =
  typeof databaseUrl === 'string' &&
  databaseUrl.length > 0 &&
  process.env.PRISMA_SKIP_DB_TESTS !== '1';

const describeDb = shouldRunDbTests ? describe : describe.skip;

const DEMO_PASSWORD = 'Password123!';
const EMPLOYEE_EMAIL = 'noura.alharbi@expo.sa';
const ADMIN_EMAIL = 'admin@expo.sa';
const API = '/api/v1';
const SCHEDULED_TITLE = 'T-FIX-01 scheduled briefing';

describeDb('Scheduled notification publishing (e2e T-FIX-01)', () => {
  let app: INestApplication<App>;
  const prisma = new PrismaClient();
  let employeeId = '';

  beforeAll(async () => {
    const passwordHash = await bcrypt.hash(DEMO_PASSWORD, 10);

    for (const code of ['OPS', 'TECH'] as const) {
      await prisma.department.upsert({
        where: { code },
        create: { code, nameEn: code, nameAr: code },
        update: {},
      });
    }

    const departments = await prisma.department.findMany({
      where: { code: { in: ['OPS', 'TECH'] } },
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

  async function login(email: string): Promise<string> {
    const response = await request(app.getHttpServer())
      .post(`${API}/auth/login`)
      .send({ email, password: DEMO_PASSWORD })
      .expect(200);
    return (response.body as ApiSuccessResponse<LoginResponseDto>).data
      .accessToken;
  }

  it('publishes a due SCHEDULED notification with recipients + audit (happy path)', async () => {
    const adminToken = await login(ADMIN_EMAIL);
    const publishAt = new Date(Date.now() - 60_000).toISOString();

    const createResponse = await request(app.getHttpServer())
      .post(`${API}/notifications`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        titleEn: SCHEDULED_TITLE,
        bodyEn: 'This scheduled announcement must publish automatically.',
        priority: NotificationPriority.NORMAL,
        audienceType: AudienceType.USERS,
        audienceFilter: { userIds: [employeeId] },
        publishNow: false,
        publishAt,
      })
      .expect(201);

    const created = createResponse.body as ApiSuccessResponse<{
      id: string;
      status: NotificationStatus;
      recipientCount: number;
    }>;
    expect(created.data.status).toBe(NotificationStatus.SCHEDULED);
    expect(created.data.recipientCount).toBe(0);
    const notificationId = created.data.id;

    // Scheduled notifications are hidden from recipients until published.
    const employeeToken = await login(EMPLOYEE_EMAIL);
    const beforeList = await request(app.getHttpServer())
      .get(`${API}/notifications`)
      .query({ search: SCHEDULED_TITLE })
      .set('Authorization', `Bearer ${employeeToken}`)
      .expect(200);
    const beforeBody = beforeList.body as ApiSuccessResponse<
      Array<{ id: string }>
    >;
    expect(beforeBody.data.every((item) => item.id !== notificationId)).toBe(
      true,
    );

    const publisher = app.get(ScheduledNotificationsService);
    const summary = await publisher.publishDueNotifications();
    expect(summary.published).toBeGreaterThanOrEqual(1);
    expect(summary.failed).toBe(0);

    const row = await prisma.notification.findUniqueOrThrow({
      where: { id: notificationId },
    });
    expect(row.status).toBe(NotificationStatus.PUBLISHED);

    const recipients = await prisma.notificationRecipient.findMany({
      where: { notificationId },
    });
    expect(recipients).toHaveLength(1);
    expect(recipients[0]?.userId).toBe(employeeId);
    expect(recipients[0]?.deliveredAt).not.toBeNull();

    const audit = await prisma.auditLog.findFirst({
      where: {
        action: AuditActions.NotificationPublished,
        entityId: notificationId,
      },
    });
    expect(audit).not.toBeNull();

    const afterList = await request(app.getHttpServer())
      .get(`${API}/notifications`)
      .query({ search: SCHEDULED_TITLE })
      .set('Authorization', `Bearer ${employeeToken}`)
      .expect(200);
    const afterBody = afterList.body as ApiSuccessResponse<
      Array<{ id: string }>
    >;
    expect(afterBody.data.some((item) => item.id === notificationId)).toBe(
      true,
    );
  });

  it('leaves future SCHEDULED notifications untouched (edge)', async () => {
    const adminToken = await login(ADMIN_EMAIL);
    const publishAt = new Date(Date.now() + 60 * 60 * 1000).toISOString();

    const createResponse = await request(app.getHttpServer())
      .post(`${API}/notifications`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        titleEn: 'T-FIX-01 future scheduled briefing',
        bodyEn: 'This notification is scheduled for the future.',
        priority: NotificationPriority.NORMAL,
        audienceType: AudienceType.USERS,
        audienceFilter: { userIds: [employeeId] },
        publishNow: false,
        publishAt,
      })
      .expect(201);

    const created = createResponse.body as ApiSuccessResponse<{ id: string }>;

    const publisher = app.get(ScheduledNotificationsService);
    await publisher.publishDueNotifications();

    const row = await prisma.notification.findUniqueOrThrow({
      where: { id: created.data.id },
    });
    expect(row.status).toBe(NotificationStatus.SCHEDULED);
    const recipients = await prisma.notificationRecipient.count({
      where: { notificationId: created.data.id },
    });
    expect(recipients).toBe(0);
  });

  it('does not publish cancelled scheduled notifications (failure path)', async () => {
    const adminToken = await login(ADMIN_EMAIL);
    const publishAt = new Date(Date.now() - 60_000).toISOString();

    const createResponse = await request(app.getHttpServer())
      .post(`${API}/notifications`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        titleEn: 'T-FIX-01 cancelled scheduled briefing',
        bodyEn: 'This scheduled announcement is cancelled before publish.',
        priority: NotificationPriority.NORMAL,
        audienceType: AudienceType.USERS,
        audienceFilter: { userIds: [employeeId] },
        publishNow: false,
        publishAt,
      })
      .expect(201);

    const created = createResponse.body as ApiSuccessResponse<{ id: string }>;

    await request(app.getHttpServer())
      .post(`${API}/notifications/${created.data.id}/cancel`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ reason: 'Cancelled before scheduled publish' })
      .expect(200);

    const publisher = app.get(ScheduledNotificationsService);
    await publisher.publishDueNotifications();

    const row = await prisma.notification.findUniqueOrThrow({
      where: { id: created.data.id },
    });
    expect(row.status).toBe(NotificationStatus.CANCELLED);
    const recipients = await prisma.notificationRecipient.count({
      where: { notificationId: created.data.id },
    });
    expect(recipients).toBe(0);
  });
});
