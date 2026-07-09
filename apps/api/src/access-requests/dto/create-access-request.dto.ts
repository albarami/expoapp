import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { AccessDuration, AccessUrgency } from '@prisma/client';
import {
  IsDateString,
  IsEnum,
  IsNotEmpty,
  IsString,
  IsUUID,
  MaxLength,
  MinLength,
  ValidateIf,
} from 'class-validator';
import {
  MAX_JUSTIFICATION_LENGTH,
  MIN_JUSTIFICATION_LENGTH,
} from '../access-requests.types';

export class CreateAccessRequestDto {
  @ApiProperty({ format: 'uuid' })
  @IsUUID()
  systemId!: string;

  @ApiProperty({ format: 'uuid' })
  @IsUUID()
  securityRoleId!: string;

  @ApiProperty({
    minLength: MIN_JUSTIFICATION_LENGTH,
    maxLength: MAX_JUSTIFICATION_LENGTH,
  })
  @IsString()
  @IsNotEmpty()
  @MinLength(MIN_JUSTIFICATION_LENGTH)
  @MaxLength(MAX_JUSTIFICATION_LENGTH)
  businessJustification!: string;

  @ApiProperty({ enum: AccessDuration })
  @IsEnum(AccessDuration)
  accessDuration!: AccessDuration;

  @ApiProperty({
    description: 'Access start date',
    example: '2026-07-10T00:00:00.000Z',
  })
  @IsDateString()
  startDate!: string;

  @ApiPropertyOptional({
    description: 'Required when accessDuration is TEMPORARY',
    example: '2026-08-10T00:00:00.000Z',
  })
  @ValidateIf(
    (dto: CreateAccessRequestDto) =>
      dto.accessDuration === AccessDuration.TEMPORARY,
  )
  @IsDateString()
  endDate?: string;

  @ApiProperty({ enum: AccessUrgency })
  @IsEnum(AccessUrgency)
  urgency!: AccessUrgency;
}
