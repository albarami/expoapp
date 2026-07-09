// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'ExpoApp';

  @override
  String get login => 'Login';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get home => 'Home';

  @override
  String get notifications => 'Notifications';

  @override
  String get requests => 'Requests';

  @override
  String get approvals => 'Approvals';

  @override
  String get auditLogs => 'Audit Logs';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String get newAccessRequest => 'New Access Request';

  @override
  String get createNotification => 'Create Notification';

  @override
  String get markAsRead => 'Mark as read';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get cancel => 'Cancel';

  @override
  String get submit => 'Submit';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading…';

  @override
  String get noNotifications => 'No notifications yet';

  @override
  String get noNotificationsMessage =>
      'Important announcements will appear here.';

  @override
  String get noRequests => 'No access requests yet';

  @override
  String get noRequestsMessage => 'Create your first security access request.';

  @override
  String get noApprovals => 'No approvals pending';

  @override
  String get noData => 'Nothing to show';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get errorGeneric => 'Please try again.';

  @override
  String get unauthorizedTitle => 'Access denied';

  @override
  String get unauthorizedMessage =>
      'You do not have permission to view this screen.';

  @override
  String get networkError =>
      'Cannot connect to the server. Check your network and try again.';

  @override
  String get businessJustification => 'Business justification';

  @override
  String get system => 'System';

  @override
  String get securityRole => 'Security role';

  @override
  String get duration => 'Duration';

  @override
  String get urgency => 'Urgency';

  @override
  String get startDate => 'Start date';

  @override
  String get endDate => 'End date';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get confirm => 'Confirm';

  @override
  String get demoLoginHint => 'Use a seeded demo account to sign in.';

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusSubmitted => 'Submitted';

  @override
  String get statusManagerPending => 'Pending Manager';

  @override
  String get statusManagerApproved => 'Manager Approved';

  @override
  String get statusSecurityPending => 'Pending Security';

  @override
  String get statusSecurityApproved => 'Security Approved';

  @override
  String get statusProvisioning => 'Provisioning';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusManagerRejected => 'Rejected by Manager';

  @override
  String get statusSecurityRejected => 'Rejected by Security';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusFailed => 'Failed';

  @override
  String dashboardGreeting(String name) {
    return 'Welcome, $name';
  }

  @override
  String get dashboardSubtitle => 'Your role-based overview';

  @override
  String get unreadNotifications => 'Unread notifications';

  @override
  String get openAccessRequests => 'Open access requests';

  @override
  String get completedRequests => 'Completed requests';

  @override
  String get pendingApprovals => 'Pending approvals';

  @override
  String get teamOpenRequests => 'Team open requests';

  @override
  String get pendingSecurityApprovals => 'Pending security approvals';

  @override
  String get highRiskOpenRequests => 'High-risk open requests';

  @override
  String get publishedNotifications => 'Published notifications';

  @override
  String get totalRecipients => 'Total recipients';

  @override
  String get readCount => 'Read count';

  @override
  String get readPercentage => 'Read percentage';

  @override
  String get pendingManagerApprovals => 'Pending manager approvals';

  @override
  String get latestNotifications => 'Latest notifications';

  @override
  String get latestRequests => 'Latest requests';

  @override
  String get recentAuditEvents => 'Recent audit events';

  @override
  String get notificationStats => 'Notification stats';

  @override
  String get accessWorkflowStats => 'Access workflow stats';

  @override
  String get noAuditEvents => 'No recent audit events';

  @override
  String get viewAll => 'View all';

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityNormal => 'Normal';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityCritical => 'Critical';

  @override
  String get priorityUrgent => 'Urgent';

  @override
  String get searchNotifications => 'Search notifications';

  @override
  String get filterAll => 'All';

  @override
  String get filterUnread => 'Unread';

  @override
  String get unread => 'Unread';

  @override
  String get readStatus => 'Read';

  @override
  String notificationsUnreadCount(int count) {
    return '$count unread in this page';
  }

  @override
  String get notificationDetail => 'Notification';

  @override
  String get markedAsRead => 'Marked as read';

  @override
  String get deliveredCount => 'Delivered';

  @override
  String get unreadCountLabel => 'Unread recipients';

  @override
  String get titleEn => 'Title (English)';

  @override
  String get titleArOptional => 'Title (Arabic, optional)';

  @override
  String get bodyEn => 'Body (English)';

  @override
  String get bodyArOptional => 'Body (Arabic, optional)';

  @override
  String get priority => 'Priority';

  @override
  String get audienceType => 'Audience';

  @override
  String get audienceAll => 'Everyone';

  @override
  String get audienceDepartment => 'Departments';

  @override
  String get audienceRole => 'Roles';

  @override
  String get audienceUsers => 'Selected users';

  @override
  String get audienceAllHint =>
      'This notification will be delivered to all active users.';

  @override
  String get searchUsers => 'Search users';

  @override
  String get noUsersFound => 'No matching users found';

  @override
  String selectedUsersCount(int count) {
    return '$count selected';
  }

  @override
  String get publishNow => 'Publish now';

  @override
  String get publishNowHint => 'Recipients are created immediately.';

  @override
  String get schedulePublishHint => 'Schedule a future publish time.';

  @override
  String get publishAt => 'Publish at';

  @override
  String get expiresAtOptional => 'Expires at (optional)';

  @override
  String get selectDateTime => 'Select date and time';

  @override
  String get preview => 'Preview';

  @override
  String get publish => 'Publish';

  @override
  String get createNotificationSubtitle =>
      'Compose a bilingual announcement for the selected audience.';

  @override
  String get criticalConfirmTitle => 'Publish critical notification?';

  @override
  String get criticalConfirmMessage =>
      'Critical notifications are urgent. Confirm you want to publish now.';

  @override
  String get notificationCreatedTitle => 'Notification created';

  @override
  String notificationCreatedMessage(int count) {
    return 'Delivered to $count recipients.';
  }

  @override
  String get validationRequired => 'This field is required.';

  @override
  String validationMinLength(int min) {
    return 'Must be at least $min characters.';
  }

  @override
  String validationMaxLength(int max) {
    return 'Must be at most $max characters.';
  }

  @override
  String get validationAudienceRequired =>
      'Select at least one audience value.';

  @override
  String get validationPublishAtRequired =>
      'Choose a publish time when scheduling.';

  @override
  String get errorManagerNotFound => 'No manager found for this request.';

  @override
  String get errorRoleNotRequestable => 'This role cannot be requested.';

  @override
  String get errorDuplicateActiveRequest =>
      'You already have an active request for this role.';

  @override
  String get errorInvalidAccessDates =>
      'Check the start and end dates for this request.';

  @override
  String get errorRequestNotCancelable =>
      'This request can no longer be cancelled.';

  @override
  String get errorUserInactive => 'Your account is inactive.';

  @override
  String get errorValidation => 'Please check the form and try again.';

  @override
  String get errorUnauthorized => 'Your session expired. Please sign in again.';

  @override
  String get errorInvalidCredentials => 'Invalid email or password.';

  @override
  String get validationEmailRequired => 'Email is required.';

  @override
  String get validationEmailInvalid => 'Enter a valid email address.';

  @override
  String get validationPasswordRequired => 'Password is required.';

  @override
  String get demoQuickLogin => 'Quick demo login';

  @override
  String get demoEmployee => 'Employee';

  @override
  String get demoManager => 'Manager';

  @override
  String get demoSecurityAdmin => 'Security Admin';

  @override
  String get demoSystemAdmin => 'System Admin';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get sessionRestoring => 'Restoring your session…';

  @override
  String signedInAs(String name) {
    return 'Signed in as $name';
  }

  @override
  String get security => 'Security';

  @override
  String get create => 'Create';

  @override
  String get role => 'Role';

  @override
  String get department => 'Department';

  @override
  String get employeeNumber => 'Employee number';

  @override
  String get notAvailable => 'Not available';

  @override
  String get roleEmployee => 'Employee';

  @override
  String get roleManager => 'Manager';

  @override
  String get roleSecurityAdmin => 'Security Admin';

  @override
  String get roleSystemAdmin => 'System Admin';

  @override
  String get about => 'About';

  @override
  String get appVersion => 'App version';

  @override
  String get apiEnvironment => 'API environment';

  @override
  String get apiBaseUrl => 'API base URL';

  @override
  String get filterPending => 'Pending';

  @override
  String get filterCompleted => 'Completed';

  @override
  String get filterRejected => 'Rejected';

  @override
  String get requestDetail => 'Request detail';

  @override
  String get requester => 'Requester';

  @override
  String get riskLevel => 'Risk level';

  @override
  String get currentStage => 'Current stage';

  @override
  String get nextApprover => 'Next approver';

  @override
  String get timeline => 'Timeline';

  @override
  String get noTimelineEvents => 'No timeline events yet.';

  @override
  String get cancelRequest => 'Cancel request';

  @override
  String get cancelRequestTitle => 'Cancel this request?';

  @override
  String cancelRequestMessage(String requestNumber) {
    return 'Cancel request $requestNumber? This cannot be undone.';
  }

  @override
  String get requestCancelled => 'Request cancelled.';

  @override
  String requestSubmitted(String requestNumber) {
    return 'Request $requestNumber submitted.';
  }

  @override
  String get newAccessRequestSubtitle =>
      'Choose a system and role, then explain why you need access.';

  @override
  String justificationHelper(int min) {
    return 'At least $min characters.';
  }

  @override
  String get selectDate => 'Select a date';

  @override
  String get durationTemporary => 'Temporary';

  @override
  String get durationPermanent => 'Permanent';

  @override
  String get urgencyNormal => 'Normal';

  @override
  String get urgencyUrgent => 'Urgent';

  @override
  String get urgencyCritical => 'Critical';

  @override
  String get stageRequester => 'Requester';

  @override
  String get stageManager => 'Manager';

  @override
  String get stageSecurity => 'Security';

  @override
  String get stageProvisioning => 'Provisioning';

  @override
  String get stageComplete => 'Complete';

  @override
  String get riskLow => 'Low';

  @override
  String get riskMedium => 'Medium';

  @override
  String get riskHigh => 'High';

  @override
  String get riskCritical => 'Critical';

  @override
  String get review => 'Review';

  @override
  String get viewDetails => 'View details';

  @override
  String get approvalDetail => 'Approval decision';

  @override
  String get approvalStageManager => 'Manager approval';

  @override
  String get approvalStageSecurity => 'Security approval';

  @override
  String approvalStageLabel(String stage) {
    return 'Stage: $stage';
  }

  @override
  String get noApprovalsMessage => 'You are all caught up.';

  @override
  String get noCompletedApprovals => 'No completed approvals';

  @override
  String get noCompletedApprovalsMessage => 'Decided tasks will appear here.';

  @override
  String get approveConfirmTitle => 'Approve this request?';

  @override
  String approveConfirmMessage(String requestNumber) {
    return 'Are you sure you want to approve access request $requestNumber?';
  }

  @override
  String get rejectConfirmTitle => 'Reject this request?';

  @override
  String get rejectConfirmMessage => 'Please provide a rejection reason.';

  @override
  String get optionalComment => 'Comment (optional)';

  @override
  String get optionalCommentHint =>
      'Add a note for the requester or next approver.';

  @override
  String get rejectionReason => 'Rejection reason';

  @override
  String get rejectionReasonHint => 'Explain why this request is rejected.';

  @override
  String get rejectionCommentRequired => 'A rejection reason is required.';

  @override
  String get decisionComment => 'Decision comment';

  @override
  String get confirmApprove => 'Confirm approve';

  @override
  String get confirmReject => 'Confirm reject';

  @override
  String approvalApprovedSuccess(String requestNumber) {
    return 'Request $requestNumber approved.';
  }

  @override
  String approvalRejectedSuccess(String requestNumber) {
    return 'Request $requestNumber rejected.';
  }

  @override
  String get errorApprovalNotFound => 'This approval task could not be found.';

  @override
  String get errorApprovalNotPending =>
      'This approval has already been decided.';

  @override
  String get errorNotTaskAssignee =>
      'Only the assigned approver can decide this task.';

  @override
  String get errorForbidden => 'You do not have permission for this action.';

  @override
  String get close => 'Close';

  @override
  String get viewMetadata => 'View metadata';

  @override
  String get searchActorEmail => 'Search by actor email';

  @override
  String get filterAction => 'Action';

  @override
  String get filterEntityType => 'Entity';

  @override
  String get filterFromDate => 'From date';

  @override
  String get filterToDate => 'To date';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get noAuditLogs => 'No audit logs match your filters';

  @override
  String get noAuditLogsMessage =>
      'Security and admin events will appear here.';

  @override
  String get noAuditLogsFilteredMessage => 'Try changing the filters.';

  @override
  String get auditActorUnknown => 'Unknown actor';

  @override
  String auditEntityLabel(String entityType) {
    return 'Entity: $entityType';
  }

  @override
  String get auditMetadataTitle => 'Audit event detail';

  @override
  String get auditNoMetadata => 'No metadata recorded.';

  @override
  String get auditFieldAction => 'Action';

  @override
  String get auditFieldActor => 'Actor';

  @override
  String get auditFieldEntity => 'Entity type';

  @override
  String get auditFieldEntityId => 'Entity ID';

  @override
  String get auditFieldWhen => 'When';

  @override
  String get auditFieldIp => 'IP address';

  @override
  String get auditFieldUserAgent => 'User agent';

  @override
  String get auditFieldMetadata => 'Metadata';

  @override
  String get previousPage => 'Previous page';

  @override
  String get nextPage => 'Next page';

  @override
  String auditPageStatus(int page, int totalPages, int total) {
    return 'Page $page of $totalPages · $total events';
  }

  @override
  String get errorNotFound => 'The requested item could not be found.';

  @override
  String get errorInvalidAudienceFilter =>
      'The notification audience selection is invalid.';

  @override
  String get errorFusionConfigurationMissing =>
      'Oracle Fusion is not configured for this environment.';

  @override
  String get errorFusionProvisioningFailed =>
      'Provisioning with Oracle Fusion failed. Try again later.';

  @override
  String get auditActionAuthLogin => 'Signed in';

  @override
  String get auditActionAuthLogout => 'Signed out';

  @override
  String get auditActionNotificationCreated => 'Notification created';

  @override
  String get auditActionNotificationPublished => 'Notification published';

  @override
  String get auditActionNotificationRead => 'Notification read';

  @override
  String get auditActionNotificationCancelled => 'Notification cancelled';

  @override
  String get auditActionAccessRequestSubmitted => 'Access request submitted';

  @override
  String get auditActionAccessRequestCancelled => 'Access request cancelled';

  @override
  String get auditActionAccessRequestProvisioningStarted =>
      'Provisioning started';

  @override
  String get auditActionAccessRequestCompleted => 'Access request completed';

  @override
  String get auditActionAccessRequestFailed => 'Access request failed';

  @override
  String get auditActionApprovalManagerApproved => 'Manager approved';

  @override
  String get auditActionApprovalManagerRejected => 'Manager rejected';

  @override
  String get auditActionApprovalSecurityApproved => 'Security approved';

  @override
  String get auditActionApprovalSecurityRejected => 'Security rejected';

  @override
  String get auditEntityUser => 'User';

  @override
  String get auditEntityNotification => 'Notification';

  @override
  String get auditEntityAccessRequest => 'Access request';

  @override
  String get auditEntityApprovalTask => 'Approval task';
}
