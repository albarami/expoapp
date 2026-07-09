import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsEnum, IsOptional, IsString, MaxLength } from 'class-validator';
import {
  ApprovalDecisionInput,
  MAX_APPROVAL_COMMENT_LENGTH,
} from '../approvals.types';

export class DecideApprovalDto {
  @ApiProperty({ enum: ApprovalDecisionInput })
  @IsEnum(ApprovalDecisionInput)
  decision!: ApprovalDecisionInput;

  @ApiPropertyOptional({
    maxLength: MAX_APPROVAL_COMMENT_LENGTH,
    description: 'Required when decision is REJECTED; optional when APPROVED',
  })
  @IsOptional()
  @IsString()
  @MaxLength(MAX_APPROVAL_COMMENT_LENGTH)
  comment?: string;
}
