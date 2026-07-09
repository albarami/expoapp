import {
  AccessDuration,
  AccessRequestStage,
  AccessRequestStatus,
  AccessUrgency,
} from '@prisma/client';

export const DEFAULT_ACCESS_REQUEST_PAGE = 1;
export const DEFAULT_ACCESS_REQUEST_PAGE_SIZE = 20;
export const MAX_ACCESS_REQUEST_PAGE_SIZE = 100;

export const MIN_JUSTIFICATION_LENGTH = 20;
export const MAX_JUSTIFICATION_LENGTH = 1000;

export const DUPLICATE_ACTIVE_STATUSES: AccessRequestStatus[] = [
  AccessRequestStatus.MANAGER_PENDING,
  AccessRequestStatus.SECURITY_PENDING,
  AccessRequestStatus.PROVISIONING,
];

export const CANCELABLE_STATUSES: AccessRequestStatus[] = [
  AccessRequestStatus.MANAGER_PENDING,
  AccessRequestStatus.SECURITY_PENDING,
];

export const AccessRequestEventType = {
  Submitted: 'SUBMITTED',
  ManagerTaskAssigned: 'MANAGER_TASK_ASSIGNED',
  SecurityTaskAssigned: 'SECURITY_TASK_ASSIGNED',
  Cancelled: 'CANCELLED',
} as const;

export type AccessRequestEventType =
  (typeof AccessRequestEventType)[keyof typeof AccessRequestEventType];

export interface AccessRequestNextApprover {
  id: string;
  fullNameEn: string;
  fullNameAr: string | null;
}

export interface SubmitAccessRequestResult {
  id: string;
  requestNumber: string;
  status: AccessRequestStatus;
  currentStage: AccessRequestStage;
  nextApprover: AccessRequestNextApprover | null;
}

export interface AccessRequestListItem {
  id: string;
  requestNumber: string;
  status: AccessRequestStatus;
  currentStage: AccessRequestStage;
  urgency: AccessUrgency;
  accessDuration: AccessDuration;
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
  };
  requester: {
    id: string;
    fullNameEn: string;
    fullNameAr: string | null;
    email: string;
  };
  submittedAt: string | null;
  createdAt: string;
}

export interface AccessRequestListResult {
  items: AccessRequestListItem[];
  page: number;
  pageSize: number;
  total: number;
}

export interface AccessRequestTimelineEvent {
  id: string;
  eventType: string;
  messageEn: string;
  messageAr: string | null;
  actor: {
    id: string;
    fullNameEn: string;
    fullNameAr: string | null;
  } | null;
  createdAt: string;
  metadata: Record<string, unknown> | null;
}

export interface AccessRequestDetail {
  id: string;
  requestNumber: string;
  status: AccessRequestStatus;
  currentStage: AccessRequestStage;
  businessJustification: string;
  accessDuration: AccessDuration;
  urgency: AccessUrgency;
  startDate: string | null;
  endDate: string | null;
  submittedAt: string | null;
  completedAt: string | null;
  externalFusionRequestId: string | null;
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
    requiresManagerApproval: boolean;
    requiresSecurityApproval: boolean;
  };
  requester: {
    id: string;
    fullNameEn: string;
    fullNameAr: string | null;
    email: string;
  };
  nextApprover: AccessRequestNextApprover | null;
  timeline: AccessRequestTimelineEvent[];
  createdAt: string;
  updatedAt: string;
}

export interface CancelAccessRequestResult {
  id: string;
  requestNumber: string;
  status: AccessRequestStatus;
  currentStage: AccessRequestStage;
}
