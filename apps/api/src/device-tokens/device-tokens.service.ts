import { Injectable } from '@nestjs/common';
import { AuthUser } from '../auth/types/auth-user';
import { PrismaService } from '../prisma/prisma.service';
import { RegisterDeviceTokenDto } from './dto/register-device-token.dto';
import { RegisterDeviceTokenResult } from './device-tokens.types';

/**
 * Stores device push tokens for Phase 2 push readiness (docs 10 + 15).
 * Upserts on the (platform, token) unique pair so re-registration after
 * reinstall or user switch reassigns the token to the current user.
 */
@Injectable()
export class DeviceTokensService {
  constructor(private readonly prisma: PrismaService) {}

  async register(
    user: AuthUser,
    dto: RegisterDeviceTokenDto,
  ): Promise<RegisterDeviceTokenResult> {
    const token = dto.token.trim();

    const row = await this.prisma.deviceToken.upsert({
      where: {
        platform_token: {
          platform: dto.platform,
          token,
        },
      },
      create: {
        userId: user.id,
        platform: dto.platform,
        token,
        isActive: true,
      },
      update: {
        userId: user.id,
        isActive: true,
      },
    });

    return {
      id: row.id,
      platform: row.platform,
      isActive: row.isActive,
      createdAt: row.createdAt.toISOString(),
      updatedAt: row.updatedAt.toISOString(),
    };
  }
}
