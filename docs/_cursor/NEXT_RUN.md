# NEXT_RUN.md — Resume Point

**Updated:** 2026-07-09 (T-API-08 **passed** — CI green)  
**Read this file first on every new Cursor session.**

---

## Current phase

**T-MOB-01 Flutter foundation** — app structure, theme, l10n, GoRouter stub, Dio, secure storage, shared widgets. All Phase-7 API tasks (T-API-01..10) are complete.

---

## Current branch

- Branch: `agent/T-API-08-approvals` (T-API-08 complete; start T-MOB-01 from this HEAD or a new `agent/T-MOB-01-*` branch)
- Remote: `origin` → `https://github.com/albarami/expoapp.git`
- Base: T-API-08 green HEAD / CI https://github.com/albarami/expoapp/actions/runs/29036247670
- CI (T-API-08): **green** — https://github.com/albarami/expoapp/actions/runs/29036247670
- PR: not created (`main` does not exist yet on remote)

---

## Current task

| Now | Next exact task |
|---|---|
| T-API-08 **passed** | Start **T-MOB-01** Flutter foundation |

---

## Completed this run (T-API-08)

1. `ApprovalsModule` — GET `/approvals` (role-scoped queue) + POST `/approvals/:taskId/decision`
2. Manager approve → SECURITY_PENDING + security task (when required) or mock provision/complete
3. Manager/security reject → MANAGER_REJECTED / SECURITY_REJECTED + COMPLETE stage
4. Security approve → PROVISIONING + transactional outbox + MockFusion complete path
5. Timeline events + audit (approve/reject/provisioning/completed)
6. Unit BU-04 + e2e BI-06; local + GitHub CI green

---

## Exact next actions (in order)

### 1. Start T-MOB-01

```bash
cd /home/barami/projects/expoapp
git checkout -B agent/T-MOB-01-flutter-foundation origin/agent/T-API-08-approvals
# Implement Flutter foundation per 12_FLUTTER_ARCHITECTURE.md + ledger
# Use .cursor/skills/ui-ux-pro-max/ for theme/widgets
cd apps/mobile && flutter analyze && flutter test
git push -u origin agent/T-MOB-01-flutter-foundation
# wait for GitHub CI green; update ledger/NEXT_RUN
```

### 2. Sequential foundation only

No parallel feature agents until foundations per `08_PARALLEL_EXECUTION_PLAN.md` (architecture, CI, auth, navigation, Prisma, localization, shared contracts).

Remaining sequential mobile path after T-MOB-01: T-MOB-02 (auth/session) → T-MOB-03..07 feature screens.

---

## Ports reminder

See `PORTS.md`.

---

## Do not do next

- Do not spawn parallel feature agents yet (mobile foundations incomplete)
- Do not create Expo React Native apps
- Do not force-push `main`
- Do not require real Oracle credentials in Phase 1
