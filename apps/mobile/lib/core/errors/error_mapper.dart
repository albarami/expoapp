import '../../l10n/app_localizations.dart';
import '../api/api_error.dart';

/// Maps known API error codes to localized user-facing messages.
String localizeApiError(AppLocalizations l10n, ApiError error) {
  switch (error.code) {
    case 'MANAGER_NOT_FOUND':
      return l10n.errorManagerNotFound;
    case 'ROLE_NOT_REQUESTABLE':
      return l10n.errorRoleNotRequestable;
    case 'DUPLICATE_ACTIVE_REQUEST':
      return l10n.errorDuplicateActiveRequest;
    case 'INVALID_ACCESS_DATES':
      return l10n.errorInvalidAccessDates;
    case 'REQUEST_NOT_CANCELABLE':
      return l10n.errorRequestNotCancelable;
    case 'USER_INACTIVE':
      return l10n.errorUserInactive;
    case 'VALIDATION_ERROR':
      return l10n.errorValidation;
    case 'UNAUTHORIZED':
      return l10n.errorUnauthorized;
    case 'NETWORK_ERROR':
      return l10n.networkError;
    default:
      return error.message.isNotEmpty ? error.message : l10n.errorGeneric;
  }
}
