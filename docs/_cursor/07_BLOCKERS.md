# Blockers — ExpoApp

**Updated:** 2026-07-09 (setup run)  
**Rule:** Only true blockers. Product/engineering decisions are made and recorded in architecture docs — not listed here.

---

## Active blockers (Phase 1 delivery)

### B-003 — GitHub CI green gate (in progress)

**Type:** DevOps  
**Impact:** Cannot start T-API-01 until setup branch CI is green  
**Detail:** CI workflow created; push/monitor on `agent/T-ENV-01-setup-control`  
**Resolution:** Wait for Actions green; fix/push if red  
**Status:** Open until CI green confirmed

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

These are documented per master prompt §16 — continue Phase 1 without them.

---

## Documentation conflicts

| Conflict | Resolution |
|---|---|
| Repository named “expoapp” vs Expo React Native | **Flutter** stack per master prompt — do not create RN/Expo app |
| SECURITY_ADMIN optional notification create | Allow optional; SYSTEM_ADMIN is primary (`01_ARCHITECTURE_DECISIONS.md`) |
| Docs show Postgres `5432` / Redis `6379` | Local host remapped to **5433** / **6380** due to `uaid_os` containers — see `PORTS.md` |

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
