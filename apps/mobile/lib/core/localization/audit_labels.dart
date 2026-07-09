import '../../features/audit/domain/audit_models.dart';
import '../../l10n/app_localizations.dart';

/// Maps audit action / entity codes to localized display labels.
String localizeAuditAction(AppLocalizations l10n, String action) {
  switch (action) {
    case AuditActionCodes.authLogin:
      return l10n.auditActionAuthLogin;
    case AuditActionCodes.authLogout:
      return l10n.auditActionAuthLogout;
    case AuditActionCodes.notificationCreated:
      return l10n.auditActionNotificationCreated;
    case AuditActionCodes.notificationPublished:
      return l10n.auditActionNotificationPublished;
    case AuditActionCodes.notificationRead:
      return l10n.auditActionNotificationRead;
    case AuditActionCodes.notificationCancelled:
      return l10n.auditActionNotificationCancelled;
    case AuditActionCodes.accessRequestSubmitted:
      return l10n.auditActionAccessRequestSubmitted;
    case AuditActionCodes.accessRequestCancelled:
      return l10n.auditActionAccessRequestCancelled;
    case AuditActionCodes.accessRequestProvisioningStarted:
      return l10n.auditActionAccessRequestProvisioningStarted;
    case AuditActionCodes.accessRequestCompleted:
      return l10n.auditActionAccessRequestCompleted;
    case AuditActionCodes.accessRequestFailed:
      return l10n.auditActionAccessRequestFailed;
    case AuditActionCodes.approvalManagerApproved:
      return l10n.auditActionApprovalManagerApproved;
    case AuditActionCodes.approvalManagerRejected:
      return l10n.auditActionApprovalManagerRejected;
    case AuditActionCodes.approvalSecurityApproved:
      return l10n.auditActionApprovalSecurityApproved;
    case AuditActionCodes.approvalSecurityRejected:
      return l10n.auditActionApprovalSecurityRejected;
    default:
      return action;
  }
}

String localizeAuditEntityType(AppLocalizations l10n, String entityType) {
  switch (entityType) {
    case AuditEntityTypes.user:
      return l10n.auditEntityUser;
    case AuditEntityTypes.notification:
      return l10n.auditEntityNotification;
    case AuditEntityTypes.accessRequest:
      return l10n.auditEntityAccessRequest;
    case AuditEntityTypes.approvalTask:
      return l10n.auditEntityApprovalTask;
    default:
      return entityType;
  }
}
