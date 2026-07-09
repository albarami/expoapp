# Mobile Screen Specifications

## General screen requirements

Every screen must support:

- English/Arabic text
- RTL layout
- Loading state
- Error state
- Empty state where relevant
- Pull-to-refresh for list screens
- Safe area
- Responsive layout
- Clear action buttons

## 1. Splash / Startup

Purpose:

- Initialize app.
- Check saved token.
- Determine route.

UI:

- App logo placeholder
- Loading indicator
- Optional environment label in debug mode

Behavior:

- If valid session -> dashboard.
- If no session -> login.

## 2. Login

Fields:

- Email
- Password
- Language toggle
- Login button

Demo mode:

- Show quick login cards:
  - Employee
  - Manager
  - Security Admin
  - System Admin

Validation:

- Email required.
- Password required.
- Invalid credentials show localized error.

API:

- `POST /auth/login`

## 3. Dashboard

Purpose:

Role-based overview.

Employee widgets:

- Unread notifications
- Open access requests
- Latest notifications
- Latest requests
- Quick action: New Access Request

Manager widgets:

- Pending approvals
- Team requests summary
- Latest notifications

Security Admin widgets:

- Pending security approvals
- High-risk requests
- Recent audit events

System Admin widgets:

- Notification stats
- Access workflow stats
- Quick action: Create Notification
- Recent audit events

API:

- `GET /dashboard/summary`

## 4. Notifications List

Elements:

- Header
- Search
- Filter chips
- Notification cards
- Pull-to-refresh

Filters:

- All
- Unread
- High
- Critical

Card:

- Localized title
- Localized preview
- Priority chip
- Unread indicator
- Created date

API:

- `GET /notifications`

## 5. Notification Detail

Elements:

- Title
- Priority
- Body
- Created date
- Read status
- Mark as read button

API:

- `GET /notifications/:id`
- `PATCH /notifications/:id/read`

Behavior:

- If unread, mark as read either on open or with button. Prefer explicit button for demo clarity.

## 6. Create Notification

Role:

- System Admin

Fields:

- Title EN
- Title AR
- Body EN
- Body AR
- Priority
- Audience type
- Audience values
- Publish now/schedule
- Expiry date
- Preview

Actions:

- Save/publish
- Cancel

API:

- `POST /notifications`

Validation:

- Title/body required.
- Audience required.
- Critical confirmation required.

## 7. My Requests

Elements:

- Status tabs: All, Pending, Completed, Rejected
- Request cards
- New request FAB/button

Card:

- Request number
- System
- Security role
- Status chip
- Current stage
- Created date

API:

- `GET /access-requests?mineOnly=true`

## 8. New Access Request

Fields:

- System dropdown
- Security role dropdown
- Business justification
- Duration
- Start date
- End date
- Urgency

Behavior:

- Role list filters by system.
- Temporary duration requires end date.
- Submit disabled until valid.

API:

- `GET /reference-data`
- `POST /access-requests`

Success:

- Show request number.
- Navigate to request detail.

## 9. Request Detail

Elements:

- Request number
- Requester
- System
- Role
- Risk level
- Business justification
- Date range
- Status chip
- Timeline
- Cancel button if requester and cancellable

API:

- `GET /access-requests/:id`
- `PATCH /access-requests/:id/cancel`

## 10. Approval Queue

Roles:

- Manager
- Security Admin
- System Admin optional

Elements:

- Pending/Completed toggle
- Approval cards
- Risk/urgency chips

API:

- `GET /approvals?status=PENDING`

## 11. Approval Detail / Decision

Can be same request detail screen with approve/reject buttons if current user has pending task.

Approve flow:

- Tap Approve.
- Confirmation bottom sheet.
- Optional comment.
- Submit.
- Show success.

Reject flow:

- Tap Reject.
- Required comment.
- Submit.
- Show success.

API:

- `POST /approvals/:taskId/decision`

## 12. Audit Logs

Roles:

- Security Admin
- System Admin

Elements:

- Date filters
- Action filter
- Search actor/email
- Log cards/table
- Metadata detail modal

API:

- `GET /audit-logs`

## 13. Profile

Elements:

- Name
- Email
- Role
- Department
- Employee number
- Language setting
- Logout button

API:

- `GET /auth/me`
- `POST /auth/logout`

## 14. Settings

Elements:

- Language selector
- Theme mode future
- App version
- API environment in debug mode

## Screen quality checklist

For each screen, Cursor must confirm:

- UI is not blank on success.
- Loading state displays.
- Error state displays retry.
- Empty state is meaningful.
- Arabic labels exist.
- No overflow in RTL.
- Buttons cannot double-submit.
- Forms show validation before API call.
