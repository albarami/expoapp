# NEXT_RUN.md — Resume Point

**Updated:** 2026-07-09 (T-API-03 CI green)  
**Read this file first on every new Cursor session.**

---

## Current phase

**T-API-03 Auth + RBAC passed** (JWT login/me/logout, guards, role permissions, auth-ready seed).  
**Resume at T-API-04** (full seed data per `09_SEED_DATA.md`).

---

## Current branch

- Branch: `agent/T-API-03-auth-rbac`
- Remote: `origin` → `https://github.com/albarami/expoapp.git`
- CI: **success** — https://github.com/albarami/expoapp/actions/runs/29028053503
- PR: not created (`main` does not exist yet on remote)

---

## Current task

| Now | Next exact task |
|---|---|
| T-API-03 **passed** (local + CI green) | Start **T-API-04** — Seed data (core + full) |

---

## Completed this run

1. Branched `agent/T-API-03-auth-rbac` from T-API-02 green HEAD
2. Auth module: POST `/auth/login`, GET `/auth/me`, POST `/auth/logout`
3. JWT access + refresh tokens; Passport JWT strategy; global `JwtAuthGuard` + `RolesGuard`
4. `@Public()`, `@Roles()`, `@CurrentUser()`; ROLE_PERMISSIONS map
5. Auth-ready idempotent seed (5 departments + 5 demo users, bcrypt `Password123!`)
6. Temporary RBAC probe routes for BI-03 until notifications/audit modules exist
7. Unit + e2e tests (BU-01, BI-02, BI-03); local lint/test/e2e/build PASS
8. GitHub Actions CI **green** (run 29028053503)

---

## Exact next actions (in order)

### 1. Start T-API-04 (Seed data)

Expand `apps/api/prisma/seed.ts` to full `09_SEED_DATA.md` (systems, security roles, notifications, access requests, approvals, audit samples). Keep idempotent. Auth users/departments already seeded in T-API-03 — extend, do not break login.

Branch pattern: `agent/T-API-04-seed-data` from T-API-03 green HEAD.

### 2. Then sequential foundation

T-API-05 (reference/dashboard) → … per `03_TASK_LEDGER.md`  
No parallel feature agents until foundations per `08_PARALLEL_EXECUTION_PLAN.md`.

---

## Ports reminder

See `PORTS.md`.

---

## Do not do next

- Do not skip T-API-04 and jump to feature modules or T-MOB-*
- Do not spawn parallel feature agents yet
- Do not create Expo React Native apps
- Do not force-push `main`
