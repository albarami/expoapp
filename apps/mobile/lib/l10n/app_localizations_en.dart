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
  String get comingSoon => 'Coming soon';

  @override
  String get foundationPlaceholder =>
      'Foundation screen — feature UI arrives in a later task.';

  @override
  String get noNotifications => 'No notifications yet';

  @override
  String get noNotificationsMessage =>
      'You will see important announcements here.';

  @override
  String get noRequests => 'No requests yet';

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
      'Network error. Check your connection and try again.';

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
  String get audienceUsersUnavailable =>
      'Selecting individual users is not available in this build. Choose All, Department, or Role.';

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
}
