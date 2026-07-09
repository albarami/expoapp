import { ConfigService } from '@nestjs/config';
import { Test, TestingModule } from '@nestjs/testing';
import { PrismaService } from '../prisma/prisma.service';
import { HealthService } from './health.service';

const mockPing = jest.fn();
const mockConnect = jest.fn();
const mockDisconnect = jest.fn();

jest.mock('ioredis', () => {
  return jest.fn().mockImplementation(() => ({
    connect: mockConnect,
    ping: mockPing,
    disconnect: mockDisconnect,
  }));
});

describe('HealthService', () => {
  let service: HealthService;
  let prisma: { $queryRaw: jest.Mock };
  let configGet: jest.Mock;

  beforeEach(async () => {
    jest.clearAllMocks();
    mockConnect.mockResolvedValue(undefined);
    mockPing.mockResolvedValue('PONG');
    mockDisconnect.mockReturnValue(undefined);

    prisma = {
      $queryRaw: jest.fn().mockResolvedValue([{ '?column?': 1 }]),
    };
    configGet = jest.fn((key: string, fallback?: string) => {
      if (key === 'REDIS_URL') {
        return 'redis://localhost:6380';
      }
      if (key === 'FUSION_MODE') {
        return 'mock';
      }
      return fallback;
    });

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        HealthService,
        { provide: PrismaService, useValue: prisma },
        { provide: ConfigService, useValue: { get: configGet } },
      ],
    }).compile();

    service = module.get(HealthService);
  });

  it('returns ok when database and redis are healthy', async () => {
    await expect(service.check()).resolves.toEqual({
      status: 'ok',
      database: 'ok',
      redis: 'ok',
      fusionMode: 'mock',
    });
  });

  it('returns degraded when database fails', async () => {
    prisma.$queryRaw.mockRejectedValue(new Error('db down'));

    await expect(service.check()).resolves.toEqual({
      status: 'degraded',
      database: 'error',
      redis: 'ok',
      fusionMode: 'mock',
    });
  });

  it('returns degraded when redis fails', async () => {
    mockPing.mockRejectedValue(new Error('redis down'));

    await expect(service.check()).resolves.toEqual({
      status: 'degraded',
      database: 'ok',
      redis: 'error',
      fusionMode: 'mock',
    });
  });

  it('treats missing redis url as disabled', async () => {
    configGet.mockImplementation((key: string, fallback?: string) => {
      if (key === 'REDIS_URL') {
        return undefined;
      }
      if (key === 'FUSION_MODE') {
        return 'mock';
      }
      return fallback;
    });

    await expect(service.check()).resolves.toEqual({
      status: 'ok',
      database: 'ok',
      redis: 'disabled',
      fusionMode: 'mock',
    });
  });
});
