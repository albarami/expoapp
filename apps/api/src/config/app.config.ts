import { registerAs } from '@nestjs/config';

export default registerAs('app', () => ({
  nodeEnv: process.env.NODE_ENV ?? 'local',
  port: Number(process.env.PORT ?? 3000),
  apiPrefix: process.env.API_PREFIX ?? 'api/v1',
  corsOrigins: process.env.CORS_ORIGINS ?? '',
  logLevel: process.env.LOG_LEVEL ?? 'debug',
  fusionMode: process.env.FUSION_MODE ?? 'mock',
  pushMode: process.env.PUSH_MODE ?? 'mock',
}));
