# NEXT_RUN.md — Resume Point

**Updated:** 2026-07-09 (T-API-06 implemented locally; awaiting CI green confirmation in this run)  
**Read this file first on every new Cursor session.**

---

## Current phase

**T-API-06 Notifications module** — implemented; push/CI in progress. Next sequential API task after green: **T-API-09 Fusion adapter** (Phase 7 order; T-API-10 list endpoint still pending — `AuditService.record` already shipped with T-API-06).

---

## Current branch

- Branch: `agent/T-API-06-notifications`
- Remote: `origin` → `https://github.com/albarami/expoapp.git`
- Base: T-API-05 green HEAD (`d90df59` / CI https://github.com/albarami/expoapp/actions/runs/29030021235)
- CI (T-API-06): pending push
- PR: not created (`main` does not exist yet on remote)

---

## Current task

| Now | Next exact task |
|---|---|
| T-API-06 **implemented** (local lint/test/e2e/build PASS) | Confirm CI green, then start **T-API-09** — Fusion adapter |

---

## Completed this run

1. Notifications module: list/detail/create/publish/read/stats/cancel + audience resolver
2. Global `AuditService.record` helper + notification audit actions
3. Replaced temporary `POST /notifications` RBAC probe; kept `GET /audit-logs` probe
4. Local lint / unit / e2e / build **PASS**
5. Tests: BU-02, BI-04, BI-03 updated

---

## Exact next actions (in order)

### 1. Confirm T-API-06 CI green

Push `agent/T-API-06-notifications`, wait for GitHub Actions, fix until green, then mark ledger **passed**.

### 2. Start T-API-09 (Fusion adapter)

Per `03_TASK_LEDGER.md` / `23_ORACLE_FUSION_ADAPTER.md`.  
Branch pattern: `agent/T-API-09-fusion-adapter` from T-API-06 green HEAD.

### 3. Sequential foundation only

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
