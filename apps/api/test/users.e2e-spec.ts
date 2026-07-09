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
const SECURITY_EMAIL = 'reem.security@expo.sa';
const ADMIN_EMAIL = 'admin@expo.sa';
const INACTIVE_EMAIL = 'users.e2e.inactive@expo.sa';
const API = '/api/v1';

type UserListItem = {
  id: string;
  email: string;
  fullNameEn: string;
  fullNameAr: string | null;
  employeeNumber: string;
  role: UserRole;
  department: { id: string; code: string } | null;
};

type Pagination = {
  page: number;
  pageSize: number;
  total: number;
  totalPages: number;
};

describeDb('Users lookup (e2e T-FIX-01)', () => {
  let app: INestApplication<App>;
  const prisma = new PrismaClient();

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
      isActive: boolean;
    }> = [
      {
        email: EMPLOYEE_EMAIL,
        role: UserRole.EMPLOYEE,
        employeeNumber: 'E1001',
        externalRef: 'ext-e1001',
        fullNameEn: 'Noura Alharbi',
        departmentCode: 'OPS',
        isActive: true,
      },
      {
        email: SECURITY_EMAIL,
        role: UserRole.SECURITY_ADMIN,
        employeeNumber: 'S3001',
        externalRef: 'ext-s3001',
        fullNameEn: 'Reem Almutairi',
        departmentCode: 'SEC',
        isActive: true,
      },
      {
        email: ADMIN_EMAIL,
        role: UserRole.SYSTEM_ADMIN,
        employeeNumber: 'A9001',
        externalRef: 'ext-a9001',
        fullNameEn: 'Expo System Admin',
        departmentCode: 'TECH',
        isActive: true,
      },
      {
        email: INACTIVE_EMAIL,
        role: UserRole.EMPLOYEE,
        employeeNumber: 'E9901',
        externalRef: 'ext-e9901',
        fullNameEn: 'Users E2E Inactive',
        departmentCode: 'OPS',
        isActive: false,
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
          isActive: user.isActive,
        },
        update: {
          passwordHash,
          role: user.role,
          isActive: user.isActive,
          departmentId,
          fullNameEn: user.fullNameEn,
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

  async function login(email: string): Promise<string> {
    const response = await request(app.getHttpServer())
      .post(`${API}/auth/login`)
      .send({ email, password: DEMO_PASSWORD })
      .expect(200);
    return (response.body as ApiSuccessResponse<LoginResponseDto>).data
      .accessToken;
  }

  it('returns paginated active users to system admin (happy path)', async () => {
    const token = await login(ADMIN_EMAIL);

    const response = await request(app.getHttpServer())
      .get(`${API}/users`)
      .query({ page: 1, pageSize: 50 })
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    const body = response.body as ApiSuccessResponse<UserListItem[]> & {
      pagination: Pagination;
    };
    expect(body.pagination.page).toBe(1);
    expect(body.pagination.total).toBeGreaterThanOrEqual(3);
    expect(body.data.some((user) => user.email === EMPLOYEE_EMAIL)).toBe(true);
    expect(body.data.every((user) => user.email !== INACTIVE_EMAIL)).toBe(true);

    const employee = body.data.find((user) => user.email === EMPLOYEE_EMAIL);
    expect(employee).toEqual(
      expect.objectContaining({
        id: expect.any(String) as string,
        fullNameEn: 'Noura Alharbi',
        employeeNumber: 'E1001',
        role: UserRole.EMPLOYEE,
        department: expect.objectContaining({ code: 'OPS' }) as object,
      }),
    );
  });

  it('supports search by name/email for the audience picker (edge)', async () => {
    const token = await login(ADMIN_EMAIL);

    const response = await request(app.getHttpServer())
      .get(`${API}/users`)
      .query({ search: 'noura' })
      .set('Authorization', `Bearer ${token}`)
      .expect(200);

    const body = response.body as ApiSuccessResponse<UserListItem[]>;
    expect(body.data.length).toBeGreaterThanOrEqual(1);
    expect(
      body.data.every((user) =>
        `${user.fullNameEn} ${user.email}`.toLowerCase().includes('noura'),
      ),
    ).toBe(true);

    const noMatch = await request(app.getHttpServer())
      .get(`${API}/users`)
      .query({ search: 'no-user-matches-this-string' })
      .set('Authorization', `Bearer ${token}`)
      .expect(200);
    const noMatchBody = noMatch.body as ApiSuccessResponse<UserListItem[]> & {
      pagination: Pagination;
    };
    expect(noMatchBody.data).toEqual([]);
    expect(noMatchBody.pagination.total).toBe(0);
  });

  it('allows security admin (optional admin role per docs 06/19)', async () => {
    const token = await login(SECURITY_EMAIL);

    await request(app.getHttpServer())
      .get(`${API}/users`)
      .set('Authorization', `Bearer ${token}`)
      .expect(200);
  });

  it('rejects employees with 403 and anonymous with 401 (failure path)', async () => {
    const employeeToken = await login(EMPLOYEE_EMAIL);

    const forbidden = await request(app.getHttpServer())
      .get(`${API}/users`)
      .set('Authorization', `Bearer ${employeeToken}`)
      .expect(403);
    expect((forbidden.body as ApiErrorResponse).error.code).toBe('FORBIDDEN');

    const unauthorized = await request(app.getHttpServer())
      .get(`${API}/users`)
      .expect(401);
    expect((unauthorized.body as ApiErrorResponse).error.code).toBe(
      'UNAUTHORIZED',
    );
  });
});
