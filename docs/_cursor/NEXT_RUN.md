# NEXT_RUN.md — Resume Point

**Updated:** 2026-07-09 (T-API-09 **in progress** — implementation ready for local validation / CI)  
**Read this file first on every new Cursor session.**

---

## Current phase

**T-API-09 Fusion adapter** — interface + MockFusionAdapter + Oracle scaffold + `FUSION_ADAPTER` provider + IntegrationOutbox helper. Validate locally, push, wait for CI green, then continue to **T-API-10** (audit list endpoint).

---

## Current branch

- Branch: `agent/T-API-09-fusion-adapter` (from T-API-06 green HEAD)
- Remote: `origin` → `https://github.com/albarami/expoapp.git`
- Base: T-API-06 green HEAD (`e0f7503` / CI https://github.com/albarami/expoapp/actions/runs/29032026526)
- CI (T-API-09): pending push / validation
- PR: not created (`main` does not exist yet on remote)

---

## Current task

| Now | Next exact task |
|---|---|
| T-API-09 **in_progress** | Finish local lint/test/e2e/build → push → CI green → mark passed → start **T-API-10** |

---

## Completed this run

1. Fusion adapter interface (`fusion-adapter.interface.ts`)
2. `MockFusionAdapter` (seed-backed profile/roles/validate/provision/status)
3. `OracleFusionAdapter` scaffold (`FUSION_CONFIGURATION_MISSING` when env incomplete)
4. `FusionModule` provider selection via `FUSION_MODE` + `FUSION_ADAPTER` token
5. `IntegrationOutboxService` enqueue/mark helpers for future provisioning path
6. Unit tests BU-06 / FUS-01..03 + e2e `fusion.e2e-spec.ts`
7. Wired `FusionModule` into `AppModule`

---

## Exact next actions (in order)

### 1. Finish T-API-09 validation

```bash
cd /home/barami/projects/expoapp
git checkout -B agent/T-API-09-fusion-adapter e0f7503  # if branch not yet created from green HEAD
# ensure fusion changes are on this branch
cd apps/api && npm run lint && npm run test && npm run test:e2e && npm run build
git push -u origin agent/T-API-09-fusion-adapter
# wait for GitHub CI green; update ledger/NEXT_RUN
```

### 2. After T-API-09 green → T-API-10

Per ledger: Audit module list endpoint (`GET /audit-logs`), admin-only filters.  
`AuditService.record` already shipped with T-API-06.

### 3. Sequential foundation only

No parallel feature agents until foundations per `08_PARALLEL_EXECUTION_PLAN.md`.

---

## Ports reminder

See `PORTS.md`.

---

## Do not do next

- Do not skip to Flutter feature modules before remaining API foundations (audit list, access, approvals)
- Do not spawn parallel feature agents yet
- Do not create Expo React Native apps
- Do not force-push `main`
- Do not require real Oracle credentials in Phase 1
