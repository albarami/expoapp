# API Contract

## Base URL

```text
http://localhost:3000/api/v1
```

## Response envelope

All successful responses should follow:

```json
{
  "data": {},
  "meta": {
    "traceId": "string",
    "timestamp": "2026-07-09T12:00:00.000Z"
  }
}
```

Paginated responses:

```json
{
  "data": [],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "total": 100,
    "totalPages": 5
  },
  "meta": {
    "traceId": "string",
    "timestamp": "2026-07-09T12:00:00.000Z"
  }
}
```

Error response:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Business justification must be at least 20 characters.",
    "details": [
      {
        "field": "businessJustification",
        "message": "Minimum length is 20 characters."
      }
    ]
  },
  "meta": {
    "traceId": "string",
    "timestamp": "2026-07-09T12:00:00.000Z"
  }
}
```

## Endpoint summary

| Method | Endpoint | Purpose | Roles |
|---|---|---|---|
| GET | `/health` | Health check | Public |
| POST | `/auth/login` | Login | Public |
| GET | `/auth/me` | Current user | Authenticated |
| POST | `/auth/logout` | Logout | Authenticated |
| GET | `/dashboard/summary` | Role dashboard | Authenticated |
| GET | `/reference-data` | Departments/systems/roles | Authenticated |
| GET | `/notifications` | User notifications | Authenticated |
| GET | `/notifications/:id` | Notification detail | Authenticated |
| PATCH | `/notifications/:id/read` | Mark read | Authenticated |
| POST | `/notifications` | Create/publish notification | System Admin |
| GET | `/notifications/:id/stats` | Notification stats | System Admin/Security Admin |
| POST | `/notifications/:id/cancel` | Cancel notification | System Admin |
| GET | `/access-requests` | List requests | Authenticated, scoped |
| POST | `/access-requests` | Submit request | Authenticated |
| GET | `/access-requests/:id` | Request detail | Authenticated, scoped |
| PATCH | `/access-requests/:id/cancel` | Cancel request | Requester if allowed |
| GET | `/approvals` | Assigned approvals | Manager/Security Admin |
| POST | `/approvals/:taskId/decision` | Approve/reject | Task assignee |
| GET | `/audit-logs` | Audit log list | Security Admin/System Admin |
| GET | `/users` | User lookup for admin audience | System Admin |
| POST | `/device-tokens` | Store device token | Authenticated |

## Authentication

### POST `/auth/login`

Request:

```json
{
  "email": "noura.alharbi@expo.sa",
  "password": "Password123!"
}
```

Response:

```json
{
  "data": {
    "accessToken": "jwt",
    "refreshToken": "jwt-or-demo-token",
    "user": {
      "id": "uuid",
      "email": "noura.alharbi@expo.sa",
      "fullNameEn": "Noura Alharbi",
      "fullNameAr": "نورة الحربي",
      "role": "EMPLOYEE",
      "department": {
        "id": "uuid",
        "code": "OPS",
        "nameEn": "Operations",
        "nameAr": "العمليات"
      }
    }
  }
}
```

### GET `/auth/me`

Headers:

```text
Authorization: Bearer <token>
```

Response:

```json
{
  "data": {
    "id": "uuid",
    "email": "admin@expo.sa",
    "role": "SYSTEM_ADMIN",
    "permissions": [
      "notifications:create",
      "notifications:publish",
      "audit:read"
    ]
  }
}
```

## Dashboard

### GET `/dashboard/summary`

Role-aware response.

Employee response:

```json
{
  "data": {
    "unreadNotifications": 4,
    "openAccessRequests": 2,
    "completedRequests": 5,
    "pendingApprovals": 0,
    "latestNotifications": [],
    "latestRequests": []
  }
}
```

## Reference data

### GET `/reference-data`

Returns departments, systems, security roles, roles, priorities, and urgency values.

```json
{
  "data": {
    "departments": [],
    "systems": [],
    "securityRoles": [],
    "notificationPriorities": ["LOW", "NORMAL", "HIGH", "CRITICAL"],
    "accessUrgencies": ["NORMAL", "URGENT", "CRITICAL"],
    "accessDurations": ["TEMPORARY", "PERMANENT"]
  }
}
```

## Notifications

### GET `/notifications`

Query parameters:

| Parameter | Type | Notes |
|---|---|---|
| `page` | number | default 1 |
| `pageSize` | number | default 20 |
| `status` | string | Optional |
| `priority` | string | Optional |
| `unreadOnly` | boolean | Optional |
| `search` | string | Search title/body |

Response item:

```json
{
  "id": "uuid",
  "titleEn": "Security access request process is now available",
  "titleAr": "أصبحت خدمة طلب الصلاحيات الأمنية متاحة",
  "bodyEn": "You can now request access directly from ExpoApp.",
  "bodyAr": "يمكنك الآن طلب الصلاحيات مباشرة من تطبيق إكسبو.",
  "priority": "HIGH",
  "status": "PUBLISHED",
  "audienceType": "ALL",
  "readAt": null,
  "createdAt": "2026-07-09T12:00:00.000Z"
}
```

### POST `/notifications`

Roles: `SYSTEM_ADMIN`, optionally `SECURITY_ADMIN`.

```json
{
  "titleEn": "Operations briefing",
  "titleAr": "إحاطة العمليات",
  "bodyEn": "All operations staff must attend the 9 AM briefing.",
  "bodyAr": "على جميع موظفي العمليات حضور الإحاطة الساعة 9 صباحًا.",
  "priority": "HIGH",
  "audienceType": "DEPARTMENT",
  "audienceFilter": {
    "departmentCodes": ["OPS"]
  },
  "publishNow": true,
  "publishAt": null,
  "expiresAt": "2026-08-01T00:00:00.000Z"
}
```

Response:

```json
{
  "data": {
    "id": "uuid",
    "status": "PUBLISHED",
    "recipientCount": 2
  }
}
```

Rules:

- `titleEn` required, max 120.
- `bodyEn` required, max 2000.
- Arabic fields optional but recommended.
- `audienceType=ALL` requires `audienceFilter: {"all": true}`.
- `audienceType=DEPARTMENT` requires `departmentCodes`.
- `audienceType=ROLE` requires `roles`.
- `audienceType=USERS` requires `userIds`.

## Access requests

### POST `/access-requests`

```json
{
  "systemId": "uuid",
  "securityRoleId": "uuid",
  "businessJustification": "I need temporary inquiry access to validate vendor invoice status for the operations finance team.",
  "accessDuration": "TEMPORARY",
  "startDate": "2026-07-10T00:00:00.000Z",
  "endDate": "2026-08-10T00:00:00.000Z",
  "urgency": "NORMAL"
}
```

Response:

```json
{
  "data": {
    "id": "uuid",
    "requestNumber": "AR-2026-000007",
    "status": "MANAGER_PENDING",
    "currentStage": "MANAGER",
    "nextApprover": {
      "id": "uuid",
      "fullNameEn": "Faisal Otaibi"
    }
  }
}
```

Validation:

- `businessJustification` min 20 chars, max 1000.
- `securityRoleId` must be active.
- Temporary access requires `startDate` and `endDate`.
- `endDate` must be after `startDate`.
- Requester must be active.
- If requester has no manager and manager approval is required, return business error `MANAGER_NOT_FOUND`.

## Approvals

### POST `/approvals/:taskId/decision`

```json
{
  "decision": "APPROVED",
  "comment": "Approved for operational need."
}
```

or:

```json
{
  "decision": "REJECTED",
  "comment": "Business justification is insufficient."
}
```

Response:

```json
{
  "data": {
    "taskId": "uuid",
    "decision": "APPROVED",
    "request": {
      "id": "uuid",
      "requestNumber": "AR-2026-000007",
      "status": "SECURITY_PENDING",
      "currentStage": "SECURITY"
    }
  }
}
```

Rules:

- Only task assignee can decide, unless system admin override is explicitly enabled.
- Comment required for rejection.
- Pending manager approval -> approved creates security task if required.
- Pending manager approval -> rejected sets request `MANAGER_REJECTED`.
- Pending security approval -> approved sets request `PROVISIONING` then `COMPLETED` in mock mode.
- Pending security approval -> rejected sets request `SECURITY_REJECTED`.

## Audit

### GET `/audit-logs`

Roles: `SECURITY_ADMIN`, `SYSTEM_ADMIN`.

Query parameters:

| Parameter | Type |
|---|---|
| `page` | number |
| `pageSize` | number |
| `actorId` | uuid |
| `action` | string |
| `entityType` | string |
| `from` | ISO datetime |
| `to` | ISO datetime |

Response item:

```json
{
  "id": "uuid",
  "actorEmail": "admin@expo.sa",
  "action": "NOTIFICATION_PUBLISHED",
  "entityType": "Notification",
  "entityId": "uuid",
  "metadata": {
    "recipientCount": 120
  },
  "createdAt": "2026-07-09T12:00:00.000Z"
}
```

## Health

### GET `/health`

```json
{
  "data": {
    "status": "ok",
    "database": "ok",
    "redis": "ok",
    "fusionMode": "mock"
  }
}
```
