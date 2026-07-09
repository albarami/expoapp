import { HttpStatus, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { User } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { Request } from 'express';
import { ErrorCode } from '../common/constants/error-codes';
import { BusinessException } from '../common/exceptions/business.exception';
import { PrismaService } from '../prisma/prisma.service';
import { AuthAuditAction } from './constants/audit-actions';
import { getPermissionsForRole } from './constants/permissions';
import { LoginResponseDto, MeResponseDto } from './dto/auth-response.dto';
import { LoginDto } from './dto/login.dto';
import { AuthUser, AuthUserDepartment } from './types/auth-user';
import { JwtAccessPayload, JwtRefreshPayload } from './types/jwt-payload';

type UserWithDepartment = User & {
  department: AuthUserDepartment | null;
};

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  async login(dto: LoginDto, request?: Request): Promise<LoginResponseDto> {
    const email = dto.email.trim().toLowerCase();
    const user = await this.prisma.user.findUnique({
      where: { email },
      include: {
        department: {
          select: {
            id: true,
            code: true,
            nameEn: true,
            nameAr: true,
          },
        },
      },
    });

    if (!user || !user.passwordHash) {
      await this.recordAuthAudit({
        action: AuthAuditAction.LOGIN,
        actorEmail: email,
        success: false,
        reason: 'invalid_credentials',
        request,
      });
      throw this.invalidCredentials();
    }

    if (!user.isActive) {
      await this.recordAuthAudit({
        action: AuthAuditAction.LOGIN,
        actorId: user.id,
        actorEmail: user.email,
        success: false,
        reason: 'inactive_user',
        request,
      });
      throw new BusinessException({
        code: ErrorCode.UNAUTHORIZED,
        message: 'Account is inactive.',
        status: HttpStatus.UNAUTHORIZED,
      });
    }

    const passwordMatches = await bcrypt.compare(
      dto.password,
      user.passwordHash,
    );
    if (!passwordMatches) {
      await this.recordAuthAudit({
        action: AuthAuditAction.LOGIN,
        actorId: user.id,
        actorEmail: user.email,
        success: false,
        reason: 'invalid_credentials',
        request,
      });
      throw this.invalidCredentials();
    }

    const tokens = await this.issueTokens(user);
    await this.recordAuthAudit({
      action: AuthAuditAction.LOGIN,
      actorId: user.id,
      actorEmail: user.email,
      success: true,
      request,
    });

    return {
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      user: {
        id: user.id,
        email: user.email,
        fullNameEn: user.fullNameEn,
        fullNameAr: user.fullNameAr,
        role: user.role,
        department: user.department,
      },
    };
  }

  async getMe(userId: string): Promise<MeResponseDto> {
    const user = await this.loadActiveUser(userId);
    return {
      id: user.id,
      email: user.email,
      fullNameEn: user.fullNameEn,
      fullNameAr: user.fullNameAr,
      role: user.role,
      permissions: getPermissionsForRole(user.role),
      department: user.department,
    };
  }

  async logout(user: AuthUser, request?: Request): Promise<{ success: true }> {
    await this.recordAuthAudit({
      action: AuthAuditAction.LOGOUT,
      actorId: user.id,
      actorEmail: user.email,
      success: true,
      request,
    });
    return { success: true };
  }

  async validateAccessPayload(payload: JwtAccessPayload): Promise<AuthUser> {
    if (payload.typ !== 'access') {
      throw new BusinessException({
        code: ErrorCode.UNAUTHORIZED,
        message: 'Invalid access token.',
        status: HttpStatus.UNAUTHORIZED,
      });
    }

    const user = await this.loadActiveUser(payload.sub);
    return this.toAuthUser(user);
  }

  toAuthUser(user: UserWithDepartment): AuthUser {
    return {
      id: user.id,
      email: user.email,
      fullNameEn: user.fullNameEn,
      fullNameAr: user.fullNameAr,
      role: user.role,
      departmentId: user.departmentId,
      department: user.department,
      isActive: user.isActive,
      permissions: getPermissionsForRole(user.role),
    };
  }

  private async loadActiveUser(userId: string): Promise<UserWithDepartment> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        department: {
          select: {
            id: true,
            code: true,
            nameEn: true,
            nameAr: true,
          },
        },
      },
    });

    if (!user || !user.isActive) {
      throw new BusinessException({
        code: ErrorCode.UNAUTHORIZED,
        message: 'Authentication required.',
        status: HttpStatus.UNAUTHORIZED,
      });
    }

    return user;
  }

  private async issueTokens(
    user: Pick<User, 'id' | 'email' | 'role'>,
  ): Promise<{
    accessToken: string;
    refreshToken: string;
  }> {
    const secret = this.configService.getOrThrow<string>('JWT_SECRET');
    const expiresIn = this.configService.get<string>('JWT_EXPIRES_IN', '8h');
    const refreshExpiresIn = this.configService.get<string>(
      'JWT_REFRESH_EXPIRES_IN',
      '30d',
    );

    const accessPayload: JwtAccessPayload = {
      sub: user.id,
      email: user.email,
      role: user.role,
      typ: 'access',
    };
    const refreshPayload: JwtRefreshPayload = {
      sub: user.id,
      email: user.email,
      role: user.role,
      typ: 'refresh',
    };

    const [accessToken, refreshToken] = await Promise.all([
      this.jwtService.signAsync(accessPayload, {
        secret,
        expiresIn: expiresIn as `${number}${'s' | 'm' | 'h' | 'd'}`,
      }),
      this.jwtService.signAsync(refreshPayload, {
        secret,
        expiresIn: refreshExpiresIn as `${number}${'s' | 'm' | 'h' | 'd'}`,
      }),
    ]);

    return { accessToken, refreshToken };
  }

  private invalidCredentials(): BusinessException {
    return new BusinessException({
      code: ErrorCode.UNAUTHORIZED,
      message: 'Invalid email or password.',
      status: HttpStatus.UNAUTHORIZED,
    });
  }

  private async recordAuthAudit(params: {
    action: string;
    actorId?: string;
    actorEmail?: string;
    success: boolean;
    reason?: string;
    request?: Request;
  }): Promise<void> {
    try {
      await this.prisma.auditLog.create({
        data: {
          actorId: params.actorId,
          actorEmail: params.actorEmail,
          action: params.action,
          entityType: 'Auth',
          entityId: params.actorId,
          ipAddress: this.extractIp(params.request),
          userAgent: params.request?.headers['user-agent'],
          metadata: {
            success: params.success,
            ...(params.reason ? { reason: params.reason } : {}),
          },
        },
      });
    } catch {
      // Auth must not fail if audit write fails in Phase 1.
    }
  }

  private extractIp(request?: Request): string | undefined {
    if (!request) {
      return undefined;
    }
    const forwarded = request.headers['x-forwarded-for'];
    if (typeof forwarded === 'string' && forwarded.length > 0) {
      return forwarded.split(',')[0]?.trim();
    }
    return request.ip;
  }
}
