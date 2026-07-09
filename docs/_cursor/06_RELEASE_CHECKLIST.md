# Release Checklist — ExpoApp Phase 1

**Generated:** 2026-07-09  
**Updated:** 2026-07-09 (T-QA-01)  
**Sources:** Master prompt §16, `32`, `33`, `36`  
**Status:** Nearly complete — finish T-REL-01 handover packaging after T-QA-01 CI green

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
- [x] Access requests create/list/detail/cancel + timeline
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
- [x] Access request form/list/detail/cancel
- [x] Approval queue/decision
- [x] Audit viewer (authorized only)
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
- [ ] Main/setup branch CI green — awaiting T-QA-01 push
- [x] No skipped/ignored failing tests

## H. Handover / Phase 2 blockers documented

- [x] Oracle credentials/endpoints listed in `07_BLOCKERS.md`
- [x] SSO provider TBD documented
- [x] App Store / Play / signing TBD documented
- [x] Push certs TBD documented
- [ ] Known limitations in README — finalize in T-REL-01

## I. Go-live verdict

Phase 1 go-live ready only when A–G are complete and H documents remaining external items.

**Current verdict:** PENDING CI — Phase 1 functionally complete pending green T-QA-01 CI and T-REL-01 README/handover polish. Device/store/Oracle remain Phase 2 externals.
