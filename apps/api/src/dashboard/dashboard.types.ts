import {
  AccessRequestStatus,
  AccessUrgency,
  ApprovalDecision,
  ApprovalStage,
  NotificationPriority,
  NotificationStatus,
  RiskLevel,
  UserRole,
} from '@prisma/client';

export interface DashboardNotificationItem {
  id: string;
  titleEn: string;
  titleAr: string | null;
  priority: NotificationPriority;
  status: NotificationStatus;
  readAt: string | null;
  createdAt: string;
}

export interface DashboardRequestItem {
  id: string;
  requestNumber: string;
  status: AccessRequestStatus;
  urgency: AccessUrgency;
  systemCode: string;
  systemNameEn: string;
  securityRoleCode: string;
  securityRoleNameEn: string;
  submittedAt: string | null;
  createdAt: string;
}

export interface DashboardAuditItem {
  id: string;
  action: string;
  entityType: string;
  entityId: string | null;
  actorEmail: string | null;
  createdAt: string;
}

export interface DashboardNotificationStats {
  publishedCount: number;
  recipientCount: number;
  readCount: number;
  readPercentage: number;
}

export interface DashboardAccessWorkflowStats {
  openAccessRequests: number;
  pendingManagerApprovals: number;
  pendingSecurityApprovals: number;
  completedRequests: number;
}

export interface DashboardSummaryResponse {
  role: UserRole;
  unreadNotifications: number;
  openAccessRequests: number;
  completedRequests: number;
  pendingApprovals: number;
  latestNotifications: DashboardNotificationItem[];
  latestRequests: DashboardRequestItem[];
  teamOpenRequests?: number;
  pendingSecurityApprovals?: number;
  highRiskOpenRequests?: number;
  recentAuditEvents?: DashboardAuditItem[];
  notificationStats?: DashboardNotificationStats;
  accessWorkflowStats?: DashboardAccessWorkflowStats;
}

export const OPEN_ACCESS_REQUEST_STATUSES: AccessRequestStatus[] = [
  AccessRequestStatus.SUBMITTED,
  AccessRequestStatus.MANAGER_PENDING,
  AccessRequestStatus.MANAGER_APPROVED,
  AccessRequestStatus.SECURITY_PENDING,
  AccessRequestStatus.SECURITY_APPROVED,
  AccessRequestStatus.PROVISIONING,
];

export const HIGH_RISK_LEVELS: RiskLevel[] = [
  RiskLevel.HIGH,
  RiskLevel.CRITICAL,
];

export const LATEST_ITEMS_LIMIT = 5;
export const RECENT_AUDIT_LIMIT = 5;

export const PENDING_APPROVAL_DECISION = ApprovalDecision.PENDING;
export const MANAGER_APPROVAL_STAGE = ApprovalStage.MANAGER;
export const SECURITY_APPROVAL_STAGE = ApprovalStage.SECURITY;
