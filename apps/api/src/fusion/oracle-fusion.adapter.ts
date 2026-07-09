import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ErrorCode } from '../common/constants/error-codes';
import { BusinessException } from '../common/exceptions/business.exception';
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

const REQUIRED_FUSION_CONFIG_KEYS = [
  'FUSION_BASE_URL',
  'FUSION_CLIENT_ID',
  'FUSION_CLIENT_SECRET',
  'FUSION_TOKEN_URL',
  'FUSION_SCOPE',
] as const;

@Injectable()
export class OracleFusionAdapter implements FusionAdapter {
  constructor(private readonly configService: ConfigService) {}

  async getEmployeeProfile(
    userExternalRef: string,
  ): Promise<FusionEmployeeProfile> {
    await Promise.resolve();
    this.assertConfigured();
    void userExternalRef;
    throw this.notImplemented('getEmployeeProfile');
  }

  async listAvailableSecurityRoles(
    input: RoleCatalogQuery,
  ): Promise<FusionSecurityRole[]> {
    await Promise.resolve();
    this.assertConfigured();
    void input;
    throw this.notImplemented('listAvailableSecurityRoles');
  }

  async validateAccessRequest(
    input: ValidateFusionAccessRequestInput,
  ): Promise<ValidationResult> {
    await Promise.resolve();
    this.assertConfigured();
    void input;
    throw this.notImplemented('validateAccessRequest');
  }

  async submitAccessProvisioning(
    input: SubmitFusionProvisioningInput,
  ): Promise<FusionProvisioningResult> {
    await Promise.resolve();
    this.assertConfigured();
    void input;
    throw this.notImplemented('submitAccessProvisioning');
  }

  async getProvisioningStatus(
    externalRequestId: string,
  ): Promise<FusionProvisioningStatus> {
    await Promise.resolve();
    this.assertConfigured();
    void externalRequestId;
    throw this.notImplemented('getProvisioningStatus');
  }

  private assertConfigured(): void {
    const missing = REQUIRED_FUSION_CONFIG_KEYS.filter((key) => {
      const value = this.configService.get<string>(key);
      return value === undefined || value.trim() === '';
    });

    if (missing.length > 0) {
      throw new BusinessException({
        code: ErrorCode.FUSION_CONFIGURATION_MISSING,
        message: `Oracle Fusion configuration missing: ${missing.join(', ')}`,
        status: 503,
      });
    }
  }

  private notImplemented(method: string): BusinessException {
    return new BusinessException({
      code: ErrorCode.FUSION_PROVISIONING_FAILED,
      message: `OracleFusionAdapter.${method} is not implemented yet`,
      status: 501,
    });
  }
}
