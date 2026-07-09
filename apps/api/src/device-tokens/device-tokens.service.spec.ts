import { UserRole } from '@prisma/client';
import { AuthUser } from '../auth/types/auth-user';
import { DeviceTokensService } from './device-tokens.service';
import { DeviceTokenPlatform } from './dto/register-device-token.dto';

function makeUser(id = 'emp-1'): AuthUser {
  return {
    id,
    email: 'noura.alharbi@expo.sa',
    fullNameEn: 'Noura',
    fullNameAr: null,
    role: UserRole.EMPLOYEE,
    departmentId: null,
    department: null,
    isActive: true,
    permissions: [],
  };
}

const storedRow = {
  id: 'dt-1',
  userId: 'emp-1',
  platform: 'ANDROID',
  token: 'fcm-token-1',
  isActive: true,
  createdAt: new Date('2026-07-01T00:00:00.000Z'),
  updatedAt: new Date('2026-07-01T00:00:00.000Z'),
};

describe('DeviceTokensService', () => {
  it('registers a new token via upsert (happy path)', async () => {
    const upsert = jest.fn().mockResolvedValue(storedRow);
    const prisma = { deviceToken: { upsert } };
    const service = new DeviceTokensService(prisma as never);

    const result = await service.register(makeUser(), {
      platform: DeviceTokenPlatform.ANDROID,
      token: 'fcm-token-1',
    });

    expect(result).toEqual({
      id: 'dt-1',
      platform: 'ANDROID',
      isActive: true,
      createdAt: '2026-07-01T00:00:00.000Z',
      updatedAt: '2026-07-01T00:00:00.000Z',
    });
    expect(upsert).toHaveBeenCalledWith({
      where: {
        platform_token: { platform: 'ANDROID', token: 'fcm-token-1' },
      },
      create: {
        userId: 'emp-1',
        platform: 'ANDROID',
        token: 'fcm-token-1',
        isActive: true,
      },
      update: {
        userId: 'emp-1',
        isActive: true,
      },
    });
  });

  it('trims tokens and reassigns an existing token to the caller (edge)', async () => {
    const upsert = jest.fn().mockResolvedValue({
      ...storedRow,
      userId: 'emp-2',
    });
    const prisma = { deviceToken: { upsert } };
    const service = new DeviceTokensService(prisma as never);

    await service.register(makeUser('emp-2'), {
      platform: DeviceTokenPlatform.ANDROID,
      token: '  fcm-token-1  ',
    });

    expect(upsert).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          platform_token: { platform: 'ANDROID', token: 'fcm-token-1' },
        },
        update: { userId: 'emp-2', isActive: true },
      }),
    );
  });

  it('propagates persistence failures (failure path)', async () => {
    const upsert = jest.fn().mockRejectedValue(new Error('db down'));
    const prisma = { deviceToken: { upsert } };
    const service = new DeviceTokensService(prisma as never);

    await expect(
      service.register(makeUser(), {
        platform: DeviceTokenPlatform.IOS,
        token: 'apns-token',
      }),
    ).rejects.toThrow('db down');
  });
});
