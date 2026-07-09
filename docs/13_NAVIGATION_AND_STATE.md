# Navigation and State

## Session states

The app has these session states:

```text
unknown -> unauthenticated -> authenticating -> authenticated -> expired
```

On app start:

1. Load token from secure storage.
2. If token exists, call `/auth/me`.
3. If valid, enter authenticated state.
4. If invalid, clear token and show login.

## Route guarding

Rules:

- `/login` available only when unauthenticated.
- Authenticated users redirected from `/login` to `/`.
- Role-protected routes redirect to `/` and show unauthorized snackbar/dialog.
- Backend still enforces all permissions.

## App shell behavior

The main shell must use bottom navigation on mobile.

On wider web view, it may use navigation rail/sidebar.

## Navigation route definitions

```dart
/login
/
/notifications
/notifications/:id
/admin/notifications/create
/requests
/requests/new
/requests/:id
/approvals
/audit
/profile
/settings
```

## State refresh rules

### After login

Refresh:

- current user
- reference data
- dashboard summary

### After notification read

Refresh:

- notification detail
- notifications list
- dashboard unread count

### After notification created

Refresh:

- notifications list
- dashboard summary
- notification stats

### After access request submission

Refresh:

- my requests
- dashboard summary

### After approval decision

Refresh:

- approval queue
- request details
- dashboard summary
- audit logs if visible

## Recommended providers

```dart
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(...));

final sessionControllerProvider =
    StateNotifierProvider<SessionController, SessionState>((ref) => ...);

final dashboardProvider =
    FutureProvider.autoDispose<DashboardSummary>((ref) async => ...);

final notificationsProvider =
    FutureProvider.autoDispose.family<PaginatedResponse<Notification>, NotificationQuery>((ref, query) async => ...);

final referenceDataProvider =
    FutureProvider<ReferenceData>((ref) async => ...);
```

## Query object pattern

Use small immutable query classes:

```dart
class NotificationQuery {
  final int page;
  final int pageSize;
  final bool unreadOnly;
  final String? priority;
  final String? search;
}
```

## Avoid anti-patterns

- Do not put all state in one global provider.
- Do not fetch API directly inside widgets.
- Do not store API response maps directly in UI.
- Do not ignore cancellation/retry behavior.
- Do not mix Arabic/English strings inside widget code.

## Deep link readiness

Not required for Phase 1, but route structure should allow future deep links:

```text
expoapp://notifications/:id
expoapp://requests/:id
expoapp://approvals/:taskId
```
