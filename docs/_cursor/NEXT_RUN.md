# NEXT_RUN.md — Resume Point

**Updated:** 2026-07-09 (T-MOB-03 **passed** — CI green)  
**Read this file first on every new Cursor session.**

---

## Current phase

**T-MOB-04 Flutter notifications (+ admin)** — list/detail/read/create/stats against notifications API. T-MOB-03 role-aware dashboard is complete.

---

## Current branch

- Branch: `agent/T-MOB-03-dashboard` (T-MOB-03 complete; start T-MOB-04 from this HEAD or a new `agent/T-MOB-04-*` branch)
- Remote: `origin` → `https://github.com/albarami/expoapp.git`
- Base: T-MOB-03 green HEAD / CI https://github.com/albarami/expoapp/actions/runs/29038786051
- CI (T-MOB-03): **green** — https://github.com/albarami/expoapp/actions/runs/29038786051
- PR: not created (`main` does not exist yet on remote)

---

## Current task

| Now | Next exact task |
|---|---|
| T-MOB-03 **passed** | Start **T-MOB-04** Flutter notifications (+ admin) |

---

## Completed this run (T-MOB-03)

1. `GET /dashboard/summary` repository + domain models
2. Role-aware dashboard UI (employee / manager / security / system admin)
3. Metrics grid, latest notifications/requests, audit + admin stats sections
4. Loading skeletons, error+retry, empty list states, pull-to-refresh
5. Quick actions / deep links to stub feature routes
6. EN/AR l10n for dashboard strings; status chip coverage for all request statuses
7. Local `flutter analyze` clean + 37 tests; GitHub CI green

---

## Exact next actions (in order)

### 1. Start T-MOB-04

```bash
cd /home/barami/projects/expoapp
git checkout -B agent/T-MOB-04-notifications origin/agent/T-MOB-03-dashboard
# Implement notifications list/detail/read + admin create/stats
# Use .cursor/skills/ui-ux-pro-max/
# Depends on T-API-06 (already passed)
cd apps/mobile && flutter analyze && flutter test
git push -u origin agent/T-MOB-04-notifications
# wait for GitHub CI green; update ledger/NEXT_RUN
```

### 2. Sequential foundation only

Still prefer sequential mobile feature tasks (T-MOB-04..07) until navigation + shared contracts feel stable per `08_PARALLEL_EXECUTION_PLAN.md` before spawning parallel feature agents.

Remaining sequential mobile path: T-MOB-04..07; T-L10N-01 polish later.

---

## Ports reminder

See `PORTS.md`.

---

## Do not do next

- Do not spawn parallel feature agents until master prompt / parallel plan criteria are fully met
- Do not create Expo React Native apps
- Do not force-push `main`
- Do not require real Oracle credentials in Phase 1
