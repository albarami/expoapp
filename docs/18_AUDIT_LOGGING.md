# Audit Logging

## Purpose

Audit logs provide traceability for security-sensitive and administrative actions.

## What must be audited

| Action | Entity type | Required metadata |
|---|---|---|
| Login | User | email, success/failure |
| Notification created | Notification | priority, audienceType |
| Notification published | Notification | recipientCount |
| Notification read | Notification | userId |
| Notification cancelled | Notification | reason if provided |
| Access request submitted | AccessRequest | requestNumber, system, role |
| Access request cancelled | AccessRequest | requestNumber |
| Manager approved | ApprovalTask | requestNumber, comment |
| Manager rejected | ApprovalTask | requestNumber, comment |
| Security approved | ApprovalTask | requestNumber, comment |
| Security rejected | ApprovalTask | requestNumber, comment |
| Provisioning started | AccessRequest | fusionMode |
| Provisioning completed | AccessRequest | externalFusionRequestId |
| Provisioning failed | AccessRequest | error |

## Audit service interface

```ts
export interface AuditInput {
  actorId?: string;
  actorEmail?: string;
  action: string;
  entityType: string;
  entityId?: string;
  metadata?: Record<string, unknown>;
  ipAddress?: string;
  userAgent?: string;
}

@Injectable()
export class AuditService {
  async record(input: AuditInput): Promise<void> {}
}
```

## Request metadata

Create middleware/interceptor to capture:

- trace ID
- IP address
- user agent
- current user if authenticated

## Audit query filters

Endpoint:

```text
GET /audit-logs
```

Filters:

- actorId
- actorEmail
- action
- entityType
- entityId
- from
- to
- page
- pageSize

## Audit UI

Authorized roles:

- Security Admin
- System Admin

Columns:

- Date/time
- Actor
- Action
- Entity
- Summary
- View metadata button

Detail modal:

- Full metadata JSON
- Trace ID if available
- IP address
- User agent
- Entity ID

## Security

- Employees cannot view audit logs.
- Managers cannot view audit logs by default.
- Audit logs cannot be edited through API.
- Audit logs cannot be deleted in Phase 1.
- Do not log passwords, tokens, or secrets.
- Mask sensitive metadata if needed.

## Example audit log

```json
{
  "actorEmail": "faisal.otaibi@expo.sa",
  "action": "APPROVAL_MANAGER_APPROVED",
  "entityType": "AccessRequest",
  "entityId": "uuid",
  "metadata": {
    "requestNumber": "AR-2026-000001",
    "previousStatus": "MANAGER_PENDING",
    "newStatus": "SECURITY_PENDING",
    "comment": "Approved for operations work."
  }
}
```

## Audit action constants

Create constants rather than scattered strings.

```ts
export const AuditActions = {
  AuthLogin: 'AUTH_LOGIN',
  NotificationCreated: 'NOTIFICATION_CREATED',
  NotificationPublished: 'NOTIFICATION_PUBLISHED',
  NotificationRead: 'NOTIFICATION_READ',
  AccessRequestSubmitted: 'ACCESS_REQUEST_SUBMITTED',
  ApprovalManagerApproved: 'APPROVAL_MANAGER_APPROVED',
  ApprovalManagerRejected: 'APPROVAL_MANAGER_REJECTED',
  ApprovalSecurityApproved: 'APPROVAL_SECURITY_APPROVED',
  ApprovalSecurityRejected: 'APPROVAL_SECURITY_REJECTED',
  AccessRequestCompleted: 'ACCESS_REQUEST_COMPLETED',
};
```
