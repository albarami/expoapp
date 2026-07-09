import 'reflect-metadata';
import { validateEnv } from './env.validation';

describe('validateEnv', () => {
  const validEnv = {
    NODE_ENV: 'local',
    PORT: '3000',
    API_PREFIX: 'api/v1',
    DATABASE_URL: 'postgresql://expoapp:expoapp@localhost:5433/expoapp',
    REDIS_URL: 'redis://localhost:6380',
    JWT_SECRET: 'test-secret',
    JWT_EXPIRES_IN: '8h',
    JWT_REFRESH_EXPIRES_IN: '30d',
    CORS_ORIGINS: 'http://localhost:3000',
    FUSION_MODE: 'mock',
    PUSH_MODE: 'mock',
    LOG_LEVEL: 'debug',
  };

  it('accepts a valid environment', () => {
    const result = validateEnv(validEnv);
    expect(result.DATABASE_URL).toContain('postgresql://');
    expect(result.PORT).toBe(3000);
    expect(result.FUSION_MODE).toBe('mock');
  });

  it('rejects missing DATABASE_URL', () => {
    const rest = { ...validEnv };
    delete (rest as { DATABASE_URL?: string }).DATABASE_URL;
    expect(() => validateEnv(rest)).toThrow(/DATABASE_URL/);
  });

  it('rejects missing JWT_SECRET', () => {
    const rest = { ...validEnv };
    delete (rest as { JWT_SECRET?: string }).JWT_SECRET;
    expect(() => validateEnv(rest)).toThrow(/JWT_SECRET/);
  });

  it('rejects invalid FUSION_MODE', () => {
    expect(() =>
      validateEnv({
        ...validEnv,
        FUSION_MODE: 'invalid',
      }),
    ).toThrow(/FUSION_MODE/);
  });
});
