# Project Understanding — ExpoApp

**Generated:** 2026-07-09  
**Source of truth:** `/docs` (all files read)  
**Repository:** https://github.com/albarami/expoapp  
**Phase:** Phase 1 — complete runnable system with production-shaped mock data

---

## Product purpose

ExpoApp is a fast mobile/web experience layer for **Expo Saudi** on top of **Oracle Fusion**. Oracle Fusion remains the ERP and system of record. ExpoApp accelerates high-frequency operational workflows that Fusion does not optimize for mobile speed and simplicity:

1. One-to-many notifications (broadcast and targeted)
2. Security access request submission
3. Manager and security approval workflows
4. Role-based dashboards
5. Full audit tracking

**Positioning:** Experience layer and workflow accelerator — **not** an ERP replacement.

```text
Mobile App -> ExpoApp API -> PostgreSQL (+ Redis) -> FusionAdapter -> Oracle Fusion (Phase 2)
```

Phase 1 uses a real NestJS backend, PostgreSQL, seeded data, JWT auth, and `MockFusionAdapter`. No Oracle credentials required.

---

## Target users / personas

| Persona | Goals |
|---|---|
| **Employee** | Read announcements; submit access requests; track status |
| **Manager** | Approve/reject direct-report access requests |
| **Security Administrator** | Validate/complete security access; maintain audit trail |
| **System Administrator** | Create/publish notifications; view stats and audit logs |

---

## User roles

| Role code | Description |
|---|---|
| `EMPLOYEE` | Basic user |
| `MANAGER` | Employee with approval rights for direct reports |
| `SECURITY_ADMIN` | Security/access workflow owner |
| `SYSTEM_ADMIN` | App administration and notification owner |

Backend RBAC is mandatory; UI hiding alone is insufficient.

---

## Core workflows

### 1. Notifications
Admin creates → audience resolved → recipient rows → employee inbox → mark read → stats/audit.

Audience types: `ALL`, `DEPARTMENT`, `ROLE`, `USERS`.

### 2. Access request + approval
Employee submits → manager approval (if required) → security approval (if required) → mock provisioning → `COMPLETED`.

Status/stage models and routing rules are defined in `16_ACCESS_REQUESTS_WORKFLOW.md` and `17_APPROVAL_ENGINE.md`.

### 3. Audit
Every meaningful auth, notification, request, approval, and provisioning action writes an immutable audit log.

### 4. Demo acceptance path
Admin broadcast → employee read → employee request → manager approve → security approve → completed + audit trail (`32_ACCEPTANCE_CRITERIA_DEMO.md`).

---

## Required modules

| Module | Backend | Flutter |
|---|---|---|
| Auth + RBAC | JWT, guards, permissions | Login, session, route guards |
| Dashboard | Role-aware summary | Role-based home |
| Notifications | CRUD, audience, read, stats | List, detail, admin create, stats |
| Access requests | Submit, list, detail, cancel, timeline | My requests, form, detail |
| Approvals | Queue + decision engine | Queue + decision UI |
| Audit | Record + query | Viewer (admin/security) |
| Reference data | Departments, systems, roles | Cached for forms |
| Fusion adapter | Interface + mock + scaffold | Never calls Oracle |
| Localization | Bilingual stored fields | EN/AR ARB + RTL |
| Health / observability | `/health`, trace IDs | Error mapping + retry |

---

## Backend requirements

- **Stack:** Node.js, NestJS, TypeScript, Prisma, PostgreSQL, Redis (Docker Compose), JWT, Swagger, class-validator, Jest
- **Prefix:** `/api/v1`; Swagger at `/docs`
- **Persistence:** All business data in PostgreSQL; no in-memory business stores
- **Seed:** Idempotent `prisma/seed.ts` per `09_SEED_DATA.md` (password `Password123!`)
- **Envelope:** `{ data, meta }` / paginated / structured errors with stable codes
- **Transactions:** Notification publish, request submit, approval decisions
- **Fusion:** `FUSION_MODE=mock|fusion`; services depend on `FusionAdapter` only

---

## Flutter mobile requirements

- **Stack:** Flutter, Dart, Riverpod, GoRouter, Dio, flutter_secure_storage, intl/l10n, Material 3
- **Platforms:** iOS, Android (primary); Flutter Web for admin/stakeholder demo
- **Architecture:** Feature-first (`data` / `domain` / `presentation`)
- **Rules:** No hardcoded fake business arrays; all data from API; loading/empty/error/unauthorized states; thin screens

### Flutter UI skill (mandatory for UI work)

| Skill | Path | When |
|---|---|---|
| **ui-ux-pro-max** (primary Flutter UI) | `.cursor/skills/ui-ux-pro-max/SKILL.md` + `data/stacks/flutter.csv` | Every Flutter UI/UX task |
| frontend-design | `.cursor/skills/frontend-design/SKILL.md` | Landing/branded surfaces if needed |
| Rule | `.cursor/rules/use-available-skills.mdc` | Always check skills before UI work |

