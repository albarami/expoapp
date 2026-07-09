# Implementation Plan — ExpoApp

**Generated:** 2026-07-09  
**Sources:** `31_CURSOR_BUILD_TASKS.md`, `01_MASTER_CURSOR_PROMPT.md`, full `/docs`  
**Rule:** Feature loop = backend → Flutter → tests → local validation → push → wait for green CI → merge → next

---

## Phase overview

```text
P0 Intake + control files          ← THIS RUN (complete)
P1 Environment + CI bootstrap      ← NEXT RUN
P2 Repo scaffold (api + mobile + docker + README)
P3 Backend foundation (Nest, Prisma, health, Swagger)
P4 Auth + RBAC + seed users
P5 Reference data + dashboard API
P6 Notifications backend + tests
P7 Access requests + approvals + Fusion adapter + audit APIs
P8 Flutter foundation (app shell, theme, l10n, router, Dio, session)
P9 Flutter auth + dashboard
P10 Flutter notifications (+ admin create)
P11 Flutter access requests + approvals + audit
P12 Localization polish + error/empty states audit
P13 Full QA + demo scenarios + release checklist
```

Parallel agents are **forbidden** until P1–P8 foundations are stable and CI is green (see `08_PARALLEL_EXECUTION_PLAN.md`).

---

## Phase 0 — Documentation intake & control system (CURRENT)

**Goal:** Full understanding; control files exist; dependency graph encoded.

**Deliverables:**
- All `docs/_cursor/*.md` files
- Accurate repo-state assessment
- NEXT_RUN resume point

**Exit criteria:** All 10 control files substantive; no feature code yet.

---

## Phase 1 — Environment setup & CI bootstrap

**Goal:** Toolchain verified; minimal scaffold that CI can run; green CI on control/setup branch.

**Steps:**
1. Detect Node/npm/Flutter/Docker versions on WSL
2. Create `.gitignore`, root `.env.example`, `docker-compose.yml`
3. Scaffold minimal `apps/api` (NestJS) with lint/test/build scripts that pass on empty/health stub if needed — prefer real Nest scaffold
4. Scaffold minimal `apps/mobile` (Flutter create) with analyze/test passing
5. Create `.github/workflows/ci.yml` per master prompt
6. First local validation commands
7. Branch `agent/T-ENV-01-setup-control`, commit, push, wait for green CI

**Exit criteria:** CI green on setup branch; docker compose config valid; npm + flutter commands documented in `05_ENVIRONMENT_SETUP.md`.

---

## Phase 2 — Repository scaffold completion

**Tasks:** Root README structure, env examples for api/mobile, Prisma folder placeholders, Flutter folder skeleton matching `04_REPOSITORY_STRUCTURE.md`.

**Depends on:** P1 CI green.

---

## Phase 3 — Backend foundation

- Nest bootstrap: ConfigModule, CORS, prefix, validation pipe, exception filter, trace ID, Swagger, Helmet
- PrismaModule + schema from `08_DATABASE_SCHEMA_PRISMA.md`
- Health module (`/health`)
- Migration `init`

**Depends on:** P2. **Blocks:** all feature modules.

---

## Phase 4 — Auth, RBAC, seed

- Auth login/me/logout, JWT strategy, guards, roles decorator, permission map
- Seed script (users, departments) — expand in later phases
- Auth audit events

**Depends on:** P3.

---

## Phase 5 — Reference data + dashboard

- Departments/systems/roles endpoints via `/reference-data`
- `/dashboard/summary` role-aware
- Seed systems + security roles

**Depends on:** P4.

---

## Phase 6 — Notifications backend

- Full notifications module per `15_NOTIFICATIONS_MODULE.md` + API contract
- Audience resolver, recipients, read, stats, cancel, audit
- Seed ≥6 notifications
- Backend tests

**Depends on:** P5. **CI green required before Flutter notifications.**

---

## Phase 7 — Access requests, approvals, Fusion, audit APIs

Order within phase (still sequential on shared schema/services):
1. Fusion adapter interface + mock + scaffold
2. Audit service + list endpoint
3. Access requests module
4. Approvals module + mock provisioning
5. Seed requests/approvals/audit samples
6. Integration tests for full workflow

**Depends on:** P6 recommended (shared patterns); hard depends on P4–P5.

---

## Phase 8 — Flutter foundation

- Flutter app structure, Material 3 theme (`21_UI_UX_DESIGN_SYSTEM.md`)
- ARB EN/AR + gen-l10n
- GoRouter + role shell stubs
- Dio client + secure storage + session controller
- Shared widgets: scaffold, loading, empty, error, buttons, chips
- **Skill:** `ui-ux-pro-max` (+ flutter.csv) for design-system widgets

**Depends on:** P1 mobile scaffold; ideally P4 API for auth wiring in P9.

**Note:** Can start shell after P1, but do not parallelize against critical shared files without integration owner.

---

## Phase 9 — Flutter auth + dashboard

- Login + demo quick buttons
- Role-based dashboard consuming `/dashboard/summary`

**Depends on:** P4, P5, P8. CI green.

---

## Phase 10 — Flutter notifications

- List, detail, mark read, admin create, stats
- Filters/search, states, l10n

**Depends on:** P6, P9. Use `ui-ux-pro-max`.

---

## Phase 11 — Flutter access requests, approvals, audit

- My requests, form, detail/timeline, cancel
- Approval queue/decision
- Audit viewer + route guards

**Depends on:** P7, P9. Use `ui-ux-pro-max`.

---

## Phase 12 — Localization & UX polish

- Full string audit; RTL pass; error-code mapping; double-submit guards
- Web admin layout check

**Depends on:** P9–P11 screens existing.

---

## Phase 13 — QA, demo, release

- Backend + Flutter automated tests complete per matrix
- Manual scenarios 1–4
- README final; release checklist; handover notes
- Document Phase 2 external blockers (Oracle, SSO, store)

**Depends on:** All feature tasks merged with green CI.

---

## Ordered checkpoint list (from docs)

1. Project scaffolding works
2. Backend health endpoint works
3. Database migration and seed work
4. Auth and role guards work
5. Notification API works
6. Access request workflow works
7. Flutter login works
8. Flutter dashboard works
9. Notification UI works
10. Access request UI works
11. Approval queues work
12. Admin screens work
13. Arabic/English switching works
14. Full demo scenario passes

---

## Out of scope (do not implement in Phase 1)

- Real Oracle Fusion calls
- Real SSO
- Real APNs/FCM delivery
- Production cloud deployment
- Penetration testing
- App Store / Play publishing
- MDM
- Chat, AI, visitor, payments, etc. (`34_RISKS_ASSUMPTIONS_DEPENDENCIES.md`)
