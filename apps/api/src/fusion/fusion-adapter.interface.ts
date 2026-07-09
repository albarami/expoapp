export interface FusionEmployeeProfile {
  externalRef: string;
  employeeNumber: string;
  fullNameEn: string;
  fullNameAr?: string;
  email: string;
  departmentCode?: string;
  managerExternalRef?: string;
}

export interface RoleCatalogQuery {
  systemCode?: string;
  search?: string;
}

export interface FusionSecurityRole {
  externalRoleId: string;
  systemCode: string;
  code: string;
  nameEn: string;
  nameAr?: string;
  description?: string;
  riskLevel: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';
}

export interface ValidateFusionAccessRequestInput {
  requesterExternalRef: string;
  systemCode: string;
  roleCode: string;
}

export interface ValidationResult {
  valid: boolean;
  code?: string;
  message?: string;
}

export interface SubmitFusionProvisioningInput {
  requestNumber: string;
  requesterExternalRef: string;
  systemCode: string;
  roleCode: string;
  justification: string;
  startDate?: string;
  endDate?: string;
  approvedByExternalRefs: string[];
}

export interface FusionProvisioningResult {
  externalRequestId: string;
  status: 'SUBMITTED' | 'COMPLETED' | 'FAILED';
  message?: string;
}

export interface FusionProvisioningStatus {
  externalRequestId: string;
  status: 'SUBMITTED' | 'IN_PROGRESS' | 'COMPLETED' | 'FAILED';
  message?: string;
}

export interface FusionAdapter {
  getEmployeeProfile(userExternalRef: string): Promise<FusionEmployeeProfile>;
  listAvailableSecurityRoles(
    input: RoleCatalogQuery,
  ): Promise<FusionSecurityRole[]>;
  validateAccessRequest(
    input: ValidateFusionAccessRequestInput,
  ): Promise<ValidationResult>;
  submitAccessProvisioning(
    input: SubmitFusionProvisioningInput,
  ): Promise<FusionProvisioningResult>;
  getProvisioningStatus(
    externalRequestId: string,
  ): Promise<FusionProvisioningStatus>;
}
