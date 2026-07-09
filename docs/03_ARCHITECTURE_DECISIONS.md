# Architecture Decisions

## ADR-001: Use Flutter for iOS and Android

### Decision

Use Flutter for the mobile application.

### Reason

Flutter provides one codebase for iOS and Android, high-performance UI, strong Material 3 support, and predictable output. It is suitable for building a polished app quickly while retaining future flexibility.

### Consequences

- One team can build both mobile platforms.
- Some native configuration is still required for production push notifications and store deployment.
- The same app can run on web for admin demo/testing, but mobile remains the primary target.

## ADR-002: Use NestJS for backend API

### Decision

Use NestJS with TypeScript.

### Reason

NestJS provides structure, decorators, validation, Swagger, modular architecture, dependency injection, and strong support for enterprise APIs.

### Consequences

- Codebase remains clean and scalable.
- Cursor can generate modules/controllers/services consistently.
- Backend structure supports adapter pattern for Oracle Fusion.

## ADR-003: Use PostgreSQL as operational database

### Decision

Use PostgreSQL for the app's operational data.

### Reason

The app needs its own fast operational store for notifications, request workflow, audit logs, and cached/reference data. Oracle Fusion remains the system of record for ERP transactions, but the app needs low-latency operational reads.

### Consequences

- The app can run independently in mock mode.
- Phase 2 integration can sync Oracle reference data into PostgreSQL.
- Workflow state is visible and auditable.

## ADR-004: Use Prisma ORM

### Decision

Use Prisma for database schema and data access.

### Reason

Prisma speeds up development, creates type-safe database access, supports migrations, and is easy for AI coding tools to reason about.

### Consequences

- Database schema is centralized in `schema.prisma`.
- Seed data can be implemented as TypeScript.
- Complex SQL can still be added later if needed.

## ADR-005: Use adapter pattern for Oracle Fusion

### Decision

All Oracle Fusion interactions must go through `FusionAdapter`.

### Reason

The first build must work without Oracle access while still being ready for real integration.

### Required interface

```ts
export interface FusionAdapter {
  getEmployeeProfile(userExternalRef: string): Promise<FusionEmployeeProfile>;
  listAvailableSecurityRoles(input: RoleCatalogQuery): Promise<FusionSecurityRole[]>;
  validateAccessRequest(input: ValidateFusionAccessRequestInput): Promise<ValidationResult>;
  submitAccessProvisioning(input: SubmitFusionProvisioningInput): Promise<FusionProvisioningResult>;
  getProvisioningStatus(externalRequestId: string): Promise<FusionProvisioningStatus>;
}
```

### Consequences

- The Flutter app is never coupled to Oracle details.
- The backend can run in `mock` or `fusion` mode.
- Real integration can be added later without rewriting workflow logic.

## ADR-006: Use role-based app shell

### Decision

After login, users see navigation and actions based on their role.

### Reason

Employees, managers, security admins, and system admins have different workflows. Role-based navigation avoids clutter and prevents unauthorized operations.

### Consequences

- Routes must have guards.
- Backend must enforce RBAC, not just UI hiding.
- Every admin endpoint checks authorization.

## ADR-007: Store notifications and workflow in app DB

### Decision

Notifications and access workflow state are stored in ExpoApp PostgreSQL.

### Reason

These are operational app records. Oracle Fusion may be integrated for identity/security roles, but this application must remain fast and auditable.

### Consequences

- Read operations are fast.
- Audit data is independent from Oracle.
- Integration with Oracle can be asynchronous.

## ADR-008: Use real mock API, not screen-level mock data

### Decision

Fake/mock data must live in backend seed data and mock adapter services.

### Reason

This keeps Phase 1 serious and avoids throwaway screens.

### Consequences

- The front end already exercises real HTTP, auth, validation, errors, and state changes.
- Phase 2 integration has less rework.
