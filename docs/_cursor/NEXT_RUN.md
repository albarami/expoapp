# NEXT_RUN.md — Resume Point

**Updated:** 2026-07-09 (T-REL-01 **passed**; Phase 1 complete)  
**Read this file first on every new Cursor session.**

---

## Current phase

**Phase 1 complete.** T-REL-01 **passed** (CI green: https://github.com/albarami/expoapp/actions/runs/29045013104).  
No further Phase 1 autonomous build tasks. Remaining work is **Phase 2 externals only** (Oracle, SSO, push, store signing, production hosting) — see `07_BLOCKERS.md`.

---

## Current branch

- Branch: `agent/T-REL-01-release`
- Remote: `origin` → `https://github.com/albarami/expoapp.git`
- CI (T-REL-01): **green** — https://github.com/albarami/expoapp/actions/runs/29045013104
- PR: not created (`main` does not exist yet on remote)

---

## Current task

| Now | Next exact task |
|---|---|
| Phase 1 **complete** | Phase 2 externals only (client-provided) |

---

## Exact next actions (in order)

### 1. Phase 1 closed

All Phase 1 tasks through T-REL-01 are **passed**. Do not open new Phase 1 feature work unless a regression is found.

### 2. Phase 2 externals

Track and unblock items in `07_BLOCKERS.md` (E-001..E-010): Oracle Fusion, SSO/OIDC, store signing, FCM/APNs, production hosting, optional device/web sign-off.

---

## Ports reminder

See `PORTS.md`.

---

## Do not do next

- Do not spawn parallel feature agents until master prompt / parallel plan criteria are fully met
- Do not create Expo React Native apps
- Do not force-push `main`
- Do not require real Oracle credentials in Phase 1
