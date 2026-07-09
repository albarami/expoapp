# Architecture Decisions — ExpoApp

**Generated:** 2026-07-09  
**Based on:** `/docs/03_ARCHITECTURE_DECISIONS.md` and full `/docs` pack  
**Status:** Binding for Phase 1 implementation

---

## ADR-C001: Monorepo layout

**Decision:** Single repository with `apps/api` (NestJS) and `apps/mobile` (Flutter), plus root `docker-compose.yml`, `.env.example`, `README.md`, `docs/`.

**Reason:** Matches `04_REPOSITORY_STRUCTURE.md` and master prompt. Shared CI and docs.

**Consequences:** No Expo React Native app. No separate admin SPA — admin is Flutter (incl. Web).

---

## Backend architecture

```text
HTTP -> NestJS (global prefix api/v1)
  -> Guards (JWT, Roles)
  -> Controllers (thin)
  -> Services (business logic + transactions)
  -> PrismaService -> PostgreSQL
  -> FusionAdapter (mock | oracle)
  -> AuditService (cross-cutting)
```

**Modules (required):** Config, Prisma, Auth, Users, Departments, ReferenceData, Dashboard, Notifications, AccessRequests, Approvals, Audit, Fusion, Health.

**Patterns:**
- Dependency injection via Nest modules
- DTOs with `class-validator` / `class-transformer`
- Global validation pipe (whitelist + transform)
- Global exception filter → stable error envelope
- Trace ID middleware/interceptor on every response `meta`
- Swagger decorators on all controllers/DTOs
- Transactions for multi-write workflows

---

## Flutter architecture

```text
UI (presentation) -> Riverpod providers -> Repositories -> Dio ApiClient -> NestJS
```

Feature-first folders under `lib/features/<feature>/{data,domain,presentation}`.

Shared: `core/` (api, auth, config, errors), `shared/widgets`, `app/` (router, theme, localization), `l10n/`.

**Screens stay thin.** Business logic in repositories/providers/domain.

---

## Folder structure

Exact trees from `04_REPOSITORY_STRUCTURE.md` — implement as specified. Naming:

| Layer | Convention |
|---|---|
| Backend files | kebab-case.ts |
| Backend classes | PascalCase |
| Flutter files | snake_case.dart |
| Flutter providers | xxxProvider |
| API routes | kebab-case plural |

---

## State management

**Riverpod** (`flutter_riverpod`).

- `AsyncValue` for async screens
- Session via `StateNotifier` / equivalent session controller
- Feature providers: dashboard, notifications, access requests, approvals, audit, reference data
- Query objects for list filters (immutable)
- Do not put all state in one global provider
- Do not call Dio from widgets

---

## API / service approach

- Central `ApiClient` (Dio): base URL, Bearer token, 401 → clear session → login, typed `ApiError`
- Feature repositories implement domain interfaces
- Response envelope unwrapping in client/repository layer
- Pagination helpers shared

Backend services own business rules; controllers only map HTTP ↔ DTOs.

---

## Authentication

Phase 1: email/password against seeded bcrypt hashes → JWT access + refresh (or demo refresh).

JWT claims: `sub`, `email`, `role` only.

Mobile: `flutter_secure_storage` for tokens; never store password.

Phase 2: SSO/OIDC — keep auth module swappable; do not hardcode demo-only assumptions into domain services beyond `ENABLE_DEMO_LOGIN`.

---

## Authorization / roles

- Backend: `JwtAuthGuard` + `RolesGuard` + `@Roles(...)` + `@CurrentUser()`
- Permission map derived from role (`14_AUTH_AND_RBAC.md`)
- Flutter: hide tabs/actions + GoRouter redirects; backend is authority
- Data scoping in services (own / assignee / admin)

---

## Validation

| Layer | Approach |
|---|---|
| Backend | class-validator DTOs; business exceptions with codes |
| Flutter | Form validators + disable submit until valid; map API error codes to l10n |

Key codes: `VALIDATION_ERROR`, `MANAGER_NOT_FOUND`, `ROLE_NOT_REQUESTABLE`, `DUPLICATE_ACTIVE_REQUEST`, `REQUEST_NOT_CANCELABLE`, `APPROVAL_TASK_NOT_PENDING`, `NOT_TASK_ASSIGNEE`, `INVALID_AUDIENCE_FILTER`, etc.

---

## Error handling

- Backend global filter → `{ error: { code, message, details }, meta }`
- Flutter: loading / empty / error+retry / unauthorized on every async screen
- Network offline message localized
- Trace ID shown in debug error details

---

## Audit logging

- `AuditService.record(...)` used by all modules
- Constants for action strings (no scattered literals)
- No update/delete audit APIs
- Never audit passwords/tokens/secrets
- Timeline events (`AccessRequestEvent`) are user-facing; audit logs are security/admin records — both written on workflow transitions

---

## Oracle Fusion adapter

```ts
FusionAdapter interface
  -> MockFusionAdapter (FUSION_MODE=mock)
  -> OracleFusionAdapter scaffold (FUSION_MODE=fusion; throws if config missing)
```

- Injected via `FUSION_ADAPTER` token
- Controllers never import Oracle adapter
- Provisioning in mock mode completes immediately with `MOCK-FUSION-AR-...` IDs
- Production path uses `IntegrationOutbox` (schema ready in Phase 1)

---

## Testing approach

| Layer | Focus |
|---|---|
| Backend unit | Auth, audience resolver, validation, approval transitions, mock adapter |
| Backend integration | Login, RBAC, notification E2E, request+approval E2E, audit writes |
| Flutter widget | Login validation, role dashboard smoke, form validation, key cards |
| Manual | Four demo scenarios in `28_TESTING_QA_ACCEPTANCE.md` |

