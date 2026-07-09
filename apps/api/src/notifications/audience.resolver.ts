import { HttpStatus, Injectable } from '@nestjs/common';
import { AudienceType, UserRole } from '@prisma/client';
import { ErrorCode } from '../common/constants/error-codes';
import { BusinessException } from '../common/exceptions/business.exception';
import { PrismaService } from '../prisma/prisma.service';
import {
  AudienceFilter,
  AudienceFilterAll,
  AudienceFilterDepartment,
  AudienceFilterRole,
  AudienceFilterUsers,
  ResolveAudienceInput,
  ResolvedAudienceUser,
} from './audience.types';

const USER_ROLES = new Set<string>(Object.values(UserRole));

@Injectable()
export class AudienceResolver {
  constructor(private readonly prisma: PrismaService) {}

  validateAndNormalizeFilter(
    audienceType: AudienceType,
    audienceFilter: unknown,
  ): AudienceFilter {
    if (
      audienceFilter === null ||
      typeof audienceFilter !== 'object' ||
      Array.isArray(audienceFilter)
    ) {
      throw this.invalidAudience('audienceFilter must be an object');
    }

    const filter = audienceFilter as Record<string, unknown>;

    switch (audienceType) {
      case AudienceType.ALL:
        return this.normalizeAll(filter);
      case AudienceType.DEPARTMENT:
        return this.normalizeDepartment(filter);
      case AudienceType.ROLE:
        return this.normalizeRole(filter);
      case AudienceType.USERS:
        return this.normalizeUsers(filter);
      default: {
        const unsupported: string = String(audienceType);
        throw this.invalidAudience(`Unsupported audienceType: ${unsupported}`);
      }
    }
  }

  async resolveAudience(
    input: ResolveAudienceInput,
  ): Promise<ResolvedAudienceUser[]> {
    const filter = this.validateAndNormalizeFilter(
      input.audienceType,
      input.audienceFilter,
    );

    const users = await this.prisma.user.findMany({
      where: { isActive: true },
      select: {
        id: true,
        email: true,
        role: true,
        isActive: true,
        department: {
          select: { code: true },
        },
      },
    });

    const activeUsers: ResolvedAudienceUser[] = users.map((user) => ({
      id: user.id,
      email: user.email,
      role: user.role,
      departmentCode: user.department?.code ?? null,
      isActive: user.isActive,
    }));

    switch (input.audienceType) {
      case AudienceType.ALL:
        return activeUsers;
      case AudienceType.DEPARTMENT: {
        const codes = new Set(
          (filter as AudienceFilterDepartment).departmentCodes,
        );
        return activeUsers.filter(
          (user) =>
            user.departmentCode !== null && codes.has(user.departmentCode),
        );
      }
      case AudienceType.ROLE: {
        const roles = new Set((filter as AudienceFilterRole).roles);
        return activeUsers.filter((user) => roles.has(user.role));
      }
      case AudienceType.USERS: {
        const ids = new Set((filter as AudienceFilterUsers).userIds);
        return activeUsers.filter((user) => ids.has(user.id));
      }
      default:
        return [];
    }
  }

  private normalizeAll(filter: Record<string, unknown>): AudienceFilterAll {
    if (filter.all !== true) {
      throw this.invalidAudience(
        'audienceType ALL requires audienceFilter.all = true',
      );
    }
    return { all: true };
  }

  private normalizeDepartment(
    filter: Record<string, unknown>,
  ): AudienceFilterDepartment {
    const codes = filter.departmentCodes;
    if (!Array.isArray(codes) || codes.length === 0) {
      throw this.invalidAudience(
        'audienceType DEPARTMENT requires non-empty departmentCodes',
      );
    }
    const departmentCodes = codes.filter(
      (code): code is string => typeof code === 'string' && code.length > 0,
    );
    if (departmentCodes.length !== codes.length) {
      throw this.invalidAudience('departmentCodes must be non-empty strings');
    }
    return { departmentCodes: [...new Set(departmentCodes)] };
  }

  private normalizeRole(filter: Record<string, unknown>): AudienceFilterRole {
    const roles = filter.roles;
    if (!Array.isArray(roles) || roles.length === 0) {
      throw this.invalidAudience(
        'audienceType ROLE requires non-empty roles array',
      );
    }
    const validRoles = roles.filter(
      (role): role is UserRole =>
        typeof role === 'string' && USER_ROLES.has(role),
    );
    if (validRoles.length !== roles.length) {
      throw this.invalidAudience('roles must be valid UserRole values');
    }
    return { roles: [...new Set(validRoles)] };
  }

  private normalizeUsers(filter: Record<string, unknown>): AudienceFilterUsers {
    const userIds = filter.userIds;
    if (!Array.isArray(userIds) || userIds.length === 0) {
      throw this.invalidAudience(
        'audienceType USERS requires non-empty userIds array',
      );
    }
    const validUserIds = userIds.filter(
      (id): id is string => typeof id === 'string' && id.length > 0,
    );
    if (validUserIds.length !== userIds.length) {
      throw this.invalidAudience('userIds must be non-empty strings');
    }
    return { userIds: [...new Set(validUserIds)] };
  }

  private invalidAudience(message: string): BusinessException {
    return new BusinessException({
      code: ErrorCode.INVALID_AUDIENCE_FILTER,
      message,
      status: HttpStatus.BAD_REQUEST,
    });
  }
}
