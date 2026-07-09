# NEXT_RUN.md — Resume Point

**Updated:** 2026-07-09 (T-API-06 **passed**; CI green)  
**Read this file first on every new Cursor session.**

---

## Current phase

**T-API-09 Fusion adapter** — next sequential foundation task per ledger (T-API-06 notifications **passed**; T-API-10 audit list endpoint still pending — `AuditService.record` already shipped with T-API-06).

---

## Current branch

- Branch: `agent/T-API-06-notifications` (T-API-06 green; start T-API-09 from this HEAD)
- Remote: `origin` → `https://github.com/albarami/expoapp.git`
- Base: T-API-06 green HEAD (`e0f7503` / CI https://github.com/albarami/expoapp/actions/runs/29032026526)
- CI (T-API-06): **green** — https://github.com/albarami/expoapp/actions/runs/29032026526
- PR: not created (`main` does not exist yet on remote)

---

## Current task

| Now | Next exact task |
|---|---|
| T-API-06 **passed** | Start **T-API-09** — Fusion adapter |

---

## Completed this run

1. T-API-06 feature commit `99f19df` — notifications + audience + audit helper
2. Docs commit `e0f7503` — ledger/NEXT_RUN/test matrix for implemented state
3. Local lint / unit / e2e / build **PASS**
4. GitHub CI **green** (run 29032026526)

---

## Exact next actions (in order)

### 1. Start T-API-09 (Fusion adapter)

Per `03_TASK_LEDGER.md` / `23_ORACLE_FUSION_ADAPTER.md`.  
Branch pattern: `agent/T-API-09-fusion-adapter` from T-API-06 green HEAD.

### 2. Sequential foundation only

No parallel feature agents until foundations per `08_PARALLEL_EXECUTION_PLAN.md`.

---

## Ports reminder

See `PORTS.md`.

---

## Do not do next

- Do not skip to Flutter feature modules before remaining API foundations (Fusion, audit list, access, approvals)
- Do not spawn parallel feature agents yet
- Do not create Expo React Native apps
- Do not force-push `main`
