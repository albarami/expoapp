import { MiddlewareConsumer, Module, NestModule } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AccessRequestsModule } from './access-requests/access-requests.module';
import { ApprovalsModule } from './approvals/approvals.module';
import { AuditModule } from './audit/audit.module';
import { AuthModule } from './auth/auth.module';
import { TraceIdMiddleware } from './common/middleware/trace-id.middleware';
import appConfig from './config/app.config';
import databaseConfig from './config/database.config';
import { validateEnv } from './config/env.validation';
import jwtConfig from './config/jwt.config';
import { DashboardModule } from './dashboard/dashboard.module';
import { FusionModule } from './fusion/fusion.module';
import { HealthModule } from './health/health.module';
import { NotificationsModule } from './notifications/notifications.module';
import { PrismaModule } from './prisma/prisma.module';
import { ReferenceDataModule } from './reference-data/reference-data.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      cache: true,
      expandVariables: true,
      load: [appConfig, databaseConfig, jwtConfig],
      validate: validateEnv,
    }),
    PrismaModule,
    AuditModule,
    FusionModule,
    AuthModule,
    ReferenceDataModule,
    DashboardModule,
    NotificationsModule,
    AccessRequestsModule,
    ApprovalsModule,
    HealthModule,
  ],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer): void {
    consumer.apply(TraceIdMiddleware).forRoutes('{*path}');
  }
}
