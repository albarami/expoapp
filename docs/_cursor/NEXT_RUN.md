# NEXT_RUN.md — Resume Point

**Updated:** 2026-07-09 (T-MOB-04 **passed** — CI green)  
**Read this file first on every new Cursor session.**

---

## Current phase

**T-MOB-05 Flutter access requests** — my requests, form, detail/timeline, cancel against access-requests API. T-MOB-04 notifications (+ admin) is complete.

---

## Current branch

- Branch: `agent/T-MOB-04-notifications` (T-MOB-04 complete; start T-MOB-05 from this HEAD or a new `agent/T-MOB-05-*` branch)
- Remote: `origin` → `https://github.com/albarami/expoapp.git`
- Base: T-MOB-04 green HEAD / CI https://github.com/albarami/expoapp/actions/runs/29039489370
- CI (T-MOB-04): **green** — https://github.com/albarami/expoapp/actions/runs/29039489370
- PR: not created (`main` does not exist yet on remote)

---

## Current task

| Now | Next exact task |
|---|---|
| T-MOB-04 **passed** | Start **T-MOB-05** Flutter access requests |

---

## Completed this run (T-MOB-04)

1. Notifications list with search, filter chips (All/Unread/High/Critical), pull-to-refresh
2. Notification detail + explicit mark-as-read; admin stats on detail
3. Admin create notification form (priority, audience, publish/schedule, critical confirm, preview)
4. Role guard: employee cannot open `/admin/notifications/create`
5. API envelope unwrap for auth/dashboard/notifications; CRITICAL priority aligned with backend
6. EN/AR l10n; ui-ux-pro-max applied to inbox/detail/create
7. Local `flutter analyze` clean + 52 tests; GitHub CI green

---

## Exact next actions (in order)

### 1. Start T-MOB-05

```bash
cd /home/barami/projects/expoapp
git checkout -B agent/T-MOB-05-access-requests origin/agent/T-MOB-04-notifications
# Implement my requests / form / detail+timeline / cancel
# Use .cursor/skills/ui-ux-pro-max/
# Depends on T-API-07 (already passed)
cd apps/mobile && flutter analyze && flutter test
git push -u origin agent/T-MOB-05-access-requests
# wait for GitHub CI green; update ledger/NEXT_RUN
```

### 2. Sequential foundation only

Still prefer sequential mobile feature tasks (T-MOB-05..07) until navigation + shared contracts feel stable per `08_PARALLEL_EXECUTION_PLAN.md` before spawning parallel feature agents.

Remaining sequential mobile path: T-MOB-05..07; T-L10N-01 polish later.

---

## Ports reminder

See `PORTS.md`.

---

## Do not do next

- Do not spawn parallel feature agents until master prompt / parallel plan criteria are fully met
- Do not create Expo React Native apps
- Do not force-push `main`
- Do not require real Oracle credentials in Phase 1
