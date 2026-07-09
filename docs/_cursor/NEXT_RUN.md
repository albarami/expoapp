# NEXT_RUN.md — Resume Point

**Updated:** 2026-07-09 (T-QA-01 local PASS — push + await CI)  
**Read this file first on every new Cursor session.**

---

## Current phase

**T-QA-01 Automated + manual QA** — local validation **PASS**. Push `agent/T-QA-01-qa` and wait for GitHub CI green, then mark passed and start **T-REL-01**.

---

## Current branch

- Branch: `agent/T-QA-01-qa`
- Base: `origin/agent/T-L10N-01-polish` (CI green: https://github.com/albarami/expoapp/actions/runs/29043070135)
- Remote: `origin` → `https://github.com/albarami/expoapp.git`
- CI (T-QA-01): pending first push
- PR: not created (`main` does not exist yet on remote)

---

## Current task

| Now | Next exact task |
|---|---|
| T-QA-01 local **PASS** | Push + green CI → mark **passed** → **T-REL-01** |

---

## Exact next actions (in order)

### 1. Finish T-QA-01 CI gate

```bash
cd /home/barami/projects/expoapp
git push -u origin agent/T-QA-01-qa
# Wait for Actions green; fix until green
# Then update ledger status to passed + CI URL
```

### 2. Start T-REL-01

```bash
git checkout -B agent/T-REL-01-release origin/agent/T-QA-01-qa
# Finalize README known limitations, release checklist verdict, handover docs
# Phase 1 go-live YES when checklist A–G complete
```

### 3. Sequential path remaining

T-QA-01 (CI) → T-REL-01.

---

## Ports reminder

See `PORTS.md`.

---

## Do not do next

- Do not spawn parallel feature agents until master prompt / parallel plan criteria are fully met
- Do not create Expo React Native apps
- Do not force-push `main`
- Do not require real Oracle credentials in Phase 1
