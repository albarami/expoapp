import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import {
  IsDateString,
  IsEmail,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  Min,
} from 'class-validator';
import {
  DEFAULT_AUDIT_PAGE,
  DEFAULT_AUDIT_PAGE_SIZE,
  MAX_AUDIT_PAGE_SIZE,
} from '../audit.types';

export class ListAuditLogsQueryDto {
  @ApiPropertyOptional({ default: DEFAULT_AUDIT_PAGE })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page: number = DEFAULT_AUDIT_PAGE;

  @ApiPropertyOptional({ default: DEFAULT_AUDIT_PAGE_SIZE })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(MAX_AUDIT_PAGE_SIZE)
  pageSize: number = DEFAULT_AUDIT_PAGE_SIZE;

  @ApiPropertyOptional({ format: 'uuid' })
  @IsOptional()
  @IsUUID()
  actorId?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsEmail()
  actorEmail?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  action?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  entityType?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  entityId?: string;

  @ApiPropertyOptional({
    description: 'Inclusive lower bound (ISO datetime)',
    example: '2026-07-01T00:00:00.000Z',
  })
  @IsOptional()
  @IsDateString()
  from?: string;

  @ApiPropertyOptional({
    description: 'Inclusive upper bound (ISO datetime)',
    example: '2026-07-31T23:59:59.999Z',
  })
  @IsOptional()
  @IsDateString()
  to?: string;
}
