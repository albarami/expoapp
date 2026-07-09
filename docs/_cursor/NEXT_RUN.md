# NEXT_RUN.md — Resume Point

**Updated:** 2026-07-09 (T-MOB-02 **passed** — CI green)  
**Read this file first on every new Cursor session.**

---

## Current phase

**T-MOB-03 Flutter dashboard** — role-based dashboard from `GET /dashboard/summary`. T-MOB-02 auth + session + role shell is complete.

---

## Current branch

- Branch: `agent/T-MOB-02-auth-session` (T-MOB-02 complete; start T-MOB-03 from this HEAD or a new `agent/T-MOB-03-*` branch)
- Remote: `origin` → `https://github.com/albarami/expoapp.git`
- Base: T-MOB-02 green HEAD / CI https://github.com/albarami/expoapp/actions/runs/29037687031
- CI (T-MOB-02): **green** — https://github.com/albarami/expoapp/actions/runs/29037687031
- PR: not created (`main` does not exist yet on remote)

---

## Current task

| Now | Next exact task |
|---|---|
| T-MOB-02 **passed** | Start **T-MOB-03** Flutter dashboard |

---

## Completed this run (T-MOB-02)

1. Real login against `POST /auth/login` with validation + localized errors
2. Demo quick-login chips (Employee/Manager/Security Admin/System Admin) when `ENABLE_DEMO_LOGIN`
3. Session restore via secure token + `GET /auth/me`; splash while unknown
4. Logout via `POST /auth/logout` + local clear; 401 → expired → login
5. Role-aware shell tabs + restricted-route redirect/snackbar
6. Auth repository, demo accounts, EN/AR l10n strings
7. Local `flutter analyze` clean + 29 tests; GitHub CI green

---

## Exact next actions (in order)

### 1. Start T-MOB-03

```bash
cd /home/barami/projects/expoapp
git checkout -B agent/T-MOB-03-dashboard origin/agent/T-MOB-02-auth-session
# Implement role-based dashboard from GET /dashboard/summary
# Use .cursor/skills/ui-ux-pro-max/
cd apps/mobile && flutter analyze && flutter test
git push -u origin agent/T-MOB-03-dashboard
# wait for GitHub CI green; update ledger/NEXT_RUN
```

### 2. Sequential foundation only

Auth/session foundation is now CI-green. Still prefer sequential mobile feature tasks (T-MOB-03..07) until navigation + shared contracts feel stable per `08_PARALLEL_EXECUTION_PLAN.md` before spawning parallel feature agents.

Remaining sequential mobile path: T-MOB-03..07; T-L10N-01 polish later.

---

## Ports reminder

See `PORTS.md`.

---

## Do not do next

- Do not spawn parallel feature agents until master prompt / parallel plan criteria are fully met
- Do not create Expo React Native apps
- Do not force-push `main`
- Do not require real Oracle credentials in Phase 1
