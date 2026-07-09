import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsNotEmpty, IsString, MinLength } from 'class-validator';

export class LoginDto {
  @ApiProperty({
    example: 'noura.alharbi@expo.sa',
    description: 'Demo user email',
  })
  @IsEmail()
  @IsNotEmpty()
  email!: string;

  @ApiProperty({
    example: 'Password123!',
    description: 'Demo password (seeded users)',
  })
  @IsString()
  @IsNotEmpty()
  @MinLength(1)
  password!: string;
}
