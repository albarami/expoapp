# NEXT_RUN.md — Resume Point

**Updated:** 2026-07-09 (T-API-04 CI green)  
**Read this file first on every new Cursor session.**

---

## Current phase

**T-API-04 Seed data passed** (full idempotent seed per `09_SEED_DATA.md`).  
**Resume at T-API-05** (reference-data + dashboard).

---

## Current branch

- Branch: `agent/T-API-04-seed-data`
- Remote: `origin` → `https://github.com/albarami/expoapp.git`
- CI: **success** — https://github.com/albarami/expoapp/actions/runs/29028738943
- PR: not created (`main` does not exist yet on remote)

---

## Current task

| Now | Next exact task |
|---|---|
| T-API-04 **passed** (local + CI green) | Start **T-API-05** — Reference data + dashboard |

---

## Completed this run

1. Branched `agent/T-API-04-seed-data` from T-API-03 green HEAD
2. Expanded `apps/api/prisma/seed.ts` to full `09_SEED_DATA.md`
3. Seeded: 5 departments, 5 users, 5 systems, 9 security roles, 6 notifications (+ recipients), 4 access requests, 5 approval tasks, 11 request events, 25 seed-keyed audit logs
4. Idempotent upserts / find-first sync; second `npm run seed` stable
5. BI-08 Jest DB test `seed.idempotency.spec.ts`
6. Local lint / unit / e2e / build PASS
7. GitHub Actions CI **green** (run 29028738943)

---

## Exact next actions (in order)

### 1. Start T-API-05 (Reference data + dashboard)

Implement GET `/reference-data` and GET `/dashboard/summary` per `10_API_CONTRACT.md`.  
Branch pattern: `agent/T-API-05-reference-dashboard` from T-API-04 green HEAD.

### 2. Then sequential foundation

T-API-06+ per `03_TASK_LEDGER.md`  
No parallel feature agents until foundations per `08_PARALLEL_EXECUTION_PLAN.md`.

---

## Ports reminder

See `PORTS.md`.

---

## Do not do next

- Do not skip T-API-05 and jump to feature modules or T-MOB-*
- Do not spawn parallel feature agents yet
- Do not create Expo React Native apps
- Do not force-push `main`
