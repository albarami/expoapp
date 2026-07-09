# NEXT_RUN.md — Resume Point

**Updated:** 2026-07-09 (T-MOB-07 implementation complete — awaiting CI)  
**Read this file first on every new Cursor session.**

---

## Current phase

**T-MOB-07 Flutter audit** — implementation complete on `agent/T-MOB-07-audit`; wait for GitHub CI green, then mark passed and start **T-L10N-01**.

---

## Current branch

- Branch: `agent/T-MOB-07-audit`
- Remote: `origin` → `https://github.com/albarami/expoapp.git`
- Base: T-MOB-06 green HEAD / CI https://github.com/albarami/expoapp/actions/runs/29041340812
- CI (T-MOB-07): **pending** after push
- PR: not created (`main` does not exist yet on remote)

---

## Current task

| Now | Next exact task |
|---|---|
| T-MOB-07 **implemented** (local analyze/test green) | Confirm CI green → mark T-MOB-07 **passed** → start **T-L10N-01** |

---

## Completed this run (T-MOB-07)

1. Audit logs list against `GET /audit-logs` (Riverpod + Dio repository)
2. Filters: actor email search, action, entity type, from/to dates; clear filters
3. Pagination controls; pull-to-refresh; loading/empty/error states
4. Metadata detail modal (JSON, IP, user agent, entity id)
5. Route guard: SECURITY_ADMIN / SYSTEM_ADMIN only on `/audit`
6. EN/AR l10n strings; ui-ux-pro-max (Material 3, 44px targets, enterprise list)
7. Local `flutter analyze` clean + 81 tests

---

## Exact next actions (in order)

### 1. Confirm T-MOB-07 CI

```bash
cd /home/barami/projects/expoapp
gh run list --branch agent/T-MOB-07-audit --limit 3
# when green: update ledger Status to passed + CI URL; then T-L10N-01
```

### 2. Start T-L10N-01 (after CI green)

```bash
cd /home/barami/projects/expoapp
git checkout -B agent/T-L10N-01-polish origin/agent/T-MOB-07-audit
# Full string audit; RTL; error code mapping per ledger
# Use .cursor/skills/ui-ux-pro-max/
cd apps/mobile && flutter analyze && flutter test
git push -u origin agent/T-L10N-01-polish
```

### 3. Sequential foundation only

Still prefer sequential until L10N + QA path; remaining: T-L10N-01 → T-QA-01 → T-REL-01.

---

## Ports reminder

See `PORTS.md`.

---

## Do not do next

- Do not spawn parallel feature agents until master prompt / parallel plan criteria are fully met
- Do not create Expo React Native apps
- Do not force-push `main`
- Do not require real Oracle credentials in Phase 1
