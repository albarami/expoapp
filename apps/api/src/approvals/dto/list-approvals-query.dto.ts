import { ApiPropertyOptional } from '@nestjs/swagger';
import { ApprovalDecision } from '@prisma/client';
import { Type } from 'class-transformer';
import { IsEnum, IsInt, IsOptional, Max, Min } from 'class-validator';
import {
  DEFAULT_APPROVALS_PAGE,
  DEFAULT_APPROVALS_PAGE_SIZE,
  MAX_APPROVALS_PAGE_SIZE,
} from '../approvals.types';

export class ListApprovalsQueryDto {
  @ApiPropertyOptional({ default: DEFAULT_APPROVALS_PAGE })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page: number = DEFAULT_APPROVALS_PAGE;

  @ApiPropertyOptional({ default: DEFAULT_APPROVALS_PAGE_SIZE })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(MAX_APPROVALS_PAGE_SIZE)
  pageSize: number = DEFAULT_APPROVALS_PAGE_SIZE;

  @ApiPropertyOptional({
    enum: ApprovalDecision,
    description: 'Filter by task decision; typically PENDING for the queue',
  })
  @IsOptional()
  @IsEnum(ApprovalDecision)
  status?: ApprovalDecision;
}
