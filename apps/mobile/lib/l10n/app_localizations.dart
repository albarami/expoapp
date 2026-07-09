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

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @foundationPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Foundation screen — feature UI arrives in a later task.'**
  String get foundationPlaceholder;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotifications;

  /// No description provided for @noNotificationsMessage.
  ///
  /// In en, this message translates to:
  /// **'You will see important announcements here.'**
  String get noNotificationsMessage;

  /// No description provided for @noRequests.
  ///
  /// In en, this message translates to:
  /// **'No requests yet'**
  String get noRequests;

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
  /// **'Network error. Check your connection and try again.'**
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

  /// No description provided for @priorityUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get priorityUrgent;

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
