import { ApiProperty } from '@nestjs/swagger';
import { IsEnum, IsNotEmpty, IsString, MaxLength } from 'class-validator';

/** Supported push platforms (doc 15: FCM Android / APNs iOS in Phase 2). */
export enum DeviceTokenPlatform {
  ANDROID = 'ANDROID',
  IOS = 'IOS',
  WEB = 'WEB',
}

const MAX_TOKEN_LENGTH = 512;

export class RegisterDeviceTokenDto {
  @ApiProperty({
    enum: DeviceTokenPlatform,
    example: DeviceTokenPlatform.ANDROID,
  })
  @IsEnum(DeviceTokenPlatform)
  platform!: DeviceTokenPlatform;

  @ApiProperty({
    description: 'Opaque push registration token from the device',
    example: 'fcm-registration-token',
    maxLength: MAX_TOKEN_LENGTH,
  })
  @IsString()
  @IsNotEmpty()
  @MaxLength(MAX_TOKEN_LENGTH)
  token!: string;
}
