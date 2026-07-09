# NEXT_RUN.md — Resume Point

**Updated:** 2026-07-09 (T-API-05 **passed**; CI green)  
**Read this file first on every new Cursor session.**

---

## Current phase

**T-API-06 Notifications module** — next sequential foundation task per ledger.

---

## Current branch

- Branch: `agent/T-API-05-reference-dashboard` (T-API-05 merged-ready; branch T-API-06 not created yet)
- Remote: `origin` → `https://github.com/albarami/expoapp.git`
- CI (T-API-05 feature): **green** — https://github.com/albarami/expoapp/actions/runs/29030021235
- PR: not created (`main` does not exist yet on remote)

---

## Current task

| Now | Next exact task |
|---|---|
| T-API-05 **passed** | Start **T-API-06** — Notifications module |

---

## Completed this run

1. T-API-05 feature commit `c2ef196` — reference-data + dashboard
2. Local lint / unit / e2e / build **PASS**
3. GitHub CI **green** (run 29030021235)
4. Docs commit `44c26cc` — ledger/NEXT_RUN updated (CI green: 29030195025)

---

## Exact next actions (in order)

### 1. Start T-API-06 (Notifications)

Per `03_TASK_LEDGER.md` / `15_NOTIFICATIONS_MODULE.md` + `10_API_CONTRACT.md`.  
Branch pattern: `agent/T-API-06-notifications` from T-API-05 green HEAD.  
Replace RBAC probe `POST /notifications` with real module (keep BI-03 authz behavior).

### 2. Sequential foundation only

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
