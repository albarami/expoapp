# Personas, Roles, and Permissions

## Personas

### Employee

An employee uses the app to receive announcements and request access.

Primary goals:

- See important notifications quickly.
- Submit a security access request.
- Track request status.
- Understand why a request was approved/rejected.

### Manager

A manager approves or rejects access requests submitted by direct reports.

Primary goals:

- See pending approvals.
- Review request details and justification.
- Approve or reject with comment.
- Track team request history.

### Security Administrator

A security admin validates and completes security access.

Primary goals:

- See requests approved by managers.
- Verify requested role/system.
- Approve, reject, or mark provisioning complete.
- Maintain audit trail.

### System Administrator

A system admin manages communications and system-level demo data.

Primary goals:

- Create notifications.
- Select audience.
- View delivery/read statistics.
- View audit logs.
- Manage reference data in future phases.

## Application roles

| Role code | Description |
|---|---|
| `EMPLOYEE` | Basic user |
| `MANAGER` | Employee with approval rights for direct reports |
| `SECURITY_ADMIN` | Security/access workflow owner |
| `SYSTEM_ADMIN` | App administration and notification owner |

## Permission matrix

| Feature/action | Employee | Manager | Security Admin | System Admin |
|---|---:|---:|---:|---:|
| Login | Yes | Yes | Yes | Yes |
| View own dashboard | Yes | Yes | Yes | Yes |
| View own notifications | Yes | Yes | Yes | Yes |
| Mark own notification as read | Yes | Yes | Yes | Yes |
| Create notification | No | No | Optional | Yes |
| Publish notification | No | No | Optional | Yes |
| View notification stats | No | No | Optional | Yes |
| Submit own access request | Yes | Yes | Yes | Yes |
| View own access requests | Yes | Yes | Yes | Yes |
| Approve direct report request | No | Yes | No | No |
| View security approval queue | No | No | Yes | Optional |
| Security approve/reject | No | No | Yes | Optional |
| Mark request provisioned/completed | No | No | Yes | Optional |
| View audit logs | No | No | Yes | Yes |
| Manage users | No | No | No | Future |
| Manage reference data | No | No | Future | Future |

## Backend RBAC rules

Backend enforcement is mandatory. UI hiding is not sufficient.

| Endpoint | Required roles |
|---|---|
| `GET /auth/me` | authenticated |
| `GET /notifications` | authenticated |
| `POST /notifications` | `SYSTEM_ADMIN`, optionally `SECURITY_ADMIN` |
| `GET /notifications/stats` | `SYSTEM_ADMIN`, optionally `SECURITY_ADMIN` |
| `POST /access-requests` | authenticated |
| `GET /access-requests` | authenticated; scoped by role |
| `GET /approvals` | `MANAGER`, `SECURITY_ADMIN`, `SYSTEM_ADMIN` |
| `POST /approvals/:id/decision` | task assignee or privileged admin |
| `GET /audit-logs` | `SECURITY_ADMIN`, `SYSTEM_ADMIN` |

## Data visibility rules

### Employee

Can see:

- Own profile
- Own notifications
- Own access requests
- Own request comments and decisions

Cannot see:

- Other users' requests
- Approval queue
- Audit logs
- Admin notification composer

### Manager

Can see:

- Own profile/data
- Own notifications/requests
- Approval tasks assigned to self
- Requests from direct reports only when assigned as approval task

Cannot see:

- Other managers' queues
- Full audit logs unless also admin
- Security admin queue unless also security admin

### Security Admin

Can see:

- Security approval queue
- Requests that reached security approval
- Audit logs related to access workflow
- Security role catalog

Cannot see:

- Unrelated private employee data beyond what is required for access decisions

### System Admin

Can see:

- Notification administration
- Audit logs
- Dashboard statistics
- Demo/system configuration

## UI routing by role

### Employee tab bar

- Home
- Notifications
- Requests
- Profile

### Manager tab bar

- Home
- Notifications
- Requests
- Approvals
- Profile

### Security Admin tab bar

- Home
- Notifications
- Security Queue
- Audit
- Profile

### System Admin tab bar

- Home
- Notifications
- Create
- Audit
- Profile
