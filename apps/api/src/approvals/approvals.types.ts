import {
  AccessDuration,
  AccessRequestStage,
  AccessRequestStatus,
  AccessUrgency,
  ApprovalDecision,
  ApprovalStage,
  RiskLevel,
} from '@prisma/client';

export const DEFAULT_APPROVALS_PAGE = 1;
export const DEFAULT_APPROVALS_PAGE_SIZE = 20;
export const MAX_APPROVALS_PAGE_SIZE = 100;

export const MAX_APPROVAL_COMMENT_LENGTH = 1000;

export const ApprovalEventType = {
  ManagerApproved: 'MANAGER_APPROVED',
  ManagerRejected: 'MANAGER_REJECTED',
  SecurityTaskAssigned: 'SECURITY_TASK_ASSIGNED',
  SecurityApproved: 'SECURITY_APPROVED',
  SecurityRejected: 'SECURITY_REJECTED',
  ProvisioningStarted: 'PROVISIONING_STARTED',
  Completed: 'COMPLETED',
  Failed: 'FAILED',
} as const;

export type ApprovalEventType =
  (typeof ApprovalEventType)[keyof typeof ApprovalEventType];

/** Decision values accepted by the API (PENDING/RETURNED are not decideable). */
export enum ApprovalDecisionInput {
  APPROVED = 'APPROVED',
  REJECTED = 'REJECTED',
}

export interface ApprovalListItem {
  id: string;
  stage: ApprovalStage;
  decision: ApprovalDecision;
  comment: string | null;
  decidedAt: string | null;
  createdAt: string;
  accessRequest: {
    id: string;
    requestNumber: string;
    status: AccessRequestStatus;
    currentStage: AccessRequestStage;
    urgency: AccessUrgency;
    accessDuration: AccessDuration;
    submittedAt: string | null;
    system: {
      id: string;
      code: string;
      nameEn: string;
      nameAr: string | null;
    };
    securityRole: {
      id: string;
      code: string;
      nameEn: string;
      nameAr: string | null;
      riskLevel: RiskLevel;
    };
    requester: {
      id: string;
      fullNameEn: string;
      fullNameAr: string | null;
      email: string;
    };
  };
}

export interface ApprovalListResult {
  items: ApprovalListItem[];
  page: number;
  pageSize: number;
  total: number;
}

export interface DecideApprovalResult {
  taskId: string;
  decision: ApprovalDecision;
  request: {
    id: string;
    requestNumber: string;
    status: AccessRequestStatus;
    currentStage: AccessRequestStage;
  };
}
