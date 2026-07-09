# NEXT_RUN.md — Resume Point

**Updated:** 2026-07-09 (T-API-07 **passed** — CI green)  
**Read this file first on every new Cursor session.**

---

## Current phase

**T-API-08 Approvals** — manager/security decisions + mock provisioning. Depends on T-API-07 (access requests) + T-API-09 (Fusion).

---

## Current branch

- Branch: `agent/T-API-07-access-requests` (T-API-07 complete; start T-API-08 from this HEAD or a new `agent/T-API-08-*` branch)
- Remote: `origin` → `https://github.com/albarami/expoapp.git`
- Base: T-API-07 green HEAD / CI https://github.com/albarami/expoapp/actions/runs/29035039147
- CI (T-API-07): **green** — https://github.com/albarami/expoapp/actions/runs/29035039147
- PR: not created (`main` does not exist yet on remote)

---

## Current task

| Now | Next exact task |
|---|---|
| T-API-07 **passed** | Start **T-API-08** Approvals + mock provisioning |

---

## Completed this run (T-API-07)

1. `AccessRequestsModule` — POST/GET list/GET detail/PATCH cancel
2. Request numbering `AR-YYYY-######`, Fusion `validateAccessRequest`, manager/security initial routing
3. Approval task + timeline events + audit on submit/cancel
4. Role-scoped lists (own / manager direct reports / security+admin all)
5. Validation codes per workflow docs
6. Unit (BU-03/BU-07) + e2e BI-05; local + GitHub CI green

---

## Exact next actions (in order)

### 1. Start T-API-08

```bash
cd /home/barami/projects/expoapp
git checkout -B agent/T-API-08-approvals origin/agent/T-API-07-access-requests
# Implement approvals per 17_APPROVAL_ENGINE.md + ledger + 10_API_CONTRACT.md
cd apps/api && npm run lint && npm run test && npm run test:e2e && npm run build
git push -u origin agent/T-API-08-approvals
# wait for GitHub CI green; update ledger/NEXT_RUN
```

### 2. Sequential foundation only

No parallel feature agents until foundations per `08_PARALLEL_EXECUTION_PLAN.md`.

---

## Ports reminder

See `PORTS.md`.

---

## Do not do next

- Do not skip to Flutter feature modules before remaining API foundations (approvals)
- Do not spawn parallel feature agents yet
- Do not create Expo React Native apps
- Do not force-push `main`
- Do not require real Oracle credentials in Phase 1
