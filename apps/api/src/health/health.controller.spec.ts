import { Test, TestingModule } from '@nestjs/testing';
import { HealthController } from './health.controller';
import { HealthService } from './health.service';
import { HealthCheckResult } from './health.types';

describe('HealthController', () => {
  let controller: HealthController;
  const healthResult: HealthCheckResult = {
    status: 'ok',
    database: 'ok',
    redis: 'ok',
    fusionMode: 'mock',
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [HealthController],
      providers: [
        {
          provide: HealthService,
          useValue: {
            check: jest.fn().mockResolvedValue(healthResult),
          },
        },
      ],
    }).compile();

    controller = module.get<HealthController>(HealthController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  it('should return health check result from service', async () => {
    await expect(controller.getHealth()).resolves.toEqual(healthResult);
  });
});
