# NEXT_RUN.md — Resume Point

**Updated:** 2026-07-09 (T-MOB-05 local green — awaiting CI)  
**Read this file first on every new Cursor session.**

---

## Current phase

**T-MOB-05 Flutter access requests** — my requests, form, detail/timeline, cancel against access-requests API. Local `flutter analyze` + 63 tests green; push and wait for GitHub CI.

---

## Current branch

- Branch: `agent/T-MOB-05-access-requests`
- Remote: `origin` → `https://github.com/albarami/expoapp.git`
- Base: T-MOB-04 green HEAD / CI https://github.com/albarami/expoapp/actions/runs/29039489370
- CI (T-MOB-05): **pending** after push
- PR: not created (`main` does not exist yet on remote)

---

## Current task

| Now | Next exact task |
|---|---|
| T-MOB-05 local green | Wait for GitHub CI green, then start **T-MOB-06** Flutter approvals |

---

## Completed this run (T-MOB-05)

1. My Requests list with status tabs (All/Pending/Completed/Rejected), pull-to-refresh, FAB
2. New Access Request form (system/role from reference-data, justification, duration, dates, urgency)
3. Request detail with timeline + cancel when requester + cancelable status
4. EN/AR l10n; error codes for invalid dates / not cancelable / inactive user
5. Routes `/requests`, `/requests/new`, `/requests/:id` wired (stubs replaced)
6. ui-ux-pro-max applied to list/form/detail
7. Local `flutter analyze` clean + 63 tests

---

## Exact next actions (in order)

### 1. Confirm T-MOB-05 CI green

```bash
cd /home/barami/projects/expoapp
gh run list --branch agent/T-MOB-05-access-requests --limit 3
# when green: update ledger Status to passed + CI URL; then start T-MOB-06
```

### 2. Start T-MOB-06

```bash
cd /home/barami/projects/expoapp
git checkout -B agent/T-MOB-06-approvals origin/agent/T-MOB-05-access-requests
# Implement approval queue + decision UI
# Use .cursor/skills/ui-ux-pro-max/
# Depends on T-API-08 (already passed)
cd apps/mobile && flutter analyze && flutter test
git push -u origin agent/T-MOB-06-approvals
# wait for GitHub CI green; update ledger/NEXT_RUN
```

### 3. Sequential foundation only

Still prefer sequential mobile feature tasks (T-MOB-06..07) until navigation + shared contracts feel stable per `08_PARALLEL_EXECUTION_PLAN.md` before spawning parallel feature agents.

Remaining sequential mobile path: T-MOB-06..07; T-L10N-01 polish later.

---

## Ports reminder

See `PORTS.md`.

---

## Do not do next

- Do not spawn parallel feature agents until master prompt / parallel plan criteria are fully met
- Do not create Expo React Native apps
- Do not force-push `main`
- Do not require real Oracle credentials in Phase 1
