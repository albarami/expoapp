# NEXT_RUN.md — Resume Point

**Updated:** 2026-07-09 (T-MOB-01 **passed** — CI green)  
**Read this file first on every new Cursor session.**

---

## Current phase

**T-MOB-02 Flutter auth + session + role shell** — login, demo buttons, token session, `/auth/me`, role tabs. T-MOB-01 Flutter foundation is complete.

---

## Current branch

- Branch: `agent/T-MOB-01-flutter-foundation` (T-MOB-01 complete; start T-MOB-02 from this HEAD or a new `agent/T-MOB-02-*` branch)
- Remote: `origin` → `https://github.com/albarami/expoapp.git`
- Base: T-MOB-01 green HEAD / CI https://github.com/albarami/expoapp/actions/runs/29036867939
- CI (T-MOB-01): **green** — https://github.com/albarami/expoapp/actions/runs/29036867939
- PR: not created (`main` does not exist yet on remote)

---

## Current task

| Now | Next exact task |
|---|---|
| T-MOB-01 **passed** | Start **T-MOB-02** Flutter auth + session + role shell |

---

## Completed this run (T-MOB-01)

1. Feature-first Flutter layout under `apps/mobile/lib` (`app/`, `core/`, `features/`, `l10n/`, `shared/`)
2. Material 3 theme + design tokens (`AppSpacing`, `AppRadius`, status colors) via **ui-ux-pro-max**
3. EN/AR ARB + `flutter gen-l10n`; locale controller + language switcher
4. GoRouter shell with role-aware tabs, route stubs, auth redirects
5. Dio `ApiClient`, secure token storage, session controller, Riverpod providers
6. Shared widgets: scaffold, cards, buttons, fields, loading/empty/error, chips, confirm sheet
7. Local `flutter analyze` + 14 tests; GitHub CI green

---

## Exact next actions (in order)

### 1. Start T-MOB-02

```bash
cd /home/barami/projects/expoapp
git checkout -B agent/T-MOB-02-auth-session origin/agent/T-MOB-01-flutter-foundation
# Implement login + demo users + /auth/me session restore + role shell polish
# Use .cursor/skills/ui-ux-pro-max/ for login UI
cd apps/mobile && flutter analyze && flutter test
git push -u origin agent/T-MOB-02-auth-session
# wait for GitHub CI green; update ledger/NEXT_RUN
```

### 2. Sequential foundation only

No parallel feature agents until foundations per `08_PARALLEL_EXECUTION_PLAN.md` are stable (auth UI + session still incomplete until T-MOB-02).

Remaining sequential mobile path after T-MOB-02: T-MOB-03..07 feature screens; T-L10N-01 polish later.

---

## Ports reminder

See `PORTS.md`.

---

## Do not do next

- Do not spawn parallel feature agents yet (auth/session foundation incomplete)
- Do not create Expo React Native apps
- Do not force-push `main`
- Do not require real Oracle credentials in Phase 1
