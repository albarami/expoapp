# NEXT_RUN.md — Resume Point

**Updated:** 2026-07-09 (T-MOB-07 passed — CI green)  
**Read this file first on every new Cursor session.**

---

## Current phase

**T-MOB-07 Flutter audit** — **passed** on `agent/T-MOB-07-audit`. Next: **T-L10N-01**.

CI: https://github.com/albarami/expoapp/actions/runs/29042259598

---

## Current branch

- Branch: `agent/T-MOB-07-audit`
- Remote: `origin` → `https://github.com/albarami/expoapp.git`
- CI (T-MOB-07): **green** — https://github.com/albarami/expoapp/actions/runs/29042259598
- PR: not created (`main` does not exist yet on remote)

---

## Current task

| Now | Next exact task |
|---|---|
| T-MOB-07 **passed** | Start **T-L10N-01** Localization & RTL polish |

---

## Exact next actions (in order)

### 1. Start T-L10N-01

```bash
cd /home/barami/projects/expoapp
git checkout -B agent/T-L10N-01-polish origin/agent/T-MOB-07-audit
# Full string audit; RTL; error code mapping per ledger
# Use .cursor/skills/ui-ux-pro-max/
cd apps/mobile && flutter analyze && flutter test
git push -u origin agent/T-L10N-01-polish
```

### 2. Sequential foundation only

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
