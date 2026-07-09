# NEXT_RUN.md — Resume Point

**Updated:** 2026-07-09 (T-L10N-01 local green — CI pending)  
**Read this file first on every new Cursor session.**

---

## Current phase

**T-L10N-01 Localization & RTL polish** — **passed locally** on `agent/T-L10N-01-polish`. Next: **T-QA-01**.

CI: pending after push — update URL when green.

---

## Current branch

- Branch: `agent/T-L10N-01-polish`
- Remote: `origin` → `https://github.com/albarami/expoapp.git`
- CI (T-L10N-01): **pending**
- PR: not created (`main` does not exist yet on remote)

---

## Current task

| Now | Next exact task |
|---|---|
| T-L10N-01 **passed** (local; CI pending) | Start **T-QA-01** Automated + manual QA |

---

## Exact next actions (in order)

### 1. Confirm T-L10N-01 CI green

```bash
gh run list --branch agent/T-L10N-01-polish --limit 3
# gh run watch <id> --exit-status
# Then mark ledger CI URL and Status passed with green CI
```

### 2. Start T-QA-01

```bash
cd /home/barami/projects/expoapp
git checkout -B agent/T-QA-01-qa origin/agent/T-L10N-01-polish
# Complete test matrix + demo scenarios per ledger / 04_TEST_MATRIX.md
git push -u origin agent/T-QA-01-qa
```

### 3. Sequential path remaining

T-QA-01 → T-REL-01.

---

## Ports reminder

See `PORTS.md`.

---

## Do not do next

- Do not spawn parallel feature agents until master prompt / parallel plan criteria are fully met
- Do not create Expo React Native apps
- Do not force-push `main`
- Do not require real Oracle credentials in Phase 1
