import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { PrismaClient, UserRole } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { NextFunction, Request, Response } from 'express';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from './../src/app.module';
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
const OTHER_EMPLOYEE_EMAIL = 'salem.alqahtani@expo.sa';
const API = '/api/v1';
const E2E_TOKEN = 'device-tokens-e2e-fcm-token';

type RegisterResult = {
  id: string;
  platform: string;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
};

describeDb('Device tokens (e2e T-FIX-01)', () => {
  let app: INestApplication<App>;
  const prisma = new PrismaClient();
  let employeeId = '';
  let otherEmployeeId = '';

  beforeAll(async () => {
    const passwordHash = await bcrypt.hash(DEMO_PASSWORD, 10);

    const department = await prisma.department.upsert({
      where: { code: 'OPS' },
      create: { code: 'OPS', nameEn: 'OPS', nameAr: 'OPS' },
      update: {},
    });

    const users: Array<{
      email: string;
      employeeNumber: string;
      externalRef: string;
      fullNameEn: string;
    }> = [
      {
        email: EMPLOYEE_EMAIL,
        employeeNumber: 'E1001',
        externalRef: 'ext-e1001',
        fullNameEn: 'Noura Alharbi',
      },
      {
        email: OTHER_EMPLOYEE_EMAIL,
        employeeNumber: 'E1002',
        externalRef: 'ext-e1002',
        fullNameEn: 'Salem Alqahtani',
      },
    ];

    for (const user of users) {
      const row = await prisma.user.upsert({
        where: { email: user.email },
        create: {
          email: user.email,
          externalRef: user.externalRef,
          employeeNumber: user.employeeNumber,
          fullNameEn: user.fullNameEn,
          fullNameAr: user.fullNameEn,
          role: UserRole.EMPLOYEE,
          departmentId: department.id,
          passwordHash,
          isActive: true,
        },
        update: {
          passwordHash,
          role: UserRole.EMPLOYEE,
          isActive: true,
        },
      });
      if (user.email === EMPLOYEE_EMAIL) {
        employeeId = row.id;
      }
      if (user.email === OTHER_EMPLOYEE_EMAIL) {
        otherEmployeeId = row.id;
      }
    }

    await prisma.deviceToken.deleteMany({
      where: { token: E2E_TOKEN },
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
    await prisma.deviceToken.deleteMany({
      where: { token: E2E_TOKEN },
    });
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

  it('stores a device token for the current user (happy path)', async () => {
    const token = await login(EMPLOYEE_EMAIL);

    const response = await request(app.getHttpServer())
      .post(`${API}/device-tokens`)
      .set('Authorization', `Bearer ${token}`)
      .send({ platform: 'ANDROID', token: E2E_TOKEN })
      .expect(201);

    const body = response.body as ApiSuccessResponse<RegisterResult>;
    expect(body.data.platform).toBe('ANDROID');
    expect(body.data.isActive).toBe(true);

    const stored = await prisma.deviceToken.findUnique({
      where: {
        platform_token: { platform: 'ANDROID', token: E2E_TOKEN },
      },
    });
    expect(stored?.userId).toBe(employeeId);
  });

  it('upserts the same token and reassigns it to the new caller (edge)', async () => {
    const firstToken = await login(EMPLOYEE_EMAIL);
    const first = await request(app.getHttpServer())
      .post(`${API}/device-tokens`)
      .set('Authorization', `Bearer ${firstToken}`)
      .send({ platform: 'ANDROID', token: E2E_TOKEN })
      .expect(201);
    const firstBody = first.body as ApiSuccessResponse<RegisterResult>;

    const secondToken = await login(OTHER_EMPLOYEE_EMAIL);
    const second = await request(app.getHttpServer())
      .post(`${API}/device-tokens`)
      .set('Authorization', `Bearer ${secondToken}`)
      .send({ platform: 'ANDROID', token: E2E_TOKEN })
      .expect(201);
    const secondBody = second.body as ApiSuccessResponse<RegisterResult>;

    expect(secondBody.data.id).toBe(firstBody.data.id);

    const rows = await prisma.deviceToken.findMany({
      where: { token: E2E_TOKEN },
    });
    expect(rows).toHaveLength(1);
    expect(rows[0]?.userId).toBe(otherEmployeeId);
  });

  it('rejects invalid platform with 400 and anonymous with 401 (failure path)', async () => {
    const token = await login(EMPLOYEE_EMAIL);

    const invalid = await request(app.getHttpServer())
      .post(`${API}/device-tokens`)
      .set('Authorization', `Bearer ${token}`)
      .send({ platform: 'BLACKBERRY', token: E2E_TOKEN })
      .expect(400);
    expect((invalid.body as ApiErrorResponse).error.code).toBe(
      'VALIDATION_ERROR',
    );

    const unauthorized = await request(app.getHttpServer())
      .post(`${API}/device-tokens`)
      .send({ platform: 'ANDROID', token: E2E_TOKEN })
      .expect(401);
    expect((unauthorized.body as ApiErrorResponse).error.code).toBe(
      'UNAUTHORIZED',
    );
  });
});
