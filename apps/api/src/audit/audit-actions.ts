export const AuditActions = {
  AuthLogin: 'AUTH_LOGIN',
  AuthLogout: 'AUTH_LOGOUT',
  NotificationCreated: 'NOTIFICATION_CREATED',
  NotificationPublished: 'NOTIFICATION_PUBLISHED',
  NotificationRead: 'NOTIFICATION_READ',
  NotificationCancelled: 'NOTIFICATION_CANCELLED',
  AccessRequestSubmitted: 'ACCESS_REQUEST_SUBMITTED',
  AccessRequestCancelled: 'ACCESS_REQUEST_CANCELLED',
  AccessRequestProvisioningStarted: 'ACCESS_REQUEST_PROVISIONING_STARTED',
  AccessRequestCompleted: 'ACCESS_REQUEST_COMPLETED',
  AccessRequestFailed: 'ACCESS_REQUEST_FAILED',
  ApprovalManagerApproved: 'APPROVAL_MANAGER_APPROVED',
  ApprovalManagerRejected: 'APPROVAL_MANAGER_REJECTED',
  ApprovalSecurityApproved: 'APPROVAL_SECURITY_APPROVED',
  ApprovalSecurityRejected: 'APPROVAL_SECURITY_REJECTED',
} as const;

export type AuditAction = (typeof AuditActions)[keyof typeof AuditActions];
