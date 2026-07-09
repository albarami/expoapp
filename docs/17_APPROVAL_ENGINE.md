# Approval Engine

## Purpose

The approval engine controls manager and security decisions for access requests.

## Approval task lifecycle

```text
PENDING -> APPROVED
PENDING -> REJECTED
PENDING -> RETURNED (future)
```

Only pending tasks can be decided.

## Approval stages

| Stage | Assignee |
|---|---|
| `MANAGER` | Requester's direct manager |
| `SECURITY` | Security admin selected by policy; seed uses Reem |

## Manager approval

### Who can approve

The approval task assignee must be the logged-in user, or a system admin if override is explicitly allowed in config.

### Approve outcome

If the requested role requires security approval:

- Mark manager task `APPROVED`.
- Set request status `SECURITY_PENDING`.
- Set current stage `SECURITY`.
- Create security approval task.
- Add timeline event.
- Write audit log.

If no security approval required:

- Mark manager task `APPROVED`.
- Set request status `PROVISIONING`.
- Call fusion adapter/provisioning.
- Complete in mock mode.
- Add timeline events.
- Write audit logs.

### Reject outcome

- Mark manager task `REJECTED`.
- Set request status `MANAGER_REJECTED`.
- Set current stage `COMPLETE`.
- Add timeline event with comment.
- Write audit log.

## Security approval

### Who can approve

The approval task assignee must be the logged-in security admin. In seed data this is `reem.security@expo.sa`.

### Approve outcome

- Mark security task `APPROVED`.
- Set request status `PROVISIONING`.
- Set current stage `PROVISIONING`.
- Add provisioning started event.
- Call `FusionAdapter.submitAccessProvisioning`.
- In mock mode, set request status `COMPLETED`.
- Set current stage `COMPLETE`.
- Set `completedAt`.
- Add completed event.
- Write audit logs.

### Reject outcome

- Mark security task `REJECTED`.
- Set request status `SECURITY_REJECTED`.
- Set current stage `COMPLETE`.
- Add timeline event with comment.
- Write audit log.

## Decision DTO

```ts
export class DecideApprovalDto {
  @IsEnum(ApprovalDecision)
  decision: 'APPROVED' | 'REJECTED';

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  comment?: string;
}
```

Validation:

- Reject requires comment.
- Approve comment optional.
- `RETURNED` is future and should not be enabled in Phase 1 unless implemented fully.

## List approvals endpoint behavior

`GET /approvals?status=PENDING`

For manager:

- Return tasks assigned to current manager.

For security admin:

- Return security tasks assigned to current user.

For system admin:

- Return all tasks if `readAll` behavior is implemented.

## Approval queue screen

List card fields:

- Request number
- Requester name
- System
- Role
- Risk level
- Urgency
- Submitted date
- Current status
- CTA: Review

## Approval detail screen

Must show:

- Requester profile summary
- System and role requested
- Business justification
- Duration/date range
- Risk level
- Timeline
- Approve button
- Reject button
- Comment field/bottom sheet

## Decision confirmation

Approve:

```text
Are you sure you want to approve this access request?
```

Reject:

```text
Please provide a rejection reason.
```

Arabic equivalents must be present.

## Audit requirements

Approval decisions must write:

- task id
- request id
- previous request status
- new request status
- decision
- comment if provided
- actor id/email

## Transaction requirement

Approval decision must be transactional. If creating the next task fails, the previous task must not be marked approved.

## Edge cases

| Case | Expected behavior |
|---|---|
| Task already decided | Return `APPROVAL_TASK_NOT_PENDING` |
| Wrong user decides task | Return 403 / `NOT_TASK_ASSIGNEE` |
| Request deleted/missing | Return 404 |
| Security approval without manager approval | Return business error unless workflow allows |
| Fusion adapter fails | Request becomes `FAILED` or remains `PROVISIONING` based on mode; audit error |
