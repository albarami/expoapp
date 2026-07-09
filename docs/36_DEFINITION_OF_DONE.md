# Definition of Done

## Whole project done

The project is considered done for Phase 1 only when all of this is true:

- Backend runs.
- Mobile app runs.
- Database persists data.
- Seed script creates demo users/data.
- Login works.
- Role-based navigation works.
- Notifications work end-to-end.
- Access requests work end-to-end.
- Approvals work end-to-end.
- Audit logs work.
- Arabic/English works.
- Oracle adapter boundary exists.
- README explains how to run everything.
- No core feature is static-only.

## Backend done

- [ ] NestJS compiles.
- [ ] Prisma migration works.
- [ ] Seed works idempotently.
- [ ] Swagger works.
- [ ] DTO validation exists.
- [ ] Guards exist.
- [ ] All API contracts implemented.
- [ ] Unit/integration tests for core workflows.
- [ ] No secrets committed.

## Mobile done

- [ ] Flutter analyze passes or has no serious issues.
- [ ] App runs on Android.
- [ ] App is iOS-ready.
- [ ] Login uses API.
- [ ] All lists use API.
- [ ] Forms submit to API.
- [ ] Loading/error/empty states exist.
- [ ] Arabic/RTL works.
- [ ] Role-based tabs/routes work.

## Notification module done

- [ ] Admin creates notification.
- [ ] Audience resolver works.
- [ ] Recipients generated.
- [ ] Employee sees notification.
- [ ] Read status updates.
- [ ] Stats work.
- [ ] Audit logs written.

## Access request module done

- [ ] Employee submits request.
- [ ] Request number generated.
- [ ] Manager task generated.
- [ ] Manager decision works.
- [ ] Security task generated.
- [ ] Security decision works.
- [ ] Mock provisioning completes.
- [ ] Timeline events written.
- [ ] Audit logs written.

## Oracle readiness done

- [ ] `FusionAdapter` interface exists.
- [ ] `MockFusionAdapter` works.
- [ ] `OracleFusionAdapter` scaffold exists.
- [ ] Services depend on adapter interface.
- [ ] Controllers do not reference Oracle implementation.
- [ ] Required Phase 2 Oracle details documented.
