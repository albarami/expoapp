import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';

export class AuthDepartmentDto {
  @ApiProperty()
  id!: string;

  @ApiProperty({ example: 'OPS' })
  code!: string;

  @ApiProperty({ example: 'Operations' })
  nameEn!: string;

  @ApiPropertyOptional({ example: 'العمليات', nullable: true })
  nameAr!: string | null;
}

export class AuthUserProfileDto {
  @ApiProperty()
  id!: string;

  @ApiProperty({ example: 'noura.alharbi@expo.sa' })
  email!: string;

  @ApiProperty({ example: 'Noura Alharbi' })
  fullNameEn!: string;

  @ApiPropertyOptional({ example: 'نورة الحربي', nullable: true })
  fullNameAr!: string | null;

  @ApiProperty({ enum: UserRole, example: UserRole.EMPLOYEE })
  role!: UserRole;

  @ApiPropertyOptional({ type: AuthDepartmentDto, nullable: true })
  department!: AuthDepartmentDto | null;
}

export class LoginResponseDto {
  @ApiProperty({ description: 'JWT access token' })
  accessToken!: string;

  @ApiProperty({ description: 'JWT refresh token (demo rotation)' })
  refreshToken!: string;

  @ApiProperty({ type: AuthUserProfileDto })
  user!: AuthUserProfileDto;
}

export class MeResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty({ example: 'admin@expo.sa' })
  email!: string;

  @ApiProperty({ example: 'Expo System Admin' })
  fullNameEn!: string;

  @ApiPropertyOptional({ example: 'مدير النظام', nullable: true })
  fullNameAr!: string | null;

  @ApiProperty({ enum: UserRole, example: UserRole.SYSTEM_ADMIN })
  role!: UserRole;

  @ApiProperty({
    type: [String],
    example: ['notifications:create', 'notifications:publish', 'audit:read'],
  })
  permissions!: string[];

  @ApiPropertyOptional({ type: AuthDepartmentDto, nullable: true })
  department!: AuthDepartmentDto | null;
}

export class LogoutResponseDto {
  @ApiProperty({ example: true })
  success!: boolean;
}
