# Error Handling and Empty States

## API error codes

Use stable error codes so Flutter can localize messages.

| Code | HTTP | Meaning |
|---|---:|---|
| `VALIDATION_ERROR` | 400 | Invalid request body/query |
| `UNAUTHORIZED` | 401 | Missing/invalid token |
| `FORBIDDEN` | 403 | Authenticated but not allowed |
| `NOT_FOUND` | 404 | Entity not found |
| `MANAGER_NOT_FOUND` | 400 | Requester has no manager |
| `ROLE_NOT_REQUESTABLE` | 400 | Security role inactive/invalid |
| `DUPLICATE_ACTIVE_REQUEST` | 409 | Active request already exists |
| `REQUEST_NOT_CANCELABLE` | 400 | Cannot cancel current status |
| `APPROVAL_TASK_NOT_PENDING` | 400 | Task already decided |
| `NOT_TASK_ASSIGNEE` | 403 | User not assigned to task |
| `INVALID_AUDIENCE_FILTER` | 400 | Notification audience invalid |
| `FUSION_CONFIGURATION_MISSING` | 500 | Real adapter missing config |
| `FUSION_PROVISIONING_FAILED` | 502 | Oracle/OIC call failed |

## Flutter error mapping

Known backend error codes must map to localized UI text.

Example:

```dart
String messageForError(ApiError error, AppLocalizations l10n) {
  switch (error.code) {
    case 'MANAGER_NOT_FOUND':
      return l10n.errorManagerNotFound;
    case 'ROLE_NOT_REQUESTABLE':
      return l10n.errorRoleNotRequestable;
    default:
      return error.message;
  }
}
```

## Empty states

### Notifications

English:

```text
No notifications yet.
Important announcements will appear here.
```

Arabic:

```text
لا توجد إشعارات حتى الآن.
ستظهر الإعلانات المهمة هنا.
```

### Requests

English:

```text
No access requests yet.
Create your first security access request.
```

Arabic:

```text
لا توجد طلبات صلاحيات حتى الآن.
أنشئ أول طلب صلاحية أمنية.
```

### Approvals

English:

```text
No approvals pending.
You are all caught up.
```

Arabic:

```text
لا توجد موافقات معلقة.
أنت على اطلاع كامل.
```

### Audit

English:

```text
No audit logs match your filters.
Try changing the filters.
```

Arabic:

```text
لا توجد سجلات تدقيق تطابق عوامل التصفية.
حاول تغيير عوامل التصفية.
```

## Loading states

Use screen-specific loading:

- Dashboard: metric card skeleton/spinner.
- Lists: list placeholder/spinner.
- Forms: disable submit and show button spinner.
- Detail: full detail spinner.

## Retry behavior

Every failed API loading screen must have retry.

## Network offline

Message:

English:

```text
Cannot connect to the server. Check your network and try again.
```

Arabic:

```text
لا يمكن الاتصال بالخادم. تحقق من الشبكة وحاول مرة أخرى.
```

## Form errors

Show validation near the field. Also disable submit until required fields are valid where practical.

## Backend exception filter

Implement global exception filter to produce consistent envelope.

## Trace ID

Every API response should include a trace ID. Flutter may show it in debug details for support.
