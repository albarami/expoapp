# Data Model

## Entity overview

```text
User
  belongs to Department
  may have manager User
  has many NotificationRecipient
  has many AccessRequest as requester
  has many ApprovalTask as assignee
  has many AuditLog as actor

Department
  has many User

AppSystem
  represents target system/application for access requests

SecurityRoleCatalog
  represents requestable access role

Notification
  has many NotificationRecipient
  created by User

NotificationRecipient
  links Notification to User with delivery/read status

AccessRequest
  requested by User
  targets AppSystem and SecurityRoleCatalog
  has many ApprovalTask
  has many AccessRequestEvent

ApprovalTask
  belongs to AccessRequest
  assigned to User
  stores stage, decision, comment

AuditLog
  records action, actor, entity, metadata

IntegrationOutbox
  future-ready queue for Oracle Fusion operations
```

## Core entities

### User

Represents an authenticated application user.

| Field | Type | Required | Notes |
|---|---|---:|---|
| `id` | UUID | Yes | Internal ID |
| `externalRef` | String | Yes | Future Oracle/SSO reference |
| `employeeNumber` | String | Yes | Human-readable employee number |
| `fullNameEn` | String | Yes | English display name |
| `fullNameAr` | String | Optional | Arabic display name |
| `email` | String | Yes | Unique |
| `phone` | String | Optional | Mobile phone |
| `role` | Enum | Yes | Application role |
| `departmentId` | UUID | Optional | Department |
| `managerId` | UUID | Optional | Direct manager |
| `isActive` | Boolean | Yes | Default true |
| `passwordHash` | String | Optional | Phase 1 demo auth |
| `createdAt` | DateTime | Yes | |
| `updatedAt` | DateTime | Yes | |

### Department

Represents organizational grouping.

| Field | Type | Required |
|---|---|---:|
| `id` | UUID | Yes |
| `code` | String | Yes |
| `nameEn` | String | Yes |
| `nameAr` | String | Optional |
| `createdAt` | DateTime | Yes |
| `updatedAt` | DateTime | Yes |

### AppSystem

A system/application for which access can be requested.

Examples:

- Oracle Fusion ERP
- Oracle Fusion HCM
- Security Operations Portal
- Event Operations Dashboard
- Vendor Management System

| Field | Type | Required |
|---|---|---:|
| `id` | UUID | Yes |
| `code` | String | Yes |
| `nameEn` | String | Yes |
| `nameAr` | String | Optional |
| `description` | String | Optional |
| `isActive` | Boolean | Yes |

### SecurityRoleCatalog

Represents a role/access item that users can request.

| Field | Type | Required | Notes |
|---|---|---:|---|
| `id` | UUID | Yes | |
| `systemId` | UUID | Yes | Links to AppSystem |
| `code` | String | Yes | Example: `FUSION_AP_INQUIRY` |
| `nameEn` | String | Yes | |
| `nameAr` | String | Optional | |
| `riskLevel` | Enum | Yes | LOW, MEDIUM, HIGH, CRITICAL |
| `requiresManagerApproval` | Boolean | Yes | Usually true |
| `requiresSecurityApproval` | Boolean | Yes | Usually true |
| `isActive` | Boolean | Yes | |

### Notification

Represents a one-to-many message.

| Field | Type | Required | Notes |
|---|---|---:|---|
| `id` | UUID | Yes | |
| `titleEn` | String | Yes | |
| `titleAr` | String | Optional | |
| `bodyEn` | String | Yes | |
| `bodyAr` | String | Optional | |
| `priority` | Enum | Yes | LOW, NORMAL, HIGH, CRITICAL |
| `status` | Enum | Yes | DRAFT, SCHEDULED, PUBLISHED, CANCELLED, EXPIRED |
| `audienceType` | Enum | Yes | ALL, DEPARTMENT, ROLE, USERS |
| `audienceFilter` | JSON | Yes | Holds selected departments/roles/users |
| `publishAt` | DateTime | Optional | Scheduled publish time |
| `expiresAt` | DateTime | Optional | |
| `createdById` | UUID | Yes | |
| `createdAt` | DateTime | Yes | |
| `updatedAt` | DateTime | Yes | |

