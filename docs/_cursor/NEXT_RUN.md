# NEXT_RUN.md — Resume Point

**Updated:** 2026-07-09 (T-API-05 local PASS; CI pending)  
**Read this file first on every new Cursor session.**

---

## Current phase

**T-API-05 Reference data + dashboard** implemented locally.  
Await GitHub CI green, then resume at **T-API-06** (notifications) — or next sequential foundation per ledger.

---

## Current branch

- Branch: `agent/T-API-05-reference-dashboard`
- Remote: `origin` → `https://github.com/albarami/expoapp.git`
- CI: pending first push/run
- PR: not created (`main` does not exist yet on remote)

---

## Current task

| Now | Next exact task |
|---|---|
| T-API-05 **local PASS** (CI pending) | Confirm CI green → start **T-API-06** — Notifications module |

---

## Completed this run

1. Branched `agent/T-API-05-reference-dashboard` from T-API-04 green HEAD
2. Implemented `ReferenceDataModule` — `GET /api/v1/reference-data`
3. Implemented `DashboardModule` — `GET /api/v1/dashboard/summary` (role-aware)
4. Kept RBAC probe routes (notifications/audit still owned by later tasks)
5. Unit tests BU-08/BU-09 + e2e BI-09
6. Local lint / unit / e2e / build PASS

---

## Exact next actions (in order)

### 1. Confirm T-API-05 CI green

Push branch if not pushed; wait for GitHub Actions success; update ledger CI fields.

### 2. Start T-API-06 (Notifications)

Per `03_TASK_LEDGER.md` / `15_NOTIFICATIONS_MODULE.md` + `10_API_CONTRACT.md`.  
Branch pattern: `agent/T-API-06-notifications` from T-API-05 green HEAD.  
Replace RBAC probe `POST /notifications` with real module (keep BI-03 authz behavior).

### 3. Sequential foundation only

No parallel feature agents until foundations per `08_PARALLEL_EXECUTION_PLAN.md`.

---

## Ports reminder

See `PORTS.md`.

---

## Do not do next

- Do not skip T-API-06 and jump to Flutter feature modules
- Do not spawn parallel feature agents yet
- Do not create Expo React Native apps
- Do not force-push `main`
