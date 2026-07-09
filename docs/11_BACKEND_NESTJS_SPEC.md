# Backend NestJS Specification

## Backend goal

Build a clean NestJS API that powers the Flutter app and can later integrate with Oracle Fusion.

## Required packages

Minimum packages:

```bash
npm install @nestjs/config @nestjs/jwt @nestjs/passport passport passport-jwt bcrypt class-validator class-transformer @nestjs/swagger swagger-ui-express
npm install @prisma/client
npm install -D prisma ts-node jest @types/bcrypt
```

Optional:

```bash
npm install ioredis helmet compression
```

## Bootstrap requirements

`main.ts` must:

- Load config.
- Enable CORS from env.
- Set global prefix `/api/v1`.
- Enable validation pipe with whitelist/transform.
- Enable Swagger at `/docs`.
- Enable structured error responses.
- Use request trace ID middleware/interceptor.
- Use helmet if installed.

## Modules

### AppModule

Imports:

- ConfigModule
- PrismaModule
- AuthModule
- UsersModule
- DepartmentsModule
- ReferenceDataModule
- DashboardModule
- NotificationsModule
- AccessRequestsModule
- ApprovalsModule
- AuditModule
- FusionModule
- HealthModule

### PrismaModule

Expose `PrismaService`.

Requirements:

- Connect on module init.
- Disconnect on module destroy.
- Log errors in development.
- Do not expose raw Prisma client directly outside services except through injected service.

### AuthModule

Responsibilities:

- Validate login credentials.
- Issue JWT token.
- Return current user.
- Provide JWT guard.
- Provide roles guard.
- Provide `@CurrentUser()` decorator.
- Audit login events.

DTOs:

```ts
LoginDto {
  email: string;
  password: string;
}
```

### NotificationsModule

Responsibilities:

- Create notification.
- Resolve audience.
- Generate recipient records.
- List notifications by current user.
- Mark as read.
- Show stats.
- Cancel notification.
- Audit create/publish/read/cancel.

Core service methods:

```ts
createNotification(actor, dto)
resolveAudience(audienceType, audienceFilter)
listForUser(user, query)
markAsRead(user, notificationId)
getStats(actor, notificationId)
cancel(actor, notificationId)
```

### AccessRequestsModule

Responsibilities:

- Submit access request.
- Validate request data.
- Determine manager/security approval requirements.
- Create request number.
- Generate initial approval task.
- Return role-scoped lists.
- Return request details/timeline.
- Cancel request.
- Audit submit/cancel.

Core service methods:

```ts
createRequest(requester, dto)
listRequests(currentUser, query)
getRequest(currentUser, id)
cancelRequest(currentUser, id)
createRequestEvent(...)
```

### ApprovalsModule

Responsibilities:

- List assigned tasks.
- Approve/reject manager tasks.
- Approve/reject security tasks.
- Advance workflow.
- Call FusionAdapter in mock/provisioning step.
- Audit decisions.

Core service methods:

```ts
listTasks(currentUser, query)
decide(currentUser, taskId, dto)
approveManagerTask(...)
rejectManagerTask(...)
approveSecurityTask(...)
rejectSecurityTask(...)
```

### AuditModule

Responsibilities:

- Write audit entries.
- Query audit entries for admins.
- Provide helper used by all modules.

Service method:

```ts
record(input: {
  actorId?: string;
  actorEmail?: string;
  action: string;
  entityType: string;
  entityId?: string;
  metadata?: Record<string, unknown>;
  ipAddress?: string;
  userAgent?: string;
})
```

### FusionModule

Responsibilities:

- Select adapter based on `FUSION_MODE`.
- Provide `FusionAdapter` token.
- Implement mock adapter.
- Keep real adapter scaffold.

Provider selection:

```ts
{
  provide: FUSION_ADAPTER,
  useClass: process.env.FUSION_MODE === 'fusion'
    ? OracleFusionAdapter
    : MockFusionAdapter
}
```

## Guards and decorators

Required:

```ts
@CurrentUser()
@Roles(UserRole.SYSTEM_ADMIN)
JwtAuthGuard
RolesGuard
```

Roles decorator:

```ts
export const Roles = (...roles: UserRole[]) => SetMetadata('roles', roles);
```

## Error handling

Create application error classes:

- `BusinessException`
- `NotFoundException` from Nest where appropriate
- `ForbiddenException`
- `ValidationException`

Business error codes:

| Code | Meaning |
|---|---|
| `MANAGER_NOT_FOUND` | Requester needs manager approval but has no manager |
| `ROLE_NOT_REQUESTABLE` | Security role inactive or invalid |
| `REQUEST_NOT_CANCELABLE` | Cannot cancel in current state |
| `APPROVAL_TASK_NOT_PENDING` | Task already decided |
| `NOT_TASK_ASSIGNEE` | User cannot decide task |
| `NOTIFICATION_NOT_FOUND` | Notification missing or not visible |
| `INVALID_AUDIENCE_FILTER` | Audience input invalid |

## Audit actions

Use consistent action constants:

```ts
AUTH_LOGIN
AUTH_LOGOUT
NOTIFICATION_CREATED
NOTIFICATION_PUBLISHED
NOTIFICATION_READ
NOTIFICATION_CANCELLED
ACCESS_REQUEST_SUBMITTED
ACCESS_REQUEST_CANCELLED
APPROVAL_MANAGER_APPROVED
APPROVAL_MANAGER_REJECTED
APPROVAL_SECURITY_APPROVED
APPROVAL_SECURITY_REJECTED
ACCESS_REQUEST_PROVISIONING_STARTED
ACCESS_REQUEST_COMPLETED
ACCESS_REQUEST_FAILED
```

## Request numbers

Generate sequential request numbers:

```text
AR-YYYY-000001
```

Implementation can use count per year for demo. Production should use database sequence or transactional counter.

## Transaction boundaries

Use database transactions for:

- Create notification + recipient rows + audit log.
- Submit access request + event + approval task + audit log.
- Approval decision + request state change + new task + event + audit log.
- Security approval + provisioning event + outbox/audit.

## Swagger

Every controller and DTO must include Swagger decorators.

Swagger path:

```text
http://localhost:3000/docs
```

## Backend tests

At minimum:

- Auth login success/failure.
- Employee cannot create notification.
- Admin can create notification.
- Employee can submit request.
- Manager can approve assigned task.
- Wrong manager cannot approve task.
- Security admin can approve security task.
- Audit log is written for submit/approve.
