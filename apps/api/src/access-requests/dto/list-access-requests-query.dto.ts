import { ApiPropertyOptional } from '@nestjs/swagger';
import { AccessRequestStatus, AccessUrgency } from '@prisma/client';
import { Type } from 'class-transformer';
import { IsEnum, IsInt, IsOptional, IsUUID, Max, Min } from 'class-validator';
import {
  DEFAULT_ACCESS_REQUEST_PAGE,
  DEFAULT_ACCESS_REQUEST_PAGE_SIZE,
  MAX_ACCESS_REQUEST_PAGE_SIZE,
} from '../access-requests.types';

export class ListAccessRequestsQueryDto {
  @ApiPropertyOptional({ default: DEFAULT_ACCESS_REQUEST_PAGE })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page: number = DEFAULT_ACCESS_REQUEST_PAGE;

  @ApiPropertyOptional({ default: DEFAULT_ACCESS_REQUEST_PAGE_SIZE })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(MAX_ACCESS_REQUEST_PAGE_SIZE)
  pageSize: number = DEFAULT_ACCESS_REQUEST_PAGE_SIZE;

  @ApiPropertyOptional({ enum: AccessRequestStatus })
  @IsOptional()
  @IsEnum(AccessRequestStatus)
  status?: AccessRequestStatus;

  @ApiPropertyOptional({ enum: AccessUrgency })
  @IsOptional()
  @IsEnum(AccessUrgency)
  urgency?: AccessUrgency;

  @ApiPropertyOptional({ format: 'uuid' })
  @IsOptional()
  @IsUUID()
  systemId?: string;

  @ApiPropertyOptional({ format: 'uuid' })
  @IsOptional()
  @IsUUID()
  requesterId?: string;
}
