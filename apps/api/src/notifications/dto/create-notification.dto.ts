import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { AudienceType, NotificationPriority } from '@prisma/client';
import { Type } from 'class-transformer';
import {
  IsBoolean,
  IsDateString,
  IsEnum,
  IsNotEmpty,
  IsObject,
  IsOptional,
  IsString,
  MaxLength,
  MinLength,
  ValidateIf,
} from 'class-validator';

export class CreateNotificationDto {
  @ApiProperty({ minLength: 3, maxLength: 120 })
  @IsString()
  @MinLength(3)
  @MaxLength(120)
  titleEn!: string;

  @ApiPropertyOptional({ minLength: 3, maxLength: 120 })
  @IsOptional()
  @IsString()
  @MinLength(3)
  @MaxLength(120)
  titleAr?: string;

  @ApiProperty({ minLength: 3, maxLength: 2000 })
  @IsString()
  @MinLength(3)
  @MaxLength(2000)
  bodyEn!: string;

  @ApiPropertyOptional({ minLength: 3, maxLength: 2000 })
  @IsOptional()
  @IsString()
  @MinLength(3)
  @MaxLength(2000)
  bodyAr?: string;

  @ApiProperty({ enum: NotificationPriority })
  @IsEnum(NotificationPriority)
  priority!: NotificationPriority;

  @ApiProperty({ enum: AudienceType })
  @IsEnum(AudienceType)
  audienceType!: AudienceType;

  @ApiProperty({
    description: 'Audience filter matching audienceType',
    example: { departmentCodes: ['OPS'] },
  })
  @IsObject()
  @IsNotEmpty()
  audienceFilter!: Record<string, unknown>;

  @ApiPropertyOptional({ default: true })
  @IsOptional()
  @IsBoolean()
  @Type(() => Boolean)
  publishNow?: boolean = true;

  @ApiPropertyOptional({
    description: 'Required when publishNow is false',
  })
  @ValidateIf((dto: CreateNotificationDto) => dto.publishNow === false)
  @IsDateString()
  publishAt?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsDateString()
  expiresAt?: string;
}
