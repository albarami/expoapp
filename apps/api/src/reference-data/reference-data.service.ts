import { Injectable } from '@nestjs/common';
import {
  AccessDuration,
  AccessUrgency,
  NotificationPriority,
  UserRole,
} from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { ReferenceDataResponse } from './reference-data.types';

@Injectable()
export class ReferenceDataService {
  constructor(private readonly prisma: PrismaService) {}

  async getReferenceData(): Promise<ReferenceDataResponse> {
    const [departments, systems, securityRoles] = await Promise.all([
      this.prisma.department.findMany({
        orderBy: { code: 'asc' },
        select: {
          id: true,
          code: true,
          nameEn: true,
          nameAr: true,
        },
      }),
      this.prisma.appSystem.findMany({
        orderBy: { code: 'asc' },
        select: {
          id: true,
          code: true,
          nameEn: true,
          nameAr: true,
          description: true,
          isActive: true,
        },
      }),
      this.prisma.securityRoleCatalog.findMany({
        where: { isActive: true },
        orderBy: [{ system: { code: 'asc' } }, { code: 'asc' }],
        select: {
          id: true,
          systemId: true,
          code: true,
          nameEn: true,
          nameAr: true,
          description: true,
          riskLevel: true,
          requiresManagerApproval: true,
          requiresSecurityApproval: true,
          isActive: true,
          system: {
            select: { code: true },
          },
        },
      }),
    ]);

    return {
      departments,
      systems,
      securityRoles: securityRoles.map((role) => ({
        id: role.id,
        systemId: role.systemId,
        systemCode: role.system.code,
        code: role.code,
        nameEn: role.nameEn,
        nameAr: role.nameAr,
        description: role.description,
        riskLevel: role.riskLevel,
        requiresManagerApproval: role.requiresManagerApproval,
        requiresSecurityApproval: role.requiresSecurityApproval,
        isActive: role.isActive,
      })),
      roles: Object.values(UserRole),
      notificationPriorities: Object.values(NotificationPriority),
      accessUrgencies: Object.values(AccessUrgency),
      accessDurations: Object.values(AccessDuration),
    };
  }
}
