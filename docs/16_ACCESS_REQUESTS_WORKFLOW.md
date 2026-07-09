# Access Requests Workflow

## Purpose

Allow employees to request security/system access through a controlled, auditable workflow.

## Main workflow

```text
Employee submits request
  -> Manager approval
    -> Security admin approval
      -> Provisioning
        -> Completed
```

## Status model

| Status | Meaning |
|---|---|
| `DRAFT` | Created but not submitted; optional future use |
| `SUBMITTED` | Submitted and being routed |
| `MANAGER_PENDING` | Waiting for manager approval |
| `MANAGER_APPROVED` | Manager approved; transition state |
| `MANAGER_REJECTED` | Manager rejected |
| `SECURITY_PENDING` | Waiting for security admin |
| `SECURITY_APPROVED` | Security approved; transition state |
| `SECURITY_REJECTED` | Security rejected |
| `PROVISIONING` | System/Oracle provisioning in progress |
| `COMPLETED` | Access completed |
| `CANCELLED` | Requester cancelled |
| `FAILED` | Provisioning failed |

## Stage model

| Stage | Meaning |
|---|---|
| `REQUESTER` | With requester |
| `MANAGER` | With manager |
| `SECURITY` | With security admin |
| `PROVISIONING` | Awaiting integration/provisioning |
| `COMPLETE` | Done |

## Request submission rules

User must provide:

- Target system
- Target security role
- Business justification
- Access duration
- Start date
- End date if temporary
- Urgency

Backend must:

1. Validate role is active and requestable.
2. Validate dates.
3. Validate requester is active.
4. Find manager if manager approval required.
5. Create request number.
6. Create access request.
7. Create event timeline item.
8. Create manager approval task or security task depending role requirements.
9. Write audit log.
10. Return current status and next approver.

## Approval routing rules

### Role requires manager and security approval

Initial status:

```text
MANAGER_PENDING / MANAGER
```

After manager approves:

```text
SECURITY_PENDING / SECURITY
```

After security approves in mock mode:

```text
PROVISIONING / PROVISIONING
COMPLETED / COMPLETE
```

### Role requires manager only

Initial status:

```text
MANAGER_PENDING / MANAGER
```

After manager approves:

```text
PROVISIONING / PROVISIONING
COMPLETED / COMPLETE
```

### Role requires security only

Initial status:

```text
SECURITY_PENDING / SECURITY
```

After security approves:

```text
PROVISIONING / PROVISIONING
COMPLETED / COMPLETE
```

## Rejection rules

- Manager rejection sets `MANAGER_REJECTED`.
- Security rejection sets `SECURITY_REJECTED`.
- Rejection requires comment.
- Rejected requests cannot be approved later.
- User may submit a new request if needed.

## Cancellation rules

Requester can cancel only when:

- `MANAGER_PENDING`
- `SECURITY_PENDING`

Requester cannot cancel when:

- `PROVISIONING`
- `COMPLETED`
- `MANAGER_REJECTED`
- `SECURITY_REJECTED`
- `FAILED`

## Request detail timeline

Every access request detail screen must show timeline events such as:

```text
Request submitted by Noura Alharbi
Manager approval task assigned to Faisal Otaibi
Manager approved: Approved for operational need
Security approval task assigned to Reem Almutairi
Security approved: Access validated
Provisioning started
Access request completed
```

Arabic messages should exist where practical.

## Business validation

| Validation | Error code |
|---|---|
| Role inactive | `ROLE_NOT_REQUESTABLE` |
| Missing manager | `MANAGER_NOT_FOUND` |
| End date before start date | `INVALID_ACCESS_DATES` |
| Justification too short | `VALIDATION_ERROR` |
| Duplicate active request for same role | `DUPLICATE_ACTIVE_REQUEST` |
| User inactive | `USER_INACTIVE` |

## Duplicate active request rule

Prevent same requester from submitting another active request for the same system/security role if an existing request is in:

- `MANAGER_PENDING`
- `SECURITY_PENDING`
- `PROVISIONING`

For demo, block only pending/provisioning duplicates.

## Access request form fields

| Field | Type | Required | UI |
|---|---|---:|---|
| System | Dropdown | Yes | From reference data |
| Security role | Dropdown | Yes | Filter by selected system |
| Business justification | Text area | Yes | Min 20 |
| Duration | Segmented control | Yes | Temporary/Permanent |
| Start date | Date picker | Yes | |
| End date | Date picker | Required if temporary | |
| Urgency | Dropdown/chips | Yes | Normal/Urgent/Critical |

## Status display

Use localized labels:

| Status | English | Arabic |
|---|---|---|
| `MANAGER_PENDING` | Pending Manager | بانتظار المدير |
| `SECURITY_PENDING` | Pending Security | بانتظار الأمن |
| `COMPLETED` | Completed | مكتمل |
| `MANAGER_REJECTED` | Rejected by Manager | مرفوض من المدير |
| `SECURITY_REJECTED` | Rejected by Security | مرفوض من الأمن |
| `CANCELLED` | Cancelled | ملغي |
| `FAILED` | Failed | فشل |

## Mock provisioning behavior

In mock mode, after security approval:

1. Call `MockFusionAdapter.submitAccessProvisioning`.
2. Mark request as `COMPLETED`.
3. Store fake `externalFusionRequestId`, e.g. `MOCK-FUSION-AR-2026-000007`.
4. Write timeline event.
5. Write audit log.

## Future Oracle behavior

In real mode, after final approval:

1. Create integration outbox row.
2. Submit request to Fusion/OIC.
3. Mark request `PROVISIONING`.
4. Poll or receive callback.
5. Mark `COMPLETED` or `FAILED`.
