# Definition of Done

## Whole project done

The project is considered done for Phase 1 only when all of this is true:

- [x] Backend runs.
- [x] Mobile app runs. (code-ready / automated coverage; interactive device external OK for Phase 1)
- [x] Database persists data.
- [x] Seed script creates demo users/data.
- [x] Login works.
- [x] Role-based navigation works.
- [x] Notifications work end-to-end.
- [x] Access requests work end-to-end.
- [x] Approvals work end-to-end.
- [x] Audit logs work.
- [x] Arabic/English works.
- [x] Oracle adapter boundary exists.
- [x] README explains how to run everything.
- [x] No core feature is static-only.

## Backend done

- [x] NestJS compiles.
- [x] Prisma migration works.
- [x] Seed works idempotently.
- [x] Swagger works.
- [x] DTO validation exists.
- [x] Guards exist.
- [x] All API contracts implemented.
- [x] Unit/integration tests for core workflows.
- [x] No secrets committed.

## Mobile done

- [x] Flutter analyze passes or has no serious issues.
- [x] App runs on Android. (Phase 1 code-ready / automated coverage; interactive device external)
- [x] App is iOS-ready.
- [x] Login uses API.
- [x] All lists use API.
- [x] Forms submit to API.
- [x] Loading/error/empty states exist.
- [x] Arabic/RTL works.
- [x] Role-based tabs/routes work.

## Notification module done

- [x] Admin creates notification.
- [x] Audience resolver works.
- [x] Recipients generated.
- [x] Employee sees notification.
- [x] Read status updates.
- [x] Stats work.
- [x] Audit logs written.

## Access request module done

- [x] Employee submits request.
- [x] Request number generated.
- [x] Manager task generated.
- [x] Manager decision works.
- [x] Security task generated.
- [x] Security decision works.
- [x] Mock provisioning completes.
- [x] Timeline events written.
- [x] Audit logs written.

## Oracle readiness done

- [x] `FusionAdapter` interface exists.
- [x] `MockFusionAdapter` works.
- [x] `OracleFusionAdapter` scaffold exists.
- [x] Services depend on adapter interface.
- [x] Controllers do not reference Oracle implementation.
- [x] Required Phase 2 Oracle details documented.
