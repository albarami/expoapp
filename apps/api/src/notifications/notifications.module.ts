import { Module } from '@nestjs/common';
import { AudienceResolver } from './audience.resolver';
import { NotificationsController } from './notifications.controller';
import { NotificationsService } from './notifications.service';
import { ScheduledNotificationsService } from './scheduled-notifications.service';

@Module({
  controllers: [NotificationsController],
  providers: [
    NotificationsService,
    AudienceResolver,
    ScheduledNotificationsService,
  ],
  exports: [
    NotificationsService,
    AudienceResolver,
    ScheduledNotificationsService,
  ],
})
export class NotificationsModule {}
