# Flutter Architecture Specification

## App goal

Build a fast, polished iOS/Android app with role-based workflows and admin functionality.

## Required packages

Recommended `pubspec.yaml` dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  go_router: ^14.0.0
  flutter_riverpod: ^2.5.0
  dio: ^5.0.0
  flutter_secure_storage: ^9.0.0
  intl: any
  json_annotation: ^4.9.0
  uuid: ^4.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.0
  json_serializable: ^6.8.0
```

If dependency versions conflict, use latest compatible versions from `flutter pub add`.

## Architecture style

Use feature-first clean architecture:

```text
features/
  notifications/
    data/
      notification_api.dart
      notification_repository_impl.dart
      models/
    domain/
      notification.dart
      notification_repository.dart
    presentation/
      screens/
      widgets/
      providers/
```

## State management

Use Riverpod.

Provider categories:

- `sessionControllerProvider`
- `apiClientProvider`
- `dashboardProvider`
- `notificationsProvider`
- `notificationDetailsProvider`
- `accessRequestsProvider`
- `accessRequestDetailsProvider`
- `approvalTasksProvider`
- `auditLogsProvider`
- `referenceDataProvider`

Use `AsyncValue` for loading/error/data.

## Routing

Use GoRouter.

| Route | Screen | Auth required |
|---|---|---:|
| `/login` | Login | No |
| `/` | App shell/dashboard | Yes |
| `/notifications` | Notifications list | Yes |
| `/notifications/:id` | Notification details | Yes |
| `/admin/notifications/create` | Create notification | System Admin |
| `/requests` | My requests | Yes |
| `/requests/new` | New access request | Yes |
| `/requests/:id` | Request details | Yes |
| `/approvals` | Approval queue | Manager/Security Admin/System Admin |
| `/audit` | Audit logs | Security Admin/System Admin |
| `/profile` | Profile | Yes |
| `/settings` | Settings | Yes |

## App shell

The app shell changes tabs based on role.

### Employee tabs

- Home
- Notifications
- Requests
- Profile

### Manager tabs

- Home
- Notifications
- Requests
- Approvals
- Profile

### Security Admin tabs

- Home
- Notifications
- Security
- Audit
- Profile

### System Admin tabs

- Home
- Notifications
- Create
- Audit
- Profile

## API client

Create `core/api/api_client.dart`.

Requirements:

- Base URL from config.
- Adds `Authorization: Bearer <token>`.
- Handles 401 by clearing session and redirecting to login.
- Converts errors to typed `ApiError`.
- Logs only safe debug info in development.

## Token storage

Use `flutter_secure_storage`.

Store:

- `accessToken`
- `refreshToken`
- basic cached `currentUser` JSON if useful

Do not store password.

## Models

Use JSON serialization for API DTOs or implement robust manual `fromJson`.

Required models:

- `User`
- `Department`
- `AppSystem`
- `SecurityRole`
- `Notification`
- `NotificationStats`
- `AccessRequest`
- `ApprovalTask`
- `AuditLog`
- `DashboardSummary`
- `ReferenceData`
- `ApiError`
- `PaginatedResponse<T>`

## UI style

Use Material 3. Create reusable widgets:

- `ExpoAppScaffold`
- `ExpoCard`
- `ExpoPrimaryButton`
- `ExpoSecondaryButton`
- `ExpoTextField`
- `StatusChip`
- `PriorityChip`
- `LoadingView`
- `EmptyState`
- `ErrorState`
- `ConfirmDecisionSheet`
- `LanguageSwitcher`

## Localization

All strings must be in ARB files.

No hardcoded UI strings except temporary debug labels.

## Performance

- Avoid heavy work in build methods.
- Use paginated lists.
- Cache reference data for current app session.
- Use skeleton/loading states for dashboard.
- Use Pull-to-refresh on lists.
- Avoid unnecessary rebuilds by splitting widgets.

## Error UX

Every async screen must have:

- Loading state
- Empty state
- Error state with retry
- Successful populated state

## Accessibility

- Buttons need clear labels.
- Critical actions require confirmation.
- Text sizes respect system accessibility scale.
- Use semantic labels for icons where meaningful.
- Support RTL layout.
