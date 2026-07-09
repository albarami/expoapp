# NEXT_RUN.md — Resume Point

**Updated:** 2026-07-09 (T-API-10 **passed** — CI green)  
**Read this file first on every new Cursor session.**

---

## Current phase

**T-API-07 Access requests** — submit/list/detail/cancel + events + numbering. Depends on T-API-09 (Fusion) + T-API-10 (Audit).

---

## Current branch

- Branch: `agent/T-API-10-audit-list` (T-API-10 complete; start T-API-07 from this HEAD or a new `agent/T-API-07-*` branch)
- Remote: `origin` → `https://github.com/albarami/expoapp.git`
- Base: T-API-10 green HEAD / CI https://github.com/albarami/expoapp/actions/runs/29033402305
- CI (T-API-10): **green** — https://github.com/albarami/expoapp/actions/runs/29033402305
- PR: not created (`main` does not exist yet on remote)

---

## Current task

| Now | Next exact task |
|---|---|
| T-API-10 **passed** | Start **T-API-07** Access requests module |

---

## Completed this run (T-API-10)

1. `AuditController` `GET /audit-logs` with RBAC (`SECURITY_ADMIN`, `SYSTEM_ADMIN`)
2. List filters: actorId, actorEmail, action, entityType, entityId, from, to, page, pageSize
3. Removed temporary `RbacProbeController`
4. Unit tests for `AuditService.list` (BU-05) + e2e `audit.e2e-spec.ts` (BI-07, AUD-01/04)
5. BI-03 auth e2e updated to assert real paginated audit list
6. Local lint/test/e2e/build green; GitHub CI green

---

## Exact next actions (in order)

### 1. Start T-API-07

```bash
cd /home/barami/projects/expoapp
git checkout -B agent/T-API-07-access-requests origin/agent/T-API-10-audit-list
# Implement access requests per 16_ACCESS_REQUESTS_WORKFLOW.md + ledger + 10_API_CONTRACT.md
cd apps/api && npm run lint && npm run test && npm run test:e2e && npm run build
git push -u origin agent/T-API-07-access-requests
# wait for GitHub CI green; update ledger/NEXT_RUN
```

### 2. Then T-API-08 approvals

After T-API-07 green, continue to T-API-08 (approvals + mock provisioning).

### 3. Sequential foundation only

No parallel feature agents until foundations per `08_PARALLEL_EXECUTION_PLAN.md`.

---

## Ports reminder

See `PORTS.md`.

---

## Do not do next

- Do not skip to Flutter feature modules before remaining API foundations (access, approvals)
- Do not spawn parallel feature agents yet
- Do not create Expo React Native apps
- Do not force-push `main`
- Do not require real Oracle credentials in Phase 1
