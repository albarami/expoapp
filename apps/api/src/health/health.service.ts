import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Redis from 'ioredis';
import { PrismaService } from '../prisma/prisma.service';
import { HealthCheckResult } from './health.types';

@Injectable()
export class HealthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly configService: ConfigService,
  ) {}

  async check(): Promise<HealthCheckResult> {
    const database = await this.checkDatabase();
    const redis = await this.checkRedis();
    const fusionMode = this.configService.get<string>('FUSION_MODE', 'mock');

    const status: HealthCheckResult['status'] =
      database === 'ok' && (redis === 'ok' || redis === 'disabled')
        ? 'ok'
        : 'degraded';

    return {
      status,
      database,
      redis,
      fusionMode,
    };
  }

  private async checkDatabase(): Promise<'ok' | 'error'> {
    try {
      await this.prisma.$queryRaw`SELECT 1`;
      return 'ok';
    } catch {
      return 'error';
    }
  }

  private async checkRedis(): Promise<'ok' | 'error' | 'disabled'> {
    const redisUrl = this.configService.get<string>('REDIS_URL');
    if (!redisUrl) {
      return 'disabled';
    }

    const client = new Redis(redisUrl, {
      maxRetriesPerRequest: 1,
      connectTimeout: 2000,
      enableOfflineQueue: false,
      lazyConnect: true,
    });

    try {
      await client.connect();
      const pong = await client.ping();
      return pong === 'PONG' ? 'ok' : 'error';
    } catch {
      return 'error';
    } finally {
      client.disconnect(false);
    }
  }
}
