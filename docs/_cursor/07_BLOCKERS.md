# Blockers — ExpoApp

**Updated:** 2026-07-09 (T-REL-01 **passed**; Phase 1 delivery complete)  
**Rule:** Only true blockers. Product/engineering decisions are made and recorded in architecture docs — not listed here.

---

## Active blockers (Phase 1 delivery)

None. **Phase 1 delivery complete.** T-REL-01 **passed** (CI green: https://github.com/albarami/expoapp/actions/runs/29045013104). Remaining items below are Phase 2 externals only.

### B-003 — GitHub CI green gate (**cleared**)

**Type:** DevOps  
**Impact:** Was blocking T-API-01 until setup branch CI green  
**Detail:** CI green on `agent/T-ENV-01-setup-control` — https://github.com/albarami/expoapp/actions/runs/29025032699  
**Resolution:** Confirmed Actions success 2026-07-09  
**Status:** Cleared

T-QA-01 CI also green: https://github.com/albarami/expoapp/actions/runs/29044389419

T-REL-01 CI also green: https://github.com/albarami/expoapp/actions/runs/29045013104

---

## External / Phase 2 blockers (do not stop Phase 1)

| ID | Item | Needed for | Status |
|---|---|---|---|
| E-001 | Oracle Fusion base URL, OAuth, endpoints / OIC process | Real Fusion adapter | Waiting on client |
| E-002 | SSO/OIDC provider details | Production auth | Waiting on client |
| E-003 | Apple Developer + signing | iOS store | Waiting on client |
| E-004 | Google Play + signing | Android store | Waiting on client |
| E-005 | FCM/APNs credentials | Real push | Waiting on client |
| E-006 | Production hosting/DB/network allowlists | Production deploy | Waiting on client |
| E-007 | Official Expo Saudi brand assets | Final branding | Optional; use placeholder |
| E-008 | Interactive Android emulator / physical device sign-off (PL-01) | Store demo polish | Optional for Phase 1; automated API+widget coverage complete |
| E-009 | iOS Simulator / Xcode (PL-02) | iOS store demo | Host limitation on WSL/Linux; Flutter iOS-ready code retained |
| E-010 | Interactive Flutter Web browser sign-off (PL-03) | Stakeholder web demo | Optional; Flutter Web target supported |

These are documented per master prompt §16 — Phase 1 continues/completes without them.

---

## Documentation conflicts

| Conflict | Resolution |
|---|---|
| Repository named “expoapp” vs Expo React Native | **Flutter** stack per master prompt — do not create RN/Expo app |
| SECURITY_ADMIN optional notification create | Allow optional; SYSTEM_ADMIN is primary (`01_ARCHITECTURE_DECISIONS.md`) |
| Docs show Postgres `5432` / Redis `6379` | Local host remapped to **5433** / **6380** due to `uaid_os` containers — see `PORTS.md` |
| Doc 06 matrix "Submit own access request = Yes for all roles" vs `assertCanCreate` 403 for SYSTEM_ADMIN vs sysadmin tab bar lacking a Requests tab | Docs are internally inconsistent. Permission matrix + doc 10 endpoint table (`POST /access-requests` = authenticated) are authoritative for backend RBAC; the tab bar is a navigation choice only. **Resolved 2026-07-09 (T-FIX-01):** backend allows all roles to submit; sysadmin tab bar unchanged. See ADR-C013 |
| Scheduled notifications had no publisher (SCHEDULED rows were a dead end) vs docs 15/19/20 Phase 1 schedule workflow | **Resolved 2026-07-09 (T-FIX-01):** in-process scheduled publisher implemented (ADR-C012); scheduling is Phase 1 scope per docs |

No conflict currently blocks implementation.

---

## Cleared blockers

| ID | Cleared | Notes |
|---|---|---|
| B-001 | 2026-07-09 | Scaffold created: apps/api, apps/mobile, compose, README, env, CI |
| B-002 | 2026-07-09 | Toolchain verified; Flutter installed to `~/flutter` |

---

## How to add a blocker

1. Confirm it cannot be inferred or safely created
2. Add ID, impact, owner, status
3. Update `NEXT_RUN.md` if it changes resume order
4. Do **not** list ordinary incomplete tasks here — those belong in `03_TASK_LEDGER.md`
