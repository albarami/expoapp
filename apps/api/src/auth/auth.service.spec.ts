import { HttpStatus } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { Test, TestingModule } from '@nestjs/testing';
import { UserRole } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { BusinessException } from '../common/exceptions/business.exception';
import { PrismaService } from '../prisma/prisma.service';
import { AuthService } from './auth.service';
import { AuthAuditAction } from './constants/audit-actions';

jest.mock('bcrypt', () => ({
  compare: jest.fn(),
  hash: jest.fn(),
}));

type AuditCreateArg = {
  data: {
    action: string;
    actorId?: string;
    actorEmail?: string;
    metadata: {
      success: boolean;
      reason?: string;
    };
  };
};

describe('AuthService (BU-01)', () => {
  let service: AuthService;

  const userFindUnique = jest.fn();
  const auditLogCreate = jest.fn();
  const jwtSignAsync = jest.fn();

  const prisma = {
    user: {
      findUnique: userFindUnique,
    },
    auditLog: {
      create: auditLogCreate,
    },
  };

  const jwtService = {
    signAsync: jwtSignAsync,
  };

  const configService = {
    getOrThrow: jest.fn((key: string) => {
      if (key === 'JWT_SECRET') {
        return 'test-secret';
      }
      throw new Error(`Missing ${key}`);
    }),
    get: jest.fn((key: string, fallback?: string) => {
      if (key === 'JWT_EXPIRES_IN') {
        return '8h';
      }
      if (key === 'JWT_REFRESH_EXPIRES_IN') {
        return '30d';
      }
      return fallback;
    }),
  };

  const activeUser = {
    id: 'user-1',
    email: 'noura.alharbi@expo.sa',
    fullNameEn: 'Noura Alharbi',
    fullNameAr: 'نورة الحربي',
    role: UserRole.EMPLOYEE,
    passwordHash: 'hashed',
    isActive: true,
    departmentId: 'dept-1',
    department: {
      id: 'dept-1',
      code: 'OPS',
      nameEn: 'Operations',
      nameAr: 'العمليات',
    },
  };

  function lastAuditArg(): AuditCreateArg {
    const calls = auditLogCreate.mock.calls as [AuditCreateArg][];
    const firstCall = calls[0];
    if (!firstCall) {
      throw new Error('Expected auditLog.create to be called');
    }
    return firstCall[0];
  }

  beforeEach(async () => {
    jest.clearAllMocks();
    auditLogCreate.mockResolvedValue({ id: 'audit-1' });
    jwtSignAsync
      .mockResolvedValueOnce('access-token')
      .mockResolvedValueOnce('refresh-token');

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: PrismaService, useValue: prisma },
        { provide: JwtService, useValue: jwtService },
        { provide: ConfigService, useValue: configService },
      ],
    }).compile();

    service = module.get(AuthService);
  });

  it('logs in successfully with valid credentials', async () => {
    userFindUnique.mockResolvedValue(activeUser);
    (bcrypt.compare as jest.Mock).mockResolvedValue(true);

    const result = await service.login({
      email: 'Noura.Alharbi@expo.sa',
      password: 'Password123!',
    });

    expect(result.accessToken).toBe('access-token');
    expect(result.refreshToken).toBe('refresh-token');
    expect(result.user).toEqual({
      id: activeUser.id,
      email: activeUser.email,
      fullNameEn: activeUser.fullNameEn,
      fullNameAr: activeUser.fullNameAr,
      role: UserRole.EMPLOYEE,
      department: activeUser.department,
    });
    expect(auditLogCreate).toHaveBeenCalledTimes(1);
    const successAudit = lastAuditArg();
    expect(successAudit.data.action).toBe(AuthAuditAction.LOGIN);
    expect(successAudit.data.actorId).toBe(activeUser.id);
    expect(successAudit.data.metadata.success).toBe(true);
  });

  it('rejects wrong password', async () => {
    userFindUnique.mockResolvedValue(activeUser);
    (bcrypt.compare as jest.Mock).mockResolvedValue(false);

    let caught: BusinessException | undefined;
    try {
      await service.login({
        email: 'noura.alharbi@expo.sa',
        password: 'wrong',
      });
    } catch (error) {
      caught = error as BusinessException;
    }

    expect(caught).toBeInstanceOf(BusinessException);
    expect(caught?.getStatus()).toBe(HttpStatus.UNAUTHORIZED);
    expect(caught?.code).toBe('UNAUTHORIZED');
    expect(auditLogCreate).toHaveBeenCalledTimes(1);
    const failedAudit = lastAuditArg();
    expect(failedAudit.data.action).toBe(AuthAuditAction.LOGIN);
    expect(failedAudit.data.metadata).toEqual({
      success: false,
      reason: 'invalid_credentials',
    });
  });

  it('rejects inactive user', async () => {
    userFindUnique.mockResolvedValue({
      ...activeUser,
      isActive: false,
    });

    await expect(
      service.login({
        email: 'noura.alharbi@expo.sa',
        password: 'Password123!',
      }),
    ).rejects.toMatchObject({
      code: 'UNAUTHORIZED',
    });

    expect(bcrypt.compare).not.toHaveBeenCalled();
    expect(auditLogCreate).toHaveBeenCalledTimes(1);
    const inactiveAudit = lastAuditArg();
    expect(inactiveAudit.data.metadata).toEqual({
      success: false,
      reason: 'inactive_user',
    });
  });

  it('rejects unknown email without revealing existence', async () => {
    userFindUnique.mockResolvedValue(null);

    await expect(
      service.login({
        email: 'missing@expo.sa',
        password: 'Password123!',
      }),
    ).rejects.toBeInstanceOf(BusinessException);

    expect(bcrypt.compare).not.toHaveBeenCalled();
  });
});