For every UI task, record: skill used, design decisions, screens affected, platform checks, doc alignment.

---

## Flutter Web / admin requirements

Admin lives in the **same** Flutter app. System Admin tabs: Home, Notifications, Create, Audit, Profile. Must run on Flutter Web (`flutter run -d chrome`) for demos. Employees must never see admin screens.

---

## Screen map

| Screen | Route | Roles |
|---|---|---|
| Splash/startup | (bootstrap) | All |
| Login | `/login` | Public |
| Dashboard | `/` | Authenticated (role widgets) |
| Notifications list | `/notifications` | Authenticated |
| Notification detail | `/notifications/:id` | Authenticated |
| Create notification | `/admin/notifications/create` | SYSTEM_ADMIN |
| My requests | `/requests` | Authenticated |
| New request | `/requests/new` | Authenticated |
| Request detail | `/requests/:id` | Authenticated (scoped) |
| Approvals | `/approvals` | MANAGER / SECURITY_ADMIN / optional SYSTEM_ADMIN |
| Audit | `/audit` | SECURITY_ADMIN / SYSTEM_ADMIN |
| Profile | `/profile` | Authenticated |
| Settings | `/settings` | Authenticated |

---

## Navigation map (role tab bars)

| Role | Tabs |
|---|---|
| Employee | Home, Notifications, Requests, Profile |
| Manager | Home, Notifications, Requests, Approvals, Profile |
| Security Admin | Home, Notifications, Security, Audit, Profile |
| System Admin | Home, Notifications, Create, Audit, Profile |

Mobile: bottom nav. Wider web: navigation rail/sidebar allowed.

---

## Data model (summary)

Entities: `User`, `Department`, `AppSystem`, `SecurityRoleCatalog`, `Notification`, `NotificationRecipient`, `AccessRequest`, `ApprovalTask`, `AccessRequestEvent`, `AuditLog`, `IntegrationOutbox`, `DeviceToken`.

Full Prisma schema: `08_DATABASE_SCHEMA_PRISMA.md`.

---

## Integrations

| Integration | Phase 1 | Phase 2 |
|---|---|---|
| Oracle Fusion | `MockFusionAdapter` | `OracleFusionAdapter` / OIC |
| Auth | Seeded JWT login | SSO/OIDC |
| Push | `PUSH_MODE=mock` + device token store | FCM/APNs |
| Redis | Docker Compose available | Caching / hot data |

Flutter never calls Oracle. Controllers never call Oracle adapters directly.

---

## Non-functional requirements

- Local/mock API p95 dashboard & lists &lt; 500 ms; submit/approve &lt; 1 s
- Cold launch to dashboard after saved login &lt; 2.5 s (target)
- Pagination default pageSize 20, max 100
- Graceful offline: network error + retry; preserve form input
- Observability: trace IDs, structured logs, `/health`

---

## Security requirements

- Server-side JWT + role/permission guards
- Bcrypt password hashes; never log passwords/tokens/secrets
- Secure token storage on device
- No secrets in git; `.env.example` only
- Audit immutability (no update/delete APIs in Phase 1)
- CORS from env; Helmet recommended
- Output scoping by role

---

## Permission requirements

See matrix in `06_PERSONAS_ROLES_PERMISSIONS.md`. Highlights:

- Create/publish notifications: `SYSTEM_ADMIN` (optional `SECURITY_ADMIN`)
- Approvals: assignee (manager/security) only
- Audit: `SECURITY_ADMIN`, `SYSTEM_ADMIN`
- Access requests: authenticated; lists scoped by role

---

## Go-live definition (Phase 1)

Per `01_MASTER_CURSOR_PROMPT.md` §16 and `36_DEFINITION_OF_DONE.md`:

- All modules, screens, workflows, roles, models, APIs, Swagger, validation, seed, audit, Fusion adapter (mock + scaffold)
- Flutter uses APIs only; EN/AR + RTL; Flutter Web admin path
- Lint/test/build/analyze green; GitHub CI green
- README + `.env.example` + release checklist complete
- Production Oracle/SSO/store secrets documented as blockers if missing — do not block Phase 1 completion

---

## Current repository reality (intake)

As of 2026-07-09 intake:

| Exists | Missing |
|---|---|
| `/docs` full specification pack (00–37 + MANIFEST) | `apps/api` NestJS app |
| `.cursor/rules`, `.cursor/skills` (ui-ux-pro-max, frontend-design) | `apps/mobile` Flutter app |
| | `docker-compose.yml`, root `README.md`, `.env.example`, `.gitignore` |
| | `.github/workflows` CI |
| | Prisma schema, seed, source code |

This is a **docs-first greenfield**. Implementation has not started. Control files under `docs/_cursor/` are the execution system for subsequent runs.
