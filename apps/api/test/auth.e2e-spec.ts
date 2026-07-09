import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { PrismaClient, UserRole } from '@prisma/client';
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
import {
  LoginResponseDto,
  MeResponseDto,
} from './../src/auth/dto/auth-response.dto';

const databaseUrl = process.env.DATABASE_URL;
const shouldRunDbTests =
  typeof databaseUrl === 'string' &&
  databaseUrl.length > 0 &&
  process.env.PRISMA_SKIP_DB_TESTS !== '1';

const describeDb = shouldRunDbTests ? describe : describe.skip;

const DEMO_PASSWORD = 'Password123!';

const DEMO_USERS: Array<{
  email: string;
  role: UserRole;
  employeeNumber: string;
  externalRef: string;
  fullNameEn: string;
  departmentCode: string;
}> = [
  {
    email: 'noura.alharbi@expo.sa',
    role: UserRole.EMPLOYEE,
    employeeNumber: 'E1001',
    externalRef: 'ext-e1001',
    fullNameEn: 'Noura Alharbi',
    departmentCode: 'OPS',
  },
  {
    email: 'salem.alqahtani@expo.sa',
    role: UserRole.EMPLOYEE,
    employeeNumber: 'E1002',
    externalRef: 'ext-e1002',
    fullNameEn: 'Salem Alqahtani',
    departmentCode: 'OPS',
  },
  {
    email: 'faisal.otaibi@expo.sa',
    role: UserRole.MANAGER,
    employeeNumber: 'M2001',
    externalRef: 'ext-m2001',
    fullNameEn: 'Faisal Otaibi',
    departmentCode: 'OPS',
  },
  {
    email: 'reem.security@expo.sa',
    role: UserRole.SECURITY_ADMIN,
    employeeNumber: 'S3001',
    externalRef: 'ext-s3001',
    fullNameEn: 'Reem Almutairi',
    departmentCode: 'SEC',
  },
  {
    email: 'admin@expo.sa',
    role: UserRole.SYSTEM_ADMIN,
    employeeNumber: 'A9001',
    externalRef: 'ext-a9001',
    fullNameEn: 'Expo System Admin',
    departmentCode: 'TECH',
  },
];

describeDb('Auth + RBAC (e2e BI-02 / BI-03)', () => {
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

    for (const user of DEMO_USERS) {
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

  it('logs in all demo users (BI-02)', async () => {
    for (const user of DEMO_USERS) {
      const body = await login(user.email);
      expect(body.data.accessToken).toEqual(expect.any(String));
      expect(body.data.refreshToken).toEqual(expect.any(String));
      expect(body.data.user.email).toBe(user.email);
      expect(body.data.user.role).toBe(user.role);
      expect(body.data.user.department).toEqual(
        expect.objectContaining({
          code: user.departmentCode,
        }),
      );
    }
  });

  it('returns /auth/me with permissions and supports logout (BI-02)', async () => {
    const loginBody = await login('admin@expo.sa');
    const token = loginBody.data.accessToken;

    const meResponse = await request(app.getHttpServer())
      .get('/api/v1/auth/me')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    const me = meResponse.body as ApiSuccessResponse<MeResponseDto>;
    expect(me.data.email).toBe('admin@expo.sa');
    expect(me.data.role).toBe(UserRole.SYSTEM_ADMIN);
    expect(me.data.permissions).toEqual(
      expect.arrayContaining([
        'notifications:create',
        'notifications:publish',
        'audit:read',
      ]),
    );

    const logoutResponse = await request(app.getHttpServer())
      .post('/api/v1/auth/logout')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    expect(
      (logoutResponse.body as ApiSuccessResponse<{ success: boolean }>).data
        .success,
    ).toBe(true);
  });

  it('rejects missing bearer token with 401 (BI-03)', async () => {
    const response = await request(app.getHttpServer())
      .get('/api/v1/auth/me')
      .expect(401);

    const body = response.body as ApiErrorResponse;
    expect(body.error.code).toBe('UNAUTHORIZED');
  });

  it('rejects employee POST /notifications with 403 (BI-03)', async () => {
    const loginBody = await login('noura.alharbi@expo.sa');

    const response = await request(app.getHttpServer())
      .post('/api/v1/notifications')
      .set('Authorization', `Bearer ${loginBody.data.accessToken}`)
      .expect(403);

    const body = response.body as ApiErrorResponse;
    expect(body.error.code).toBe('FORBIDDEN');
  });

  it('rejects employee GET /audit-logs with 403 (BI-03)', async () => {
    const loginBody = await login('noura.alharbi@expo.sa');

    const response = await request(app.getHttpServer())
      .get('/api/v1/audit-logs')
      .set('Authorization', `Bearer ${loginBody.data.accessToken}`)
      .expect(403);

    const body = response.body as ApiErrorResponse;
    expect(body.error.code).toBe('FORBIDDEN');
  });

  it('allows system admin RBAC probe endpoints', async () => {
    const loginBody = await login('admin@expo.sa');
    const token = loginBody.data.accessToken;

    await request(app.getHttpServer())
      .post('/api/v1/notifications')
      .set('Authorization', `Bearer ${token}`)
      .expect(201);

    await request(app.getHttpServer())
      .get('/api/v1/audit-logs')
      .set('Authorization', `Bearer ${token}`)
      .expect(200);
  });

  it('rejects invalid login credentials with 401', async () => {
    const response = await request(app.getHttpServer())
      .post('/api/v1/auth/login')
      .send({ email: 'noura.alharbi@expo.sa', password: 'bad-password' })
      .expect(401);

    const body = response.body as ApiErrorResponse;
    expect(body.error.code).toBe('UNAUTHORIZED');
    expect(body.error.message).toMatch(/Invalid email or password/i);
  });
});
