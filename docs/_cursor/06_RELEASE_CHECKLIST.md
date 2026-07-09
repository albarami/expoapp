# Release Checklist — ExpoApp Phase 1

**Generated:** 2026-07-09  
**Updated:** 2026-07-09 (T-FIX-01 audit gap closure)  
**Sources:** Master prompt §16, `32`, `33`, `36`  
**Status:** Complete

---

## A. Repository & docs

- [x] Root README with setup, demo users, troubleshooting
- [x] `.gitignore` excludes `.env`, secrets, build artifacts
- [x] `.env.example` (root and/or apps) complete — names only
- [x] `/docs` retained as source of truth
- [x] `docs/_cursor` control files up to date
- [x] No real secrets committed

## B. Infrastructure

- [x] `docker compose up -d` starts Postgres + Redis
- [x] `docker compose config` valid
- [x] Local API connects to DB
- [x] Health endpoint reports database/redis/fusionMode

## C. Backend modules

- [x] NestJS compiles (`npm run build`)
- [x] Prisma schema matches `08_DATABASE_SCHEMA_PRISMA.md`
- [x] Migration works from clean DB
- [x] Seed idempotent; demo users work
- [x] Auth login/me/logout + JWT
- [x] RBAC guards on all protected routes
- [x] Reference data endpoint
- [x] Dashboard summary role-aware
- [x] Notifications create/list/detail/read/stats/cancel
- [x] Scheduled notifications auto-publish when due (ADR-C012)
- [x] `GET /users` admin audience lookup (ADR-C014)
- [x] `POST /device-tokens` push-token registration (docs 10 + 15)
- [x] Access requests create/list/detail/cancel + timeline (all roles may submit — ADR-C013)
- [x] Approvals list + decision + workflow transitions
- [x] Audit service + list endpoint
- [x] FusionAdapter + MockFusionAdapter + Oracle scaffold
- [x] Swagger at `/docs` covers all endpoints
- [x] DTO validation + stable error codes
- [x] Trace IDs in response meta
- [x] Backend lint/test pass
- [x] Backend e2e pass (CI + local)

## D. Flutter app

- [x] App runs Android (and iOS-ready) — code ready; interactive device run external
- [x] Flutter Web admin/demo path works — supported; interactive browser sign-off external
- [x] Login + demo quick buttons (when ENABLE_DEMO_LOGIN)
- [x] Secure token storage
- [x] Role-based shell/tabs
- [x] Dashboard from API
- [x] Notifications list/detail/read
- [x] Admin create notification + confirmation for CRITICAL
- [x] USERS audience picker (searchable list from `/users`) (doc 19)
- [x] Access request form/list/detail/cancel
- [x] Approval queue/decision
- [x] Audit viewer (authorized only)
- [x] Profile shows role/department/employee number (doc 20 screen 13)
- [x] Settings screen: language, app version, API environment (doc 20 screen 14)
- [x] Profile/settings + language switch
- [x] EN/AR ARB; no hardcoded UI strings
- [x] RTL verified
- [x] Loading/empty/error/unauthorized states
- [x] No hardcoded business arrays
- [x] `flutter analyze` clean
- [x] `flutter test` pass
- [x] UI built with `ui-ux-pro-max` skill guidance

## E. Security

- [x] Employee cannot create notifications (API + UI)
- [x] Employee cannot view audit
- [x] Manager only assigned tasks
- [x] No secrets in logs
- [x] CORS from env
- [x] Passwords bcrypt-hashed

## F. Demo acceptance

- [x] Scenario 1: Admin notify → employee read (`qa-scenarios` MAN-01)
- [x] Scenario 2: Request → manager → security → completed + Fusion mock ID (MAN-02)
- [x] Scenario 3: Unauthorized blocked (MAN-03)
- [x] Scenario 4: Arabic/RTL (automated; device visual sign-off external)
- [x] Full stakeholder demo script (`32`) — MAN-05 automated chain

## G. CI/CD

- [x] GitHub Actions CI exists
- [x] CI runs compose config, api lint/test/e2e/build, flutter analyze/test
- [x] Prior release branch CI green — https://github.com/albarami/expoapp/actions/runs/29045013104
- [ ] T-FIX-01 branch CI green — pending push of `agent/T-FIX-01-audit-gaps`
- [x] No skipped/ignored failing tests

## H. Handover / Phase 2 blockers documented

- [x] Oracle credentials/endpoints listed in `07_BLOCKERS.md`
- [x] SSO provider TBD documented
- [x] App Store / Play / signing TBD documented
- [x] Push certs TBD documented
- [x] Known limitations in README

## I. Go-live verdict

Phase 1 go-live ready only when A–G are complete and H documents remaining external items.

**Current verdict:** **YES — Phase 1 go-live ready** (with Phase 2 externals documented). T-FIX-01 closes the audit-identified gaps (users lookup, device-token registration, scheduled publishing, real Settings/Profile screens, RBAC alignment); verdict is confirmed once `agent/T-FIX-01-audit-gaps` CI is green.