CI must fail on lint/test/analyze/build errors. Never weaken tests to pass CI.

---

## Seed / mock-data approach

- Mock data = PostgreSQL seed + MockFusionAdapter — **not** Flutter static arrays
- Idempotent upserts in `seed.ts`
- Demo password `Password123!` documented in README only as demo credentials
- Seed covers departments, users, systems, roles, ≥6 notifications, ≥4 access requests, audit samples

---

## iOS / Android / Web assumptions

| Platform | Phase 1 expectation |
|---|---|
| Android | Primary local run target (emulator/device) |
| iOS | Code must be iOS-ready; simulator when available on host |
| Flutter Web | Admin/stakeholder demo (`flutter run -d chrome`); nav rail on wide layouts |
| Push | Mock only; device token endpoint exists |
| Store signing | Out of Phase 1; document as external blocker |

API base URL: Android emulator `10.0.2.2`, iOS simulator `localhost`, web `localhost`.

---

## Package manager decision (pending env verify)

**Intent:** Prefer **npm** for NestJS (`apps/api/package.json` scripts as in docs) unless an existing lockfile dictates otherwise. Repo currently has **no** `package.json` — next run will scaffold with npm and lock `package-lock.json`.

Flutter: official `flutter` / `dart` toolchain; `pubspec.yaml` + `pubspec.lock`.

---

## ADR-C012: Scheduled notification publishing (T-FIX-01)

**Decision:** Implement scheduled publishing in Phase 1 via an in-process interval publisher (`ScheduledNotificationsService` in `NotificationsModule`) instead of an external cron or `@nestjs/schedule` dependency.

**Doc basis:** Docs 15/19/20 all specify "publish now or schedule" in the Phase 1 admin create-notification workflow (`publishAt` required for schedule; doc 07/08 define `SCHEDULED` status + `publishAt` index). No doc defers scheduled *publishing* to Phase 2 — only push channels (FCM/APNs) are deferred. A `SCHEDULED` notification that never publishes would violate doc 15's "recipients generated on publish" behavior.

**Mechanics:**
- Interval loop (default 30s, `NOTIFICATION_SCHEDULER_INTERVAL_MS` env override, min 1s) finds `SCHEDULED` rows with `publishAt <= now`.
- Per notification: resolve audience → transaction { `updateMany` status guard SCHEDULED→PUBLISHED (prevents double publish/cancel race), `createMany` recipients with `deliveredAt`, `skipDuplicates` } → audit `NOTIFICATION_PUBLISHED` with `metadata.scheduled=true`, actor = creator.
- Loop disabled under `NODE_ENV=test`; tests call `publishDueNotifications()` directly.
- Failures on one notification are logged and do not block others.

**Consequences:** Single-instance semantics are fine for Phase 1 demo; the status-guard makes multi-instance safe (first claim wins). Phase 2 may move to BullMQ/cron if horizontal scale requires it.

---

## ADR-C013: SYSTEM_ADMIN may submit own access requests (T-FIX-01)

**Decision:** Remove the `assertCanCreate` block that returned 403 for `SYSTEM_ADMIN` on `POST /access-requests`. All roles may submit their own access requests.

**Doc basis (conflict resolved):** Doc 06 permission matrix — "Submit own access request: Yes" for Employee, Manager, Security Admin **and** System Admin; doc 06 RBAC table and doc 10 both list `POST /access-requests` as "authenticated" with no role carve-out. The only contrary signal is the System Admin tab bar (doc 06 UI routing) having no Requests tab — that is a navigation-emphasis choice, not a permission rule. The permission matrix + endpoint tables are authoritative for backend RBAC (doc 06: "Backend enforcement is mandatory").

**Consequences:** Sysadmin submissions follow the same workflow rules (manager required → `MANAGER_NOT_FOUND` if none; security-only roles route to security queue). Flutter sysadmin shell keeps its documented tabs (no Requests tab) — UI unchanged, backend now doc-compliant. E2E coverage added in `access-requests.e2e-spec.ts`. Conflict recorded in `07_BLOCKERS.md`.

---

## ADR-C014: `GET /users` scope (T-FIX-01)

**Decision:** `GET /users` (admin audience lookup) allows `SYSTEM_ADMIN` and `SECURITY_ADMIN`, returns **active users only**, supports `search`/`role`/`departmentCode` filters and standard pagination.

**Doc basis:** Doc 10 endpoint table ("User lookup for admin audience — System Admin") + doc 19 ("user picker can be simple list from `/users`", searchable, empty state "No matching users found"). SECURITY_ADMIN is included because this repo opted into the doc-06 "Optional" SECURITY_ADMIN notification-create capability (see conflicts table below); a role that can compose USERS-audience notifications must be able to look up users. Active-only matches doc 15 recipient resolution (inactive users excluded).

---

## Conflicts / clarifications recorded

| Topic | Decision |
|---|---|
| Repo name "expoapp" vs Expo RN | **Flutter**, not Expo React Native (`01_MASTER` hard rule) |
| Admin separate app? | Same Flutter app + Web |
| SECURITY_ADMIN create notifications | Optional per matrix; Phase 1 implement SYSTEM_ADMIN required; SECURITY_ADMIN optional flag can default off unless docs say Optional = allow — **Decision:** allow SECURITY_ADMIN create/publish/stats to match API contract optional language, but primary persona is SYSTEM_ADMIN |
| SYSTEM_ADMIN submit access requests | Doc 06 matrix says **Yes** for all roles; earlier code blocked SYSTEM_ADMIN. **Resolved:** allow (ADR-C013) |
| Scheduled notifications | Phase 1 behavior per docs 15/19/20 → in-process publisher (ADR-C012) |
| RETURNED approval | Future; not Phase 1 |
| Full offline | Not required; graceful network errors only |
