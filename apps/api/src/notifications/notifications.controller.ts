import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
  Req,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiCreatedResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import type { Request } from 'express';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import type { AuthUser } from '../auth/types/auth-user';
import { CancelNotificationDto } from './dto/cancel-notification.dto';
import { CreateNotificationDto } from './dto/create-notification.dto';
import { ListNotificationsQueryDto } from './dto/list-notifications-query.dto';
import { NotificationsService } from './notifications.service';

@ApiTags('notifications')
@ApiBearerAuth('bearer')
@Controller('notifications')
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Get()
  @ApiOperation({ summary: 'List notifications for the current user' })
  @ApiOkResponse({ description: 'Paginated notification list' })
  @ApiUnauthorizedResponse({ description: 'Missing or invalid bearer token' })
  async list(
    @CurrentUser() user: AuthUser,
    @Query() query: ListNotificationsQueryDto,
  ) {
    const result = await this.notificationsService.listForUser(user, query);
    const totalPages =
      result.total === 0 ? 0 : Math.ceil(result.total / result.pageSize);

    return {
      data: result.items,
      pagination: {
        page: result.page,
        pageSize: result.pageSize,
        total: result.total,
        totalPages,
      },
    };
  }

  @Post()
  @Roles(UserRole.SYSTEM_ADMIN, UserRole.SECURITY_ADMIN)
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Create and optionally publish a notification' })
  @ApiCreatedResponse({ description: 'Notification created' })
  create(
    @CurrentUser() user: AuthUser,
    @Body() dto: CreateNotificationDto,
    @Req() request: Request,
  ) {
    return this.notificationsService.createNotification(user, dto, request);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get notification detail for the current user' })
  @ApiOkResponse({ description: 'Notification detail' })
  getOne(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.notificationsService.getForUser(user, id);
  }

  @Patch(':id/read')
  @ApiOperation({ summary: 'Mark notification as read for the current user' })
  @ApiOkResponse({ description: 'Notification marked read' })
  markRead(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Req() request: Request,
  ) {
    return this.notificationsService.markAsRead(user, id, request);
  }

  @Get(':id/stats')
  @Roles(UserRole.SYSTEM_ADMIN, UserRole.SECURITY_ADMIN)
  @ApiOperation({ summary: 'Notification delivery/read statistics' })
  @ApiOkResponse({ description: 'Notification stats' })
  getStats(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.notificationsService.getStats(user, id);
  }

  @Post(':id/cancel')
  @Roles(UserRole.SYSTEM_ADMIN)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Cancel a notification' })
  @ApiOkResponse({ description: 'Notification cancelled' })
  cancel(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: CancelNotificationDto,
    @Req() request: Request,
  ) {
    return this.notificationsService.cancel(user, id, dto, request);
  }
}
