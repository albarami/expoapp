import { ApiPropertyOptional } from '@nestjs/swagger';
import { NotificationPriority, NotificationStatus } from '@prisma/client';
import { Transform, Type } from 'class-transformer';
import {
  IsBoolean,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  Max,
  Min,
} from 'class-validator';
import {
  DEFAULT_NOTIFICATION_PAGE,
  DEFAULT_NOTIFICATION_PAGE_SIZE,
  MAX_NOTIFICATION_PAGE_SIZE,
} from '../notifications.types';

function toBoolean(value: unknown): boolean | undefined {
  if (value === undefined || value === null || value === '') {
    return undefined;
  }
  if (typeof value === 'boolean') {
    return value;
  }
  if (value === 'true' || value === '1') {
    return true;
  }
  if (value === 'false' || value === '0') {
    return false;
  }
  return undefined;
}

export class ListNotificationsQueryDto {
  @ApiPropertyOptional({ default: DEFAULT_NOTIFICATION_PAGE })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page: number = DEFAULT_NOTIFICATION_PAGE;

  @ApiPropertyOptional({ default: DEFAULT_NOTIFICATION_PAGE_SIZE })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(MAX_NOTIFICATION_PAGE_SIZE)
  pageSize: number = DEFAULT_NOTIFICATION_PAGE_SIZE;

  @ApiPropertyOptional({ enum: NotificationStatus })
  @IsOptional()
  @IsEnum(NotificationStatus)
  status?: NotificationStatus;

  @ApiPropertyOptional({ enum: NotificationPriority })
  @IsOptional()
  @IsEnum(NotificationPriority)
  priority?: NotificationPriority;

  @ApiPropertyOptional()
  @IsOptional()
  @Transform(({ value }) => toBoolean(value))
  @IsBoolean()
  unreadOnly?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  search?: string;
}
