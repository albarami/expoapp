# Admin Experience Specification

## Admin scope

Admin functionality is built into the same Flutter application and exposed only to authorized roles.

Primary admin role:

- System Admin

Optional admin role:

- Security Admin for audit/security views

## Admin dashboard

System Admin home should show:

- Total published notifications
- Total recipients
- Read percentage
- Open access requests
- Pending manager approvals
- Pending security approvals
- Recent audit events
- Quick action: Create notification

## Create notification screen

Fields:

1. English title
2. Arabic title
3. English body
4. Arabic body
5. Priority
6. Audience type
7. Audience values
8. Publish now/schedule
9. Expiration date
10. Preview card

Validation messages must be localized.

## Audience selector behavior

### ALL

Show warning:

```text
This notification will be sent to all active users.
```

### DEPARTMENT

Show multi-select department list.

### ROLE

Show multi-select app roles:

- Employee
- Manager
- Security Admin
- System Admin

### USERS

Show searchable user picker.

For Phase 1, user picker can be simple list from `/users`.

## Notification publish confirmation

For `CRITICAL` priority, require confirmation:

```text
You are about to publish a critical notification. Continue?
```

Arabic:

```text
أنت على وشك نشر تنبيه حرج. هل تريد المتابعة؟
```

## Notification stats

Stats screen for each notification:

- Recipient count
- Delivered count
- Read count
- Unread count
- Read percentage
- Created by
- Published date
- Audience type
- Priority

## Audit log viewer

Admin can:

- Filter by action
- Filter by date
- Filter by actor email
- Open metadata details

## Security admin queue

Security Admin should have a focused queue:

- Pending security approvals
- High-risk requests first
- Critical urgency highlighted
- Request detail
- Approve/reject action

## Empty states

| Screen | Empty message |
|---|---|
| Notification stats | No recipient statistics available yet |
| Create notification audience | No matching users found |
| Audit logs | No audit logs match your filters |
| Security queue | No security approvals pending |

## Admin anti-patterns to avoid

- Do not expose admin actions through hidden buttons only.
- Do not rely on frontend role checks only.
- Do not publish notifications without backend validation.
- Do not allow empty audience.
- Do not allow critical notification without explicit confirmation.
