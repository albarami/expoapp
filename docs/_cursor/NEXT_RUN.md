# NEXT_RUN.md — Resume Point

**Updated:** 2026-07-09 (T-FIX-01 audit gap closure)  
**Read this file first on every new Cursor session.**

---

## Current phase

**Phase 1 complete + audit gaps closed (T-FIX-01).** The independent audit found real gaps vs documented Phase 1 deliverables; T-FIX-01 fixes them: `GET /users` + Flutter USERS audience picker, `POST /device-tokens`, scheduled-notification publisher, real Settings screen, Profile (role/department/employee number), and the SYSTEM_ADMIN access-request RBAC alignment. Remaining work is **Phase 2 externals only** (Oracle, SSO, push, store signing, production hosting) — see `07_BLOCKERS.md`.

---

## Current branch

- Branch: `agent/T-FIX-01-audit-gaps` (from `agent/T-REL-01-release` HEAD)
- Remote: `origin` → `https://github.com/albarami/expoapp.git`
- CI (T-FIX-01): pending push (see below)
- Local validation: API lint/build clean; API unit 88 + e2e 58 passing; `flutter analyze` clean; `flutter test` 99 passing
- `main`: create from final green HEAD once T-FIX-01 CI is green

---

## Current task

| Now | Next exact task |
|---|---|
| T-FIX-01 pushed; awaiting/confirming CI green | Create `main` from green HEAD; then Phase 2 externals only |

---

## Exact next actions (in order)

### 1. Confirm T-FIX-01 CI green + create `main`

Push `agent/T-FIX-01-audit-gaps`, wait for GitHub CI green, then create `main` from that HEAD (no force-push). Update this file and `06_RELEASE_CHECKLIST.md` with the run URL.

### 2. Phase 1 closed

All Phase 1 feature work through T-FIX-01 is complete. Do not open new Phase 1 feature work unless a regression is found.

### 3. Phase 2 externals

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