### NotificationRecipient

Per-user delivery/read state.

| Field | Type | Required |
|---|---|---:|
| `id` | UUID | Yes |
| `notificationId` | UUID | Yes |
| `userId` | UUID | Yes |
| `deliveredAt` | DateTime | Optional |
| `readAt` | DateTime | Optional |
| `createdAt` | DateTime | Yes |

### AccessRequest

Represents a request for security/system access.

| Field | Type | Required | Notes |
|---|---|---:|---|
| `id` | UUID | Yes | |
| `requestNumber` | String | Yes | Example: `AR-2026-000001` |
| `requesterId` | UUID | Yes | |
| `systemId` | UUID | Yes | |
| `securityRoleId` | UUID | Yes | |
| `businessJustification` | String | Yes | Minimum length 20 |
| `accessDuration` | Enum | Yes | TEMPORARY, PERMANENT |
| `startDate` | DateTime | Optional | Required for temporary/permanent as configured |
| `endDate` | DateTime | Optional | Required for temporary |
| `urgency` | Enum | Yes | NORMAL, URGENT, CRITICAL |
| `status` | Enum | Yes | Workflow state |
| `currentStage` | Enum | Yes | REQUESTER, MANAGER, SECURITY, PROVISIONING, COMPLETE |
| `submittedAt` | DateTime | Optional | |
| `completedAt` | DateTime | Optional | |
| `externalFusionRequestId` | String | Optional | Future integration |
| `createdAt` | DateTime | Yes | |
| `updatedAt` | DateTime | Yes | |

### ApprovalTask

A task assigned to approver.

| Field | Type | Required |
|---|---|---:|
| `id` | UUID | Yes |
| `accessRequestId` | UUID | Yes |
| `stage` | Enum | Yes |
| `assigneeId` | UUID | Yes |
| `decision` | Enum | Yes |
| `comment` | String | Optional |
| `decidedAt` | DateTime | Optional |
| `createdAt` | DateTime | Yes |

### AccessRequestEvent

Timeline event for request.

| Field | Type | Required |
|---|---|---:|
| `id` | UUID | Yes |
| `accessRequestId` | UUID | Yes |
| `actorId` | UUID | Optional |
| `eventType` | String | Yes |
| `messageEn` | String | Yes |
| `messageAr` | String | Optional |
| `metadata` | JSON | Optional |
| `createdAt` | DateTime | Yes |

### AuditLog

System audit log.

| Field | Type | Required |
|---|---|---:|
| `id` | UUID | Yes |
| `actorId` | UUID | Optional |
| `actorEmail` | String | Optional |
| `action` | String | Yes |
| `entityType` | String | Yes |
| `entityId` | String | Optional |
| `ipAddress` | String | Optional |
| `userAgent` | String | Optional |
| `metadata` | JSON | Optional |
| `createdAt` | DateTime | Yes |

### IntegrationOutbox

Future-ready queue for Oracle Fusion asynchronous operations.

| Field | Type | Required |
|---|---|---:|
| `id` | UUID | Yes |
| `type` | String | Yes |
| `payload` | JSON | Yes |
| `status` | Enum | Yes |
| `attempts` | Int | Yes |
| `lastError` | String | Optional |
| `nextAttemptAt` | DateTime | Optional |
| `createdAt` | DateTime | Yes |
| `updatedAt` | DateTime | Yes |

## Design notes

- Use UUIDs for all internal IDs.
- Use stable human-friendly request numbers for access requests.
- Keep Oracle IDs in `externalRef` and `externalFusionRequestId`.
- Avoid deleting important records. Prefer `isActive`, `status`, or soft delete in future.
- Every workflow transition must write both event timeline and audit log.
