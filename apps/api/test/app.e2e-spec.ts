import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { NextFunction, Request, Response } from 'express';
import request from 'supertest';
import { App } from 'supertest/types';
import { GlobalExceptionFilter } from './../src/common/filters/http-exception.filter';
import { ResponseEnvelopeInterceptor } from './../src/common/interceptors/response-envelope.interceptor';
import { TraceIdMiddleware } from './../src/common/middleware/trace-id.middleware';
import { ApiSuccessResponse } from './../src/common/types/api-response';
import { HealthController } from './../src/health/health.controller';
import { HealthService } from './../src/health/health.service';
import { HealthCheckResult } from './../src/health/health.types';

describe('HealthController (e2e)', () => {
  let app: INestApplication<App>;

  beforeEach(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      controllers: [HealthController],
      providers: [
        {
          provide: HealthService,
          useValue: {
            check: jest.fn().mockResolvedValue({
              status: 'ok',
              database: 'ok',
              redis: 'ok',
              fusionMode: 'mock',
            }),
          },
        },
      ],
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

  afterEach(async () => {
    await app.close();
  });

  it('/api/v1/health (GET) returns enveloped health payload', async () => {
    const response = await request(app.getHttpServer())
      .get('/api/v1/health')
      .expect(200);

    const body = response.body as ApiSuccessResponse<HealthCheckResult>;
    const traceIdHeader = response.headers['x-trace-id'];
    const traceId =
      typeof traceIdHeader === 'string' ? traceIdHeader : String(traceIdHeader);

    expect(traceId.length).toBeGreaterThan(0);
    expect(body.data).toEqual({
      status: 'ok',
      database: 'ok',
      redis: 'ok',
      fusionMode: 'mock',
    });
    expect(body.meta.traceId).toBe(traceId);
    expect(body.meta.timestamp).toEqual(expect.any(String));
  });

  it('reuses incoming x-trace-id header', async () => {
    const response = await request(app.getHttpServer())
      .get('/api/v1/health')
      .set('x-trace-id', 'client-trace-123')
      .expect(200);

    const body = response.body as ApiSuccessResponse<HealthCheckResult>;

    expect(response.headers['x-trace-id']).toBe('client-trace-123');
    expect(body.meta.traceId).toBe('client-trace-123');
  });
});
