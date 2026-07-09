# NEXT_RUN.md — Resume Point

**Updated:** 2026-07-09 (T-MOB-06 implemented locally — awaiting CI green)  
**Read this file first on every new Cursor session.**

---

## Current phase

**T-MOB-06 Flutter approvals** — approval queue + decision UI against approvals API. Local analyze/test green (73 tests); push and wait for GitHub CI.

---

## Current branch

- Branch: `agent/T-MOB-06-approvals`
- Remote: `origin` → `https://github.com/albarami/expoapp.git`
- Base: T-MOB-05 green HEAD / CI https://github.com/albarami/expoapp/actions/runs/29040425846
- CI (T-MOB-06): **pending** after push
- PR: not created (`main` does not exist yet on remote)

---

## Current task

| Now | Next exact task |
|---|---|
| T-MOB-06 **in_progress** (local green) | Wait for CI green, then **T-MOB-07** Flutter audit |

---

## Completed this run (T-MOB-06)

1. Approvals queue with Pending/Completed segmented control, pull-to-refresh, risk/urgency chips
2. Approval detail with request summary, timeline, approve/reject bottom sheets
3. Reject requires comment; approve comment optional; EN/AR l10n
4. Role guards: manager/security/admin only on `/approvals` and `/approvals/:taskId`
5. Error mapping for `APPROVAL_TASK_NOT_PENDING`, `NOT_TASK_ASSIGNEE`, `FORBIDDEN`
6. ui-ux-pro-max applied (enterprise Material 3, 44px targets, loading/empty/error)
7. Local `flutter analyze` clean + 73 tests

---

## Exact next actions (in order)

### 1. Confirm T-MOB-06 CI green

```bash
cd /home/barami/projects/expoapp
# after push: watch Actions on agent/T-MOB-06-approvals
# update ledger CI URL + status=passed; then start T-MOB-07
```

### 2. Start T-MOB-07 (after CI green)

```bash
git checkout -B agent/T-MOB-07-audit origin/agent/T-MOB-06-approvals
# Implement audit logs viewer (filters, metadata modal, route guard)
# Use .cursor/skills/ui-ux-pro-max/
# Depends on T-API-10 (already passed)
cd apps/mobile && flutter analyze && flutter test
git push -u origin agent/T-MOB-07-audit
```

### 3. Sequential foundation only

Still prefer sequential mobile feature tasks until navigation + shared contracts feel stable per `08_PARALLEL_EXECUTION_PLAN.md`.

Remaining sequential mobile path: T-MOB-07; T-L10N-01 polish later.

---

## Ports reminder

See `PORTS.md`.

---

## Do not do next

- Do not spawn parallel feature agents until master prompt / parallel plan criteria are fully met
- Do not create Expo React Native apps
- Do not force-push `main`
- Do not require real Oracle credentials in Phase 1
