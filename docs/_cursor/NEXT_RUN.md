# NEXT_RUN.md — Resume Point

**Updated:** 2026-07-09 (T-MOB-02 implemented locally — awaiting CI green)  
**Read this file first on every new Cursor session.**

---

## Current phase

**T-MOB-02 Flutter auth + session + role shell** — implemented; waiting for GitHub CI green, then start **T-MOB-03** dashboard.

---

## Current branch

- Branch: `agent/T-MOB-02-auth-session`
- Remote: `origin` → `https://github.com/albarami/expoapp.git`
- Base: T-MOB-01 green HEAD / CI https://github.com/albarami/expoapp/actions/runs/29036867939
- CI (T-MOB-02): pending push
- PR: not created (`main` does not exist yet on remote)

---

## Current task

| Now | Next exact task |
|---|---|
| T-MOB-02 **in_progress** (local analyze/test green, 29 tests) | Push + wait CI green → then **T-MOB-03** Flutter dashboard |

---

## Completed this run (T-MOB-02)

1. Real login against `POST /auth/login` with validation + localized errors
2. Demo quick-login chips (Employee/Manager/Security Admin/System Admin) when `ENABLE_DEMO_LOGIN`
3. Session restore via secure token + `GET /auth/me`; splash while unknown
4. Logout via `POST /auth/logout` + local clear; 401 → expired → login
5. Role-aware shell tabs + restricted-route redirect/snackbar
6. Auth repository, demo accounts, EN/AR l10n strings
7. Local `flutter analyze` clean + 29 tests

---

## Exact next actions (in order)

### 1. Finish T-MOB-02 CI gate

```bash
cd /home/barami/projects/expoapp
# after push of agent/T-MOB-02-auth-session
# wait for GitHub CI green; update ledger/NEXT_RUN with run URL
```

### 2. Start T-MOB-03

```bash
git checkout -B agent/T-MOB-03-dashboard origin/agent/T-MOB-02-auth-session
# Implement role-based dashboard from GET /dashboard/summary
# Use .cursor/skills/ui-ux-pro-max/
cd apps/mobile && flutter analyze && flutter test
```

### 3. Sequential foundation only

No parallel feature agents until auth/session + navigation foundations are CI-green and stable per `08_PARALLEL_EXECUTION_PLAN.md`.

Remaining sequential mobile path after T-MOB-02: T-MOB-03..07; T-L10N-01 polish later.

---

## Ports reminder

See `PORTS.md`.

---

## Do not do next

- Do not spawn parallel feature agents yet (wait for T-MOB-02 CI green)
- Do not create Expo React Native apps
- Do not force-push `main`
- Do not require real Oracle credentials in Phase 1
