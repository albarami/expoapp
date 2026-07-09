# NEXT_RUN.md — Resume Point

**Updated:** 2026-07-09 (T-API-07 local green — awaiting CI / mark passed)  
**Read this file first on every new Cursor session.**

---

## Current phase

**T-API-07 Access requests** — submit/list/detail/cancel + events + numbering implemented locally. Confirm GitHub CI green, then start **T-API-08 Approvals**.

---

## Current branch

- Branch: `agent/T-API-07-access-requests`
- Remote: `origin` → `https://github.com/albarami/expoapp.git`
- Base: T-API-10 green HEAD (`3e39d9944079b0ecffde7ae1d70846d1e0179ed7`) / CI https://github.com/albarami/expoapp/actions/runs/29033402305
- CI (T-API-07): pending after push
- PR: not created (`main` does not exist yet on remote)

---

## Current task

| Now | Next exact task |
|---|---|
| T-API-07 local **green** | Wait for GitHub CI green → mark ledger passed → start **T-API-08** Approvals |

---

## Completed this run (T-API-07)

1. `AccessRequestsModule` with create/list/detail/cancel
2. Request numbering `AR-YYYY-######`, Fusion validate, manager/security routing, approval task + timeline events + audit
3. Role-scoped lists (own / manager direct reports / security+admin all)
4. Validation codes: `ROLE_NOT_REQUESTABLE`, `MANAGER_NOT_FOUND`, `INVALID_ACCESS_DATES`, `DUPLICATE_ACTIVE_REQUEST`, `REQUEST_NOT_CANCELABLE`, `USER_INACTIVE`
5. Unit tests (BU-03/BU-07) + e2e `access-requests.e2e-spec.ts` (BI-05)
6. Local lint/test/e2e/build green

---

## Exact next actions (in order)

### 1. Confirm T-API-07 CI green

```bash
cd /home/barami/projects/expoapp
gh run list --branch agent/T-API-07-access-requests --limit 5
# when green: update 03_TASK_LEDGER.md T-API-07 Status=passed + CI URL
```

### 2. Start T-API-08

```bash
git checkout -B agent/T-API-08-approvals origin/agent/T-API-07-access-requests
# Implement approvals per 17_APPROVAL_ENGINE.md + ledger + 10_API_CONTRACT.md
cd apps/api && npm run lint && npm run test && npm run test:e2e && npm run build
git push -u origin agent/T-API-08-approvals
```

### 3. Sequential foundation only

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
