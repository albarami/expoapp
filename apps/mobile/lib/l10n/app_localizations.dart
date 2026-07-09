import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// Application display name
  ///
  /// In en, this message translates to:
  /// **'ExpoApp'**
  String get appName;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// No description provided for @approvals.
  ///
  /// In en, this message translates to:
  /// **'Approvals'**
  String get approvals;

  /// No description provided for @auditLogs.
  ///
  /// In en, this message translates to:
  /// **'Audit Logs'**
  String get auditLogs;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @newAccessRequest.
  ///
  /// In en, this message translates to:
  /// **'New Access Request'**
  String get newAccessRequest;

  /// No description provided for @createNotification.
  ///
  /// In en, this message translates to:
  /// **'Create Notification'**
  String get createNotification;

  /// No description provided for @markAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get markAsRead;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotifications;

  /// No description provided for @noNotificationsMessage.
  ///
  /// In en, this message translates to:
  /// **'Important announcements will appear here.'**
  String get noNotificationsMessage;

  /// No description provided for @noRequests.
  ///
  /// In en, this message translates to:
  /// **'No access requests yet'**
  String get noRequests;

  /// No description provided for @noRequestsMessage.
  ///
  /// In en, this message translates to:
  /// **'Create your first security access request.'**
  String get noRequestsMessage;

  /// No description provided for @noApprovals.
  ///
  /// In en, this message translates to:
  /// **'No approvals pending'**
  String get noApprovals;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'Nothing to show'**
  String get noData;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorTitle;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Please try again.'**
  String get errorGeneric;

  /// No description provided for @unauthorizedTitle.
  ///
  /// In en, this message translates to:
  /// **'Access denied'**
  String get unauthorizedTitle;

  /// No description provided for @unauthorizedMessage.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to view this screen.'**
  String get unauthorizedMessage;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Cannot connect to the server. Check your network and try again.'**
  String get networkError;

  /// No description provided for @businessJustification.
  ///
  /// In en, this message translates to:
  /// **'Business justification'**
  String get businessJustification;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @securityRole.
  ///
  /// In en, this message translates to:
  /// **'Security role'**
  String get securityRole;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @urgency.
  ///
  /// In en, this message translates to:
  /// **'Urgency'**
  String get urgency;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get endDate;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @demoLoginHint.
  ///
  /// In en, this message translates to:
  /// **'Use a seeded demo account to sign in.'**
  String get demoLoginHint;

  /// No description provided for @statusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// No description provided for @statusSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get statusSubmitted;

  /// No description provided for @statusManagerPending.
  ///
  /// In en, this message translates to:
  /// **'Pending Manager'**
  String get statusManagerPending;

  /// No description provided for @statusManagerApproved.
  ///
  /// In en, this message translates to:
  /// **'Manager Approved'**
  String get statusManagerApproved;

  /// No description provided for @statusSecurityPending.
  ///
  /// In en, this message translates to:
  /// **'Pending Security'**
  String get statusSecurityPending;

  /// No description provided for @statusSecurityApproved.
  ///
  /// In en, this message translates to:
  /// **'Security Approved'**
  String get statusSecurityApproved;

  /// No description provided for @statusProvisioning.
  ///
  /// In en, this message translates to:
  /// **'Provisioning'**
  String get statusProvisioning;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusManagerRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected by Manager'**
  String get statusManagerRejected;

  /// No description provided for @statusSecurityRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected by Security'**
  String get statusSecurityRejected;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// No description provided for @dashboardGreeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String dashboardGreeting(String name);

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your role-based overview'**
  String get dashboardSubtitle;

  /// No description provided for @unreadNotifications.
  ///
  /// In en, this message translates to:
  /// **'Unread notifications'**
  String get unreadNotifications;

  /// No description provided for @openAccessRequests.
  ///
  /// In en, this message translates to:
  /// **'Open access requests'**
  String get openAccessRequests;

  /// No description provided for @completedRequests.
  ///
  /// In en, this message translates to:
  /// **'Completed requests'**
  String get completedRequests;

  /// No description provided for @pendingApprovals.
  ///
  /// In en, this message translates to:
  /// **'Pending approvals'**
  String get pendingApprovals;

  /// No description provided for @teamOpenRequests.
  ///
  /// In en, this message translates to:
  /// **'Team open requests'**
  String get teamOpenRequests;

  /// No description provided for @pendingSecurityApprovals.
  ///
  /// In en, this message translates to:
  /// **'Pending security approvals'**
  String get pendingSecurityApprovals;

  /// No description provided for @highRiskOpenRequests.
  ///
  /// In en, this message translates to:
  /// **'High-risk open requests'**
  String get highRiskOpenRequests;

  /// No description provided for @publishedNotifications.
  ///
  /// In en, this message translates to:
  /// **'Published notifications'**
  String get publishedNotifications;

  /// No description provided for @totalRecipients.
  ///
  /// In en, this message translates to:
  /// **'Total recipients'**
  String get totalRecipients;

  /// No description provided for @readCount.
  ///
  /// In en, this message translates to:
  /// **'Read count'**
  String get readCount;

  /// No description provided for @readPercentage.
  ///
  /// In en, this message translates to:
  /// **'Read percentage'**
  String get readPercentage;

  /// No description provided for @pendingManagerApprovals.
  ///
  /// In en, this message translates to:
  /// **'Pending manager approvals'**
  String get pendingManagerApprovals;

  /// No description provided for @latestNotifications.
  ///
  /// In en, this message translates to:
  /// **'Latest notifications'**
  String get latestNotifications;

  /// No description provided for @latestRequests.
  ///
  /// In en, this message translates to:
  /// **'Latest requests'**
  String get latestRequests;

  /// No description provided for @recentAuditEvents.
  ///
  /// In en, this message translates to:
  /// **'Recent audit events'**
  String get recentAuditEvents;

  /// No description provided for @notificationStats.
  ///
  /// In en, this message translates to:
  /// **'Notification stats'**
  String get notificationStats;

  /// No description provided for @accessWorkflowStats.
  ///
  /// In en, this message translates to:
  /// **'Access workflow stats'**
  String get accessWorkflowStats;

  /// No description provided for @noAuditEvents.
  ///
  /// In en, this message translates to:
  /// **'No recent audit events'**
  String get noAuditEvents;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @priorityNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get priorityNormal;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @priorityCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get priorityCritical;

  /// No description provided for @priorityUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get priorityUrgent;

  /// No description provided for @searchNotifications.
  ///
  /// In en, this message translates to:
  /// **'Search notifications'**
  String get searchNotifications;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get filterUnread;

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// No description provided for @readStatus.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get readStatus;

  /// No description provided for @notificationsUnreadCount.
  ///
  /// In en, this message translates to:
  /// **'{count} unread in this page'**
  String notificationsUnreadCount(int count);

  /// No description provided for @notificationDetail.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notificationDetail;

  /// No description provided for @markedAsRead.
  ///
  /// In en, this message translates to:
  /// **'Marked as read'**
  String get markedAsRead;

  /// No description provided for @deliveredCount.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get deliveredCount;

  /// No description provided for @unreadCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Unread recipients'**
  String get unreadCountLabel;

  /// No description provided for @titleEn.
  ///
  /// In en, this message translates to:
  /// **'Title (English)'**
  String get titleEn;

  /// No description provided for @titleArOptional.
  ///
  /// In en, this message translates to:
  /// **'Title (Arabic, optional)'**
  String get titleArOptional;

  /// No description provided for @bodyEn.
  ///
  /// In en, this message translates to:
  /// **'Body (English)'**
  String get bodyEn;

  /// No description provided for @bodyArOptional.
  ///
  /// In en, this message translates to:
  /// **'Body (Arabic, optional)'**
  String get bodyArOptional;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @audienceType.
  ///
  /// In en, this message translates to:
  /// **'Audience'**
  String get audienceType;

  /// No description provided for @audienceAll.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get audienceAll;

  /// No description provided for @audienceDepartment.
  ///
  /// In en, this message translates to:
  /// **'Departments'**
  String get audienceDepartment;

  /// No description provided for @audienceRole.
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get audienceRole;

  /// No description provided for @audienceUsers.
  ///
  /// In en, this message translates to:
  /// **'Selected users'**
  String get audienceUsers;

  /// No description provided for @audienceAllHint.
  ///
  /// In en, this message translates to:
  /// **'This notification will be delivered to all active users.'**
  String get audienceAllHint;

  /// No description provided for @searchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search users'**
  String get searchUsers;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No matching users found'**
  String get noUsersFound;

  /// No description provided for @selectedUsersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedUsersCount(int count);

  /// No description provided for @publishNow.
  ///
  /// In en, this message translates to:
  /// **'Publish now'**
  String get publishNow;

  /// No description provided for @publishNowHint.
  ///
  /// In en, this message translates to:
  /// **'Recipients are created immediately.'**
  String get publishNowHint;

  /// No description provided for @schedulePublishHint.
  ///
  /// In en, this message translates to:
  /// **'Schedule a future publish time.'**
  String get schedulePublishHint;

  /// No description provided for @publishAt.
  ///
  /// In en, this message translates to:
  /// **'Publish at'**
  String get publishAt;

  /// No description provided for @expiresAtOptional.
  ///
  /// In en, this message translates to:
  /// **'Expires at (optional)'**
  String get expiresAtOptional;

  /// No description provided for @selectDateTime.
  ///
  /// In en, this message translates to:
  /// **'Select date and time'**
  String get selectDateTime;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @createNotificationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Compose a bilingual announcement for the selected audience.'**
  String get createNotificationSubtitle;

  /// No description provided for @criticalConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Publish critical notification?'**
  String get criticalConfirmTitle;

  /// No description provided for @criticalConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Critical notifications are urgent. Confirm you want to publish now.'**
  String get criticalConfirmMessage;

  /// No description provided for @notificationCreatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification created'**
  String get notificationCreatedTitle;

  /// No description provided for @notificationCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Delivered to {count} recipients.'**
  String notificationCreatedMessage(int count);

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get validationRequired;

  /// No description provided for @validationMinLength.
  ///
  /// In en, this message translates to:
  /// **'Must be at least {min} characters.'**
  String validationMinLength(int min);

  /// No description provided for @validationMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Must be at most {max} characters.'**
  String validationMaxLength(int max);

  /// No description provided for @validationAudienceRequired.
  ///
  /// In en, this message translates to:
  /// **'Select at least one audience value.'**
  String get validationAudienceRequired;

  /// No description provided for @validationPublishAtRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a publish time when scheduling.'**
  String get validationPublishAtRequired;

  /// No description provided for @errorManagerNotFound.
  ///
  /// In en, this message translates to:
  /// **'No manager found for this request.'**
  String get errorManagerNotFound;

  /// No description provided for @errorRoleNotRequestable.
  ///
  /// In en, this message translates to:
  /// **'This role cannot be requested.'**
  String get errorRoleNotRequestable;

  /// No description provided for @errorDuplicateActiveRequest.
  ///
  /// In en, this message translates to:
  /// **'You already have an active request for this role.'**
  String get errorDuplicateActiveRequest;

  /// No description provided for @errorInvalidAccessDates.
  ///
  /// In en, this message translates to:
  /// **'Check the start and end dates for this request.'**
  String get errorInvalidAccessDates;

  /// No description provided for @errorRequestNotCancelable.
  ///
  /// In en, this message translates to:
  /// **'This request can no longer be cancelled.'**
  String get errorRequestNotCancelable;

  /// No description provided for @errorUserInactive.
  ///
  /// In en, this message translates to:
  /// **'Your account is inactive.'**
  String get errorUserInactive;

  /// No description provided for @errorValidation.
  ///
  /// In en, this message translates to:
  /// **'Please check the form and try again.'**
  String get errorValidation;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Please sign in again.'**
  String get errorUnauthorized;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get errorInvalidCredentials;

  /// No description provided for @validationEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required.'**
  String get validationEmailRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get validationEmailInvalid;

  /// No description provided for @validationPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get validationPasswordRequired;

  /// No description provided for @demoQuickLogin.
  ///
  /// In en, this message translates to:
  /// **'Quick demo login'**
  String get demoQuickLogin;

  /// No description provided for @demoEmployee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get demoEmployee;

  /// No description provided for @demoManager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get demoManager;

  /// No description provided for @demoSecurityAdmin.
  ///
  /// In en, this message translates to:
  /// **'Security Admin'**
  String get demoSecurityAdmin;

  /// No description provided for @demoSystemAdmin.
  ///
  /// In en, this message translates to:
  /// **'System Admin'**
  String get demoSystemAdmin;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @sessionRestoring.
  ///
  /// In en, this message translates to:
  /// **'Restoring your session…'**
  String get sessionRestoring;

  /// No description provided for @signedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {name}'**
  String signedInAs(String name);

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @employeeNumber.
  ///
  /// In en, this message translates to:
  /// **'Employee number'**
  String get employeeNumber;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get notAvailable;

  /// No description provided for @roleEmployee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get roleEmployee;

  /// No description provided for @roleManager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get roleManager;

  /// No description provided for @roleSecurityAdmin.
  ///
  /// In en, this message translates to:
  /// **'Security Admin'**
  String get roleSecurityAdmin;

  /// No description provided for @roleSystemAdmin.
  ///
  /// In en, this message translates to:
  /// **'System Admin'**
  String get roleSystemAdmin;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get appVersion;

  /// No description provided for @apiEnvironment.
  ///
  /// In en, this message translates to:
  /// **'API environment'**
  String get apiEnvironment;

  /// No description provided for @apiBaseUrl.
  ///
  /// In en, this message translates to:
  /// **'API base URL'**
  String get apiBaseUrl;

  /// No description provided for @filterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get filterPending;

  /// No description provided for @filterCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get filterCompleted;

  /// No description provided for @filterRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get filterRejected;

  /// No description provided for @requestDetail.
  ///
  /// In en, this message translates to:
  /// **'Request detail'**
  String get requestDetail;

  /// No description provided for @requester.
  ///
  /// In en, this message translates to:
  /// **'Requester'**
  String get requester;

  /// No description provided for @riskLevel.
  ///
  /// In en, this message translates to:
  /// **'Risk level'**
  String get riskLevel;

  /// No description provided for @currentStage.
  ///
  /// In en, this message translates to:
  /// **'Current stage'**
  String get currentStage;

  /// No description provided for @nextApprover.
  ///
  /// In en, this message translates to:
  /// **'Next approver'**
  String get nextApprover;

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @noTimelineEvents.
  ///
  /// In en, this message translates to:
  /// **'No timeline events yet.'**
  String get noTimelineEvents;

  /// No description provided for @cancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get cancelRequest;

  /// No description provided for @cancelRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this request?'**
  String get cancelRequestTitle;

  /// No description provided for @cancelRequestMessage.
  ///
  /// In en, this message translates to:
  /// **'Cancel request {requestNumber}? This cannot be undone.'**
  String cancelRequestMessage(String requestNumber);

  /// No description provided for @requestCancelled.
  ///
  /// In en, this message translates to:
  /// **'Request cancelled.'**
  String get requestCancelled;

  /// No description provided for @requestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Request {requestNumber} submitted.'**
  String requestSubmitted(String requestNumber);

  /// No description provided for @newAccessRequestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a system and role, then explain why you need access.'**
  String get newAccessRequestSubtitle;

  /// No description provided for @justificationHelper.
  ///
  /// In en, this message translates to:
  /// **'At least {min} characters.'**
  String justificationHelper(int min);

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get selectDate;

  /// No description provided for @durationTemporary.
  ///
  /// In en, this message translates to:
  /// **'Temporary'**
  String get durationTemporary;

  /// No description provided for @durationPermanent.
  ///
  /// In en, this message translates to:
  /// **'Permanent'**
  String get durationPermanent;

  /// No description provided for @urgencyNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get urgencyNormal;

  /// No description provided for @urgencyUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get urgencyUrgent;

  /// No description provided for @urgencyCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get urgencyCritical;

  /// No description provided for @stageRequester.
  ///
  /// In en, this message translates to:
  /// **'Requester'**
  String get stageRequester;

  /// No description provided for @stageManager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get stageManager;

  /// No description provided for @stageSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get stageSecurity;

  /// No description provided for @stageProvisioning.
  ///
  /// In en, this message translates to:
  /// **'Provisioning'**
  String get stageProvisioning;

  /// No description provided for @stageComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get stageComplete;

  /// No description provided for @riskLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get riskLow;

  /// No description provided for @riskMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get riskMedium;

  /// No description provided for @riskHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get riskHigh;

  /// No description provided for @riskCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get riskCritical;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// No description provided for @approvalDetail.
  ///
  /// In en, this message translates to:
  /// **'Approval decision'**
  String get approvalDetail;

  /// No description provided for @approvalStageManager.
  ///
  /// In en, this message translates to:
  /// **'Manager approval'**
  String get approvalStageManager;

  /// No description provided for @approvalStageSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security approval'**
  String get approvalStageSecurity;

  /// No description provided for @approvalStageLabel.
  ///
  /// In en, this message translates to:
  /// **'Stage: {stage}'**
  String approvalStageLabel(String stage);

  /// No description provided for @noApprovalsMessage.
  ///
  /// In en, this message translates to:
  /// **'You are all caught up.'**
  String get noApprovalsMessage;

  /// No description provided for @noCompletedApprovals.
  ///
  /// In en, this message translates to:
  /// **'No completed approvals'**
  String get noCompletedApprovals;

  /// No description provided for @noCompletedApprovalsMessage.
  ///
  /// In en, this message translates to:
  /// **'Decided tasks will appear here.'**
  String get noCompletedApprovalsMessage;

  /// No description provided for @approveConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Approve this request?'**
  String get approveConfirmTitle;

  /// No description provided for @approveConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to approve access request {requestNumber}?'**
  String approveConfirmMessage(String requestNumber);

  /// No description provided for @rejectConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject this request?'**
  String get rejectConfirmTitle;

  /// No description provided for @rejectConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Please provide a rejection reason.'**
  String get rejectConfirmMessage;

  /// No description provided for @optionalComment.
  ///
  /// In en, this message translates to:
  /// **'Comment (optional)'**
  String get optionalComment;

  /// No description provided for @optionalCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Add a note for the requester or next approver.'**
  String get optionalCommentHint;

  /// No description provided for @rejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Rejection reason'**
  String get rejectionReason;

  /// No description provided for @rejectionReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Explain why this request is rejected.'**
  String get rejectionReasonHint;

  /// No description provided for @rejectionCommentRequired.
  ///
  /// In en, this message translates to:
  /// **'A rejection reason is required.'**
  String get rejectionCommentRequired;

  /// No description provided for @decisionComment.
  ///
  /// In en, this message translates to:
  /// **'Decision comment'**
  String get decisionComment;

  /// No description provided for @confirmApprove.
  ///
  /// In en, this message translates to:
  /// **'Confirm approve'**
  String get confirmApprove;

  /// No description provided for @confirmReject.
  ///
  /// In en, this message translates to:
  /// **'Confirm reject'**
  String get confirmReject;

  /// No description provided for @approvalApprovedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request {requestNumber} approved.'**
  String approvalApprovedSuccess(String requestNumber);

  /// No description provided for @approvalRejectedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request {requestNumber} rejected.'**
  String approvalRejectedSuccess(String requestNumber);

  /// No description provided for @errorApprovalNotFound.
  ///
  /// In en, this message translates to:
  /// **'This approval task could not be found.'**
  String get errorApprovalNotFound;

  /// No description provided for @errorApprovalNotPending.
  ///
  /// In en, this message translates to:
  /// **'This approval has already been decided.'**
  String get errorApprovalNotPending;

  /// No description provided for @errorNotTaskAssignee.
  ///
  /// In en, this message translates to:
  /// **'Only the assigned approver can decide this task.'**
  String get errorNotTaskAssignee;

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission for this action.'**
  String get errorForbidden;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @viewMetadata.
  ///
  /// In en, this message translates to:
  /// **'View metadata'**
  String get viewMetadata;

  /// No description provided for @searchActorEmail.
  ///
  /// In en, this message translates to:
  /// **'Search by actor email'**
  String get searchActorEmail;

  /// No description provided for @filterAction.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get filterAction;

  /// No description provided for @filterEntityType.
  ///
  /// In en, this message translates to:
  /// **'Entity'**
  String get filterEntityType;

  /// No description provided for @filterFromDate.
  ///
  /// In en, this message translates to:
  /// **'From date'**
  String get filterFromDate;

  /// No description provided for @filterToDate.
  ///
  /// In en, this message translates to:
  /// **'To date'**
  String get filterToDate;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @noAuditLogs.
  ///
  /// In en, this message translates to:
  /// **'No audit logs match your filters'**
  String get noAuditLogs;

  /// No description provided for @noAuditLogsMessage.
  ///
  /// In en, this message translates to:
  /// **'Security and admin events will appear here.'**
  String get noAuditLogsMessage;

  /// No description provided for @noAuditLogsFilteredMessage.
  ///
  /// In en, this message translates to:
  /// **'Try changing the filters.'**
  String get noAuditLogsFilteredMessage;

  /// No description provided for @auditActorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown actor'**
  String get auditActorUnknown;

  /// No description provided for @auditEntityLabel.
  ///
  /// In en, this message translates to:
  /// **'Entity: {entityType}'**
  String auditEntityLabel(String entityType);

  /// No description provided for @auditMetadataTitle.
  ///
  /// In en, this message translates to:
  /// **'Audit event detail'**
  String get auditMetadataTitle;

  /// No description provided for @auditNoMetadata.
  ///
  /// In en, this message translates to:
  /// **'No metadata recorded.'**
  String get auditNoMetadata;

  /// No description provided for @auditFieldAction.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get auditFieldAction;

  /// No description provided for @auditFieldActor.
  ///
  /// In en, this message translates to:
  /// **'Actor'**
  String get auditFieldActor;

  /// No description provided for @auditFieldEntity.
  ///
  /// In en, this message translates to:
  /// **'Entity type'**
  String get auditFieldEntity;

  /// No description provided for @auditFieldEntityId.
  ///
  /// In en, this message translates to:
  /// **'Entity ID'**
  String get auditFieldEntityId;

  /// No description provided for @auditFieldWhen.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get auditFieldWhen;

  /// No description provided for @auditFieldIp.
  ///
  /// In en, this message translates to:
  /// **'IP address'**
  String get auditFieldIp;

  /// No description provided for @auditFieldUserAgent.
  ///
  /// In en, this message translates to:
  /// **'User agent'**
  String get auditFieldUserAgent;

  /// No description provided for @auditFieldMetadata.
  ///
  /// In en, this message translates to:
  /// **'Metadata'**
  String get auditFieldMetadata;

  /// No description provided for @previousPage.
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get previousPage;

  /// No description provided for @nextPage.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get nextPage;

  /// No description provided for @auditPageStatus.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {totalPages} · {total} events'**
  String auditPageStatus(int page, int totalPages, int total);

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'The requested item could not be found.'**
  String get errorNotFound;

  /// No description provided for @errorInvalidAudienceFilter.
  ///
  /// In en, this message translates to:
  /// **'The notification audience selection is invalid.'**
  String get errorInvalidAudienceFilter;

  /// No description provided for @errorFusionConfigurationMissing.
  ///
  /// In en, this message translates to:
  /// **'Oracle Fusion is not configured for this environment.'**
  String get errorFusionConfigurationMissing;

  /// No description provided for @errorFusionProvisioningFailed.
  ///
  /// In en, this message translates to:
  /// **'Provisioning with Oracle Fusion failed. Try again later.'**
  String get errorFusionProvisioningFailed;

  /// No description provided for @auditActionAuthLogin.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get auditActionAuthLogin;

  /// No description provided for @auditActionAuthLogout.
  ///
  /// In en, this message translates to:
  /// **'Signed out'**
  String get auditActionAuthLogout;

  /// No description provided for @auditActionNotificationCreated.
  ///
  /// In en, this message translates to:
  /// **'Notification created'**
  String get auditActionNotificationCreated;

  /// No description provided for @auditActionNotificationPublished.
  ///
  /// In en, this message translates to:
  /// **'Notification published'**
  String get auditActionNotificationPublished;

  /// No description provided for @auditActionNotificationRead.
  ///
  /// In en, this message translates to:
  /// **'Notification read'**
  String get auditActionNotificationRead;

  /// No description provided for @auditActionNotificationCancelled.
  ///
  /// In en, this message translates to:
  /// **'Notification cancelled'**
  String get auditActionNotificationCancelled;

  /// No description provided for @auditActionAccessRequestSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Access request submitted'**
  String get auditActionAccessRequestSubmitted;

  /// No description provided for @auditActionAccessRequestCancelled.
  ///
  /// In en, this message translates to:
  /// **'Access request cancelled'**
  String get auditActionAccessRequestCancelled;

  /// No description provided for @auditActionAccessRequestProvisioningStarted.
  ///
  /// In en, this message translates to:
  /// **'Provisioning started'**
  String get auditActionAccessRequestProvisioningStarted;

  /// No description provided for @auditActionAccessRequestCompleted.
  ///
  /// In en, this message translates to:
  /// **'Access request completed'**
  String get auditActionAccessRequestCompleted;

  /// No description provided for @auditActionAccessRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Access request failed'**
  String get auditActionAccessRequestFailed;

  /// No description provided for @auditActionApprovalManagerApproved.
  ///
  /// In en, this message translates to:
  /// **'Manager approved'**
  String get auditActionApprovalManagerApproved;

  /// No description provided for @auditActionApprovalManagerRejected.
  ///
  /// In en, this message translates to:
  /// **'Manager rejected'**
  String get auditActionApprovalManagerRejected;

  /// No description provided for @auditActionApprovalSecurityApproved.
  ///
  /// In en, this message translates to:
  /// **'Security approved'**
  String get auditActionApprovalSecurityApproved;

  /// No description provided for @auditActionApprovalSecurityRejected.
  ///
  /// In en, this message translates to:
  /// **'Security rejected'**
  String get auditActionApprovalSecurityRejected;

  /// No description provided for @auditEntityUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get auditEntityUser;

  /// No description provided for @auditEntityNotification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get auditEntityNotification;

  /// No description provided for @auditEntityAccessRequest.
  ///
  /// In en, this message translates to:
  /// **'Access request'**
  String get auditEntityAccessRequest;

  /// No description provided for @auditEntityApprovalTask.
  ///
  /// In en, this message translates to:
  /// **'Approval task'**
  String get auditEntityApprovalTask;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
