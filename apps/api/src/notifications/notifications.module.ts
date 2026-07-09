import { Module } from '@nestjs/common';
import { AudienceResolver } from './audience.resolver';
import { NotificationsController } from './notifications.controller';
import { NotificationsService } from './notifications.service';

@Module({
  controllers: [NotificationsController],
  providers: [NotificationsService, AudienceResolver],
  exports: [NotificationsService, AudienceResolver],
})
export class NotificationsModule {}
