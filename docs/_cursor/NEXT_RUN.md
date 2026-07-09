# NEXT_RUN.md — Resume Point

**Updated:** 2026-07-09 (T-REL-01 in progress)  
**Read this file first on every new Cursor session.**

---

## Current phase

**T-REL-01 Release readiness** — **in_progress** on `agent/T-REL-01-release`.  
T-QA-01 **passed** (CI green: https://github.com/albarami/expoapp/actions/runs/29044389419).

After T-REL-01 is pushed and CI green: **Phase 1 complete**. No further Phase 1 tasks; remaining work is Phase 2 externals only (Oracle, SSO, push, store signing, production hosting).

---

## Current branch

- Branch: `agent/T-REL-01-release`
- Base: `origin/agent/T-QA-01-qa` (CI green: https://github.com/albarami/expoapp/actions/runs/29044389419)
- Remote: `origin` → `https://github.com/albarami/expoapp.git`
- CI (T-REL-01): pending push
- PR: not created (`main` does not exist yet on remote)

---

## Current task

| Now | Next exact task |
|---|---|
| T-REL-01 **in_progress** | Finalize docs → push → green CI → mark **passed** → Phase 1 complete |

---

## Exact next actions (in order)

### 1. Finish T-REL-01 packaging (this branch)

- README known limitations + migrate/seed/e2e commands
- Release checklist verdict YES
- Handover + definition-of-done checkboxes for Phase 1
- Blockers: Phase 2 externals only

### 2. Push and CI gate

```bash
cd /home/barami/projects/expoapp
git push -u origin agent/T-REL-01-release
# Wait for Actions green; then mark T-REL-01 passed + REL-01 complete
```

### 3. After T-REL-01

Phase 1 complete. No further Phase 1 tasks. Phase 2 externals only — see `07_BLOCKERS.md`.

---

## Ports reminder

See `PORTS.md`.

---

## Do not do next

- Do not spawn parallel feature agents until master prompt / parallel plan criteria are fully met
- Do not create Expo React Native apps
- Do not force-push `main`
- Do not require real Oracle credentials in Phase 1
