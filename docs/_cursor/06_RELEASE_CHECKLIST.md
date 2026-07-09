# Release Checklist — ExpoApp Phase 1

**Generated:** 2026-07-09  
**Sources:** Master prompt §16, `32`, `33`, `36`  
**Status:** Not started — update checkboxes as work completes

---

## A. Repository & docs

- [ ] Root README with setup, demo users, troubleshooting
- [ ] `.gitignore` excludes `.env`, secrets, build artifacts
- [ ] `.env.example` (root and/or apps) complete — names only
- [ ] `/docs` retained as source of truth
- [ ] `docs/_cursor` control files up to date
- [ ] No real secrets committed

## B. Infrastructure

- [ ] `docker compose up -d` starts Postgres + Redis
- [ ] `docker compose config` valid
- [ ] Local API connects to DB
- [ ] Health endpoint reports database/redis/fusionMode

## C. Backend modules

- [ ] NestJS compiles (`npm run build`)
- [ ] Prisma schema matches `08_DATABASE_SCHEMA_PRISMA.md`
- [ ] Migration works from clean DB
- [ ] Seed idempotent; demo users work
- [ ] Auth login/me/logout + JWT
- [ ] RBAC guards on all protected routes
- [ ] Reference data endpoint
- [ ] Dashboard summary role-aware
- [ ] Notifications create/list/detail/read/stats/cancel
- [ ] Access requests create/list/detail/cancel + timeline
- [ ] Approvals list + decision + workflow transitions
- [ ] Audit service + list endpoint
- [ ] FusionAdapter + MockFusionAdapter + Oracle scaffold
- [ ] Swagger at `/docs` covers all endpoints
- [ ] DTO validation + stable error codes
- [ ] Trace IDs in response meta
- [ ] Backend lint/test pass

## D. Flutter app

- [ ] App runs Android (and iOS-ready)
- [ ] Flutter Web admin/demo path works
- [ ] Login + demo quick buttons (when ENABLE_DEMO_LOGIN)
- [ ] Secure token storage
- [ ] Role-based shell/tabs
- [ ] Dashboard from API
- [ ] Notifications list/detail/read
- [ ] Admin create notification + confirmation for CRITICAL
- [ ] Access request form/list/detail/cancel
- [ ] Approval queue/decision
- [ ] Audit viewer (authorized only)
- [ ] Profile/settings + language switch
- [x] EN/AR ARB; no hardcoded UI strings
- [x] RTL verified
- [ ] Loading/empty/error/unauthorized states
- [ ] No hardcoded business arrays
- [ ] `flutter analyze` clean
- [ ] `flutter test` pass
- [ ] UI built with `ui-ux-pro-max` skill guidance

## E. Security

- [ ] Employee cannot create notifications (API + UI)
- [ ] Employee cannot view audit
- [ ] Manager only assigned tasks
- [ ] No secrets in logs
- [ ] CORS from env
- [ ] Passwords bcrypt-hashed

## F. Demo acceptance

- [ ] Scenario 1: Admin notify → employee read
- [ ] Scenario 2: Request → manager → security → completed + Fusion mock ID
- [ ] Scenario 3: Unauthorized blocked
- [x] Scenario 4: Arabic/RTL (automated; device sign-off in T-QA-01)
- [ ] Full stakeholder demo script (`32`)

## G. CI/CD

- [ ] GitHub Actions CI exists
- [ ] CI runs compose config, api lint/test/build, flutter analyze/test
- [ ] Main/setup branch CI green
- [ ] No skipped/ignored failing tests

## H. Handover / Phase 2 blockers documented

- [ ] Oracle credentials/endpoints listed in `07_BLOCKERS.md`
- [ ] SSO provider TBD documented
- [ ] App Store / Play / signing TBD documented
- [ ] Push certs TBD documented
- [ ] Known limitations in README

## I. Go-live verdict

Phase 1 go-live ready only when A–G are complete and H documents remaining external items.

**Current verdict:** NOT READY — greenfield; control system only.
