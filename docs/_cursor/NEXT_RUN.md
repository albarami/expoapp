# NEXT_RUN.md — Resume Point

**Updated:** 2026-07-09 (T-API-02 CI green)  
**Read this file first on every new Cursor session.**

---

## Current phase

**T-API-02 Prisma schema + migration passed** (full domain schema, init migration, CI migrate deploy).  
**Resume at T-API-03** (Auth + RBAC).

---

## Current branch

- Branch: `agent/T-API-02-prisma-schema`
- Remote: `origin` → `https://github.com/albarami/expoapp.git`
- CI: **success** — https://github.com/albarami/expoapp/actions/runs/29026568179
- PR: not created (`main` does not exist yet on remote)

---

## Current task

| Now | Next exact task |
|---|---|
| T-API-02 **passed** (local + CI green) | Start **T-API-03** — Auth + RBAC |

---

## Completed this run

1. Branched `agent/T-API-02-prisma-schema` from T-API-01 green HEAD
2. Replaced HealthCheck scaffold with full Prisma schema from `08_DATABASE_SCHEMA_PRISMA.md`
3. Created/applied init migration `20260709144050_init`
4. Schema unit tests + DB smoke tests (tables + Department round-trip)
5. CI: Postgres service + `prisma migrate deploy` before lint/test/build
6. Local lint/test/e2e/build PASS; GitHub Actions CI **green** (run 29026568179)

---

## Exact next actions (in order)

### 1. Start T-API-03 (Auth + RBAC)

Implement login/JWT/me/logout, guards, roles, permissions per `14_AUTH_AND_RBAC.md` + `10_API_CONTRACT.md`.  
Demo logins need seed users — either minimal auth-ready seed in T-API-03 or complete **T-API-04** seed immediately after auth module scaffolding so login acceptance can pass.

Branch pattern: `agent/T-API-03-auth-rbac` from T-API-02 green HEAD.

### 2. Then sequential foundation

T-API-04 (seed) → T-API-05 (reference/dashboard) → … per `03_TASK_LEDGER.md`  
No parallel feature agents until foundations per `08_PARALLEL_EXECUTION_PLAN.md`.

---

## Ports reminder

See `PORTS.md`.

---

## Do not do next

- Do not skip T-API-03 and jump to feature modules or T-MOB-*
- Do not spawn parallel feature agents yet
- Do not create Expo React Native apps
- Do not force-push `main`
