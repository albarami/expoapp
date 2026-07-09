# Notifications Module

## Purpose

Allow authorized administrators to send one-to-many notifications to employees, departments, roles, or selected users. Employees receive notifications in-app, can read details, and mark notifications as read.

## Notification types

Initial supported channel:

- In-app notifications

Future channels:

- Push notification
- Email
- SMS

## Notification priority

| Priority | Meaning | UI treatment |
|---|---|---|
| `LOW` | Informational | Subtle chip |
| `NORMAL` | Standard | Default |
| `HIGH` | Important | Prominent chip |
| `CRITICAL` | Urgent | Requires confirmation when publishing |

## Audience types

### ALL

```json
{
  "audienceType": "ALL",
  "audienceFilter": {
    "all": true
  }
}
```

### DEPARTMENT

```json
{
  "audienceType": "DEPARTMENT",
  "audienceFilter": {
    "departmentCodes": ["OPS", "SEC"]
  }
}
```

### ROLE

```json
{
  "audienceType": "ROLE",
  "audienceFilter": {
    "roles": ["MANAGER", "SECURITY_ADMIN"]
  }
}
```

### USERS

```json
{
  "audienceType": "USERS",
  "audienceFilter": {
    "userIds": ["uuid-1", "uuid-2"]
  }
}
```

## Admin create notification workflow

1. Admin opens Create Notification.
2. Admin enters English title/body.
3. Admin optionally enters Arabic title/body.
4. Admin selects priority.
5. Admin selects audience type.
6. Admin selects audience values.
7. Admin chooses publish now or schedule.
8. App validates input.
9. If critical, app asks for confirmation.
10. API creates notification and recipient rows.
11. API returns recipient count.
12. Admin sees success confirmation.

## Employee notification workflow

1. Employee opens Notifications.
2. App calls `GET /notifications`.
3. User sees unread/read list.
4. User opens notification detail.
5. App calls `GET /notifications/:id`.
6. User taps "Mark as read" or opening detail marks read depending implementation.
7. App calls `PATCH /notifications/:id/read`.
8. Dashboard unread count updates.

## Backend recipient creation

When a notification is published:

1. Resolve audience to active users.
2. Exclude inactive users.
3. Create one `NotificationRecipient` per target user.
4. Set `deliveredAt` to current timestamp in mock mode.
5. Write audit log with recipient count.

## Validation rules

| Field | Rule |
|---|---|
| `titleEn` | Required, 3-120 characters |
| `titleAr` | Optional, 3-120 characters |
| `bodyEn` | Required, 3-2000 characters |
| `bodyAr` | Optional, 3-2000 characters |
| `priority` | Required enum |
| `audienceType` | Required enum |
| `audienceFilter` | Must match audience type |
| `publishAt` | Required only for schedule |
| `expiresAt` | Optional; must be after publish time |

## Screens

### Notification List

Components:

- Header with unread count
- Search field
- Filter chips: All, Unread, High, Critical
- List cards
- Pull to refresh
- Empty state
- Error state

Card fields:

- Title localized
- Body preview localized
- Priority chip
- Read/unread dot
- Created date
- Audience/admin indicator only if admin

### Notification Detail

Components:

- Title
- Priority
- Date
- Body
- Read status
- Mark as read button if unread
- Back button

### Admin Create Notification

Components:

- Title EN
- Title AR
- Body EN
- Body AR
- Priority selector
- Audience type selector
- Audience values selector
- Publish now/schedule toggle
- Expiry date optional
- Preview card
- Submit button

### Notification Stats

Admin-only view:

- Recipient count
- Delivered count
- Read count
- Unread count
- Read percentage

## Audit events

| Action | When |
|---|---|
| `NOTIFICATION_CREATED` | Notification created |
| `NOTIFICATION_PUBLISHED` | Notification recipients generated |
| `NOTIFICATION_READ` | User marks read |
| `NOTIFICATION_CANCELLED` | Admin cancels |

## Push notification future readiness

In Phase 1:

- Store device tokens if provided.
- Use `PUSH_MODE=mock`.
- Mock notification sender logs intended push operations.

In Phase 2:

- Implement Firebase Cloud Messaging for Android.
- Implement APNs for iOS directly or through Firebase.
- Respect user notification permission state.
