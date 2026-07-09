import { plainToInstance, Transform, Type } from 'class-transformer';
import {
  IsEnum,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  Max,
  Min,
  validateSync,
} from 'class-validator';

enum NodeEnv {
  Local = 'local',
  Demo = 'demo',
  Staging = 'staging',
  Production = 'production',
  Test = 'test',
  Development = 'development',
}

enum FusionMode {
  Mock = 'mock',
  Fusion = 'fusion',
}

enum PushMode {
  Mock = 'mock',
  Fcm = 'fcm',
}

function toInteger(value: unknown, fallback: number): number {
  if (typeof value === 'number' && Number.isInteger(value)) {
    return value;
  }
  if (typeof value === 'string' && value.trim() !== '') {
    const parsed = Number.parseInt(value, 10);
    if (Number.isInteger(parsed)) {
      return parsed;
    }
  }
  return fallback;
}

export class EnvironmentVariables {
  @IsEnum(NodeEnv)
  NODE_ENV: NodeEnv = NodeEnv.Local;

  @Transform(({ value }) => toInteger(value, 3000))
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(65535)
  PORT = 3000;

  @IsString()
  @IsNotEmpty()
  API_PREFIX = 'api/v1';

  @IsString()
  @IsNotEmpty()
  DATABASE_URL!: string;

  @IsString()
  @IsNotEmpty()
  REDIS_URL!: string;

  @IsString()
  @IsNotEmpty()
  JWT_SECRET!: string;

  @IsString()
  @IsNotEmpty()
  JWT_EXPIRES_IN = '8h';

  @IsString()
  @IsNotEmpty()
  JWT_REFRESH_EXPIRES_IN = '30d';

  @IsString()
  @IsNotEmpty()
  CORS_ORIGINS!: string;

  @IsEnum(FusionMode)
  FUSION_MODE: FusionMode = FusionMode.Mock;

  @IsOptional()
  @IsString()
  FUSION_BASE_URL?: string;

  @IsOptional()
  @IsString()
  FUSION_CLIENT_ID?: string;

  @IsOptional()
  @IsString()
  FUSION_CLIENT_SECRET?: string;

  @IsOptional()
  @IsString()
  FUSION_TOKEN_URL?: string;

  @IsOptional()
  @IsString()
  FUSION_SCOPE?: string;

  @IsEnum(PushMode)
  PUSH_MODE: PushMode = PushMode.Mock;

  @IsOptional()
  @IsString()
  FCM_SERVER_KEY?: string;

  @IsOptional()
  @IsString()
  APNS_KEY_ID?: string;

  @IsOptional()
  @IsString()
  APNS_TEAM_ID?: string;

  @IsOptional()
  @IsString()
  APNS_BUNDLE_ID?: string;

  @IsString()
  @IsNotEmpty()
  LOG_LEVEL = 'debug';

  @Transform(({ value }) => toInteger(value, 30000))
  @Type(() => Number)
  @IsInt()
  @Min(1000)
  NOTIFICATION_SCHEDULER_INTERVAL_MS = 30000;
}

export function validateEnv(
  config: Record<string, unknown>,
): EnvironmentVariables {
  const validated = plainToInstance(EnvironmentVariables, config, {
    enableImplicitConversion: true,
    exposeDefaultValues: true,
  });

  const errors = validateSync(validated, {
    skipMissingProperties: false,
    whitelist: true,
    forbidNonWhitelisted: false,
  });

  if (errors.length > 0) {
    const messages = errors
      .map((error) => {
        const constraints = error.constraints
          ? Object.values(error.constraints).join(', ')
          : 'invalid';
        return `${error.property}: ${constraints}`;
      })
      .join('; ');
    throw new Error(`Environment validation failed: ${messages}`);
  }

  return validated;
}
