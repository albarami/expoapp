import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { ErrorCode } from '../common/constants/error-codes';
import { BusinessException } from '../common/exceptions/business.exception';
import { PrismaService } from '../prisma/prisma.service';
import {
  FusionAdapter,
  FusionEmployeeProfile,
  FusionProvisioningResult,
  FusionProvisioningStatus,
  FusionSecurityRole,
  RoleCatalogQuery,
  SubmitFusionProvisioningInput,
  ValidateFusionAccessRequestInput,
  ValidationResult,
} from './fusion-adapter.interface';
import { MOCK_FUSION_ID_PREFIX } from './fusion.constants';

@Injectable()
export class MockFusionAdapter implements FusionAdapter {
  constructor(private readonly prisma: PrismaService) {}

  async getEmployeeProfile(
    userExternalRef: string,
  ): Promise<FusionEmployeeProfile> {
    const user = await this.prisma.user.findUnique({
      where: { externalRef: userExternalRef },
      select: {
        externalRef: true,
        employeeNumber: true,
        fullNameEn: true,
        fullNameAr: true,
        email: true,
        isActive: true,
        department: { select: { code: true } },
        manager: { select: { externalRef: true } },
      },
    });

    if (!user || !user.isActive) {
      throw new BusinessException({
        code: ErrorCode.NOT_FOUND,
        message: `Employee profile not found for externalRef=${userExternalRef}`,
        status: 404,
      });
    }

    return {
      externalRef: user.externalRef,
      employeeNumber: user.employeeNumber,
      fullNameEn: user.fullNameEn,
      fullNameAr: user.fullNameAr ?? undefined,
      email: user.email,
      departmentCode: user.department?.code,
      managerExternalRef: user.manager?.externalRef,
    };
  }

  async listAvailableSecurityRoles(
    input: RoleCatalogQuery,
  ): Promise<FusionSecurityRole[]> {
    const where: Prisma.SecurityRoleCatalogWhereInput = {
      isActive: true,
      system: {
        isActive: true,
        ...(input.systemCode ? { code: input.systemCode } : {}),
      },
    };

    if (input.search?.trim()) {
      const search = input.search.trim();
      where.OR = [
        { code: { contains: search, mode: 'insensitive' } },
        { nameEn: { contains: search, mode: 'insensitive' } },
        { nameAr: { contains: search, mode: 'insensitive' } },
      ];
    }

    const roles = await this.prisma.securityRoleCatalog.findMany({
      where,
      orderBy: [{ system: { code: 'asc' } }, { code: 'asc' }],
      select: {
        id: true,
        code: true,
        nameEn: true,
        nameAr: true,
        description: true,
        riskLevel: true,
        system: { select: { code: true } },
      },
    });

    return roles.map((role) => ({
      externalRoleId: role.id,
      systemCode: role.system.code,
      code: role.code,
      nameEn: role.nameEn,
      nameAr: role.nameAr ?? undefined,
      description: role.description ?? undefined,
      riskLevel: role.riskLevel,
    }));
  }

  async validateAccessRequest(
    input: ValidateFusionAccessRequestInput,
  ): Promise<ValidationResult> {
    const role = await this.prisma.securityRoleCatalog.findFirst({
      where: {
        code: input.roleCode,
        isActive: true,
        system: {
          code: input.systemCode,
          isActive: true,
        },
      },
      select: { id: true },
    });

    if (!role) {
      return {
        valid: false,
        code: ErrorCode.ROLE_NOT_REQUESTABLE,
        message: `Role ${input.roleCode} is not active for system ${input.systemCode}`,
      };
    }

    const requester = await this.prisma.user.findUnique({
      where: { externalRef: input.requesterExternalRef },
      select: { id: true, isActive: true },
    });

    if (!requester || !requester.isActive) {
      return {
        valid: false,
        code: ErrorCode.NOT_FOUND,
        message: `Requester ${input.requesterExternalRef} was not found or is inactive`,
      };
    }

    return { valid: true };
  }

  async submitAccessProvisioning(
    input: SubmitFusionProvisioningInput,
  ): Promise<FusionProvisioningResult> {
    const validation = await this.validateAccessRequest({
      requesterExternalRef: input.requesterExternalRef,
      systemCode: input.systemCode,
      roleCode: input.roleCode,
    });

    if (!validation.valid) {
      return {
        externalRequestId: `${MOCK_FUSION_ID_PREFIX}${input.requestNumber}-FAILED`,
        status: 'FAILED',
        message: validation.message,
      };
    }

    return {
      externalRequestId: `${MOCK_FUSION_ID_PREFIX}${input.requestNumber}`,
      status: 'COMPLETED',
      message: 'Mock Fusion provisioning completed',
    };
  }

  getProvisioningStatus(
    externalRequestId: string,
  ): Promise<FusionProvisioningStatus> {
    if (!externalRequestId.startsWith(MOCK_FUSION_ID_PREFIX)) {
      return Promise.resolve({
        externalRequestId,
        status: 'FAILED',
        message: 'Unknown mock Fusion request id',
      });
    }

    if (externalRequestId.endsWith('-FAILED')) {
      return Promise.resolve({
        externalRequestId,
        status: 'FAILED',
        message: 'Mock Fusion provisioning failed',
      });
    }

    return Promise.resolve({
      externalRequestId,
      status: 'COMPLETED',
      message: 'Mock Fusion provisioning completed',
    });
  }
}
