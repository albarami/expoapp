# UI / UX Design System

## Design direction

Enterprise, premium, fast, clean. The app should look credible for Expo Saudi stakeholders without requiring final brand assets.

## Visual principles

- Clear hierarchy
- Large readable typography
- High contrast
- Minimal clutter
- Consistent spacing
- Fast interactions
- Professional cards and chips
- No playful/gaming aesthetic

## Brand assets

Do not use official Expo/Saudi logos unless provided by the client. Use a neutral placeholder mark:

```text
ExpoApp
```

or simple geometric app icon placeholder.

## Color tokens

Use theme tokens, not hardcoded colors in widgets.

Suggested tokens:

| Token | Usage |
|---|---|
| `primary` | Main actions |
| `secondary` | Supporting actions |
| `surface` | Cards/sheets |
| `background` | App background |
| `success` | Approved/completed |
| `warning` | Pending/urgent |
| `error` | Rejected/failed |
| `info` | Normal notification |

Cursor can implement with Material color scheme and avoid excessive custom colors.

## Typography

Use Material 3 text theme.

Hierarchy:

- Display/Headline: dashboard headings
- Title: cards/screen titles
- Body: content
- Label: chips/buttons

Arabic text must render correctly. Use system fonts unless supplied.

## Spacing

Use consistent spacing scale:

```dart
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}
```

## Radius

```dart
class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 20.0;
}
```

## Reusable widgets

### ExpoCard

Used for:

- Notification cards
- Request cards
- Approval cards
- Dashboard metric cards

### StatusChip

Accepts status enum and localized label.

### PriorityChip

Accepts priority enum.

### EmptyState

Properties:

- icon
- title
- message
- action label
- onAction

### ErrorState

Properties:

- title
- message
- retry

### ConfirmDecisionSheet

Used for approval/rejection.

## Interaction standards

- Tap targets minimum 44px.
- Critical actions require confirmation.
- Submit buttons show loading spinner while request is in flight.
- Disable duplicate submissions.
- Use snackbars for simple success messages.
- Use dialogs/bottom sheets for serious confirmations.

## Date/time display

Use localized date formatting.

Examples:

English:

```text
9 Jul 2026, 14:30
```

Arabic:

```text
٩ يوليو ٢٠٢٦، ١٤:٣٠
```

## Status chip labels

| Status | English | Arabic |
|---|---|---|
| `MANAGER_PENDING` | Pending Manager | بانتظار المدير |
| `SECURITY_PENDING` | Pending Security | بانتظار الأمن |
| `PROVISIONING` | Provisioning | جاري التنفيذ |
| `COMPLETED` | Completed | مكتمل |
| `MANAGER_REJECTED` | Rejected by Manager | مرفوض من المدير |
| `SECURITY_REJECTED` | Rejected by Security | مرفوض من الأمن |
| `CANCELLED` | Cancelled | ملغي |
| `FAILED` | Failed | فشل |

## Dashboard design

Use vertical sections:

1. Greeting and role
2. Metrics row/cards
3. Quick actions
4. Latest items

## List design

Use cards with:

- Title
- Subtitle
- Metadata row
- Status/priority chip
- Chevron/CTA

## Forms

Use grouped sections:

- Request details
- Access details
- Duration
- Justification

Show validation under fields.

## Loading states

Use skeleton-like placeholders or centered progress indicator. Keep it professional and fast.

## Empty states

Do not show blank screens.

Examples:

```text
No notifications yet.
You will see important announcements here.
```

Arabic:

```text
لا توجد إشعارات حتى الآن.
ستظهر الإعلانات المهمة هنا.
```
