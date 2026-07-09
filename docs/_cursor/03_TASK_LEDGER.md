# Task Ledger — ExpoApp

**Generated:** 2026-07-09  
**Update rule:** Every run updates status, CI, branch/PR fields. Never mark complete if CI is red/skipped/missing/unknown.

**Status values:** `pending` | `in_progress` | `blocked` | `failed` | `passed` | `merged`

---

## Dependency graph (summary)

```text
T-DOC-01
  -> T-ENV-01 -> T-ENV-02 -> T-CI-01 -> T-ENV-03 (first validation + push + green CI)
    -> T-API-01 -> T-API-02 -> T-API-03 -> T-API-04 -> T-API-05
         -> T-API-09 (fusion) ─┐
         -> T-API-10 (audit)  ─┼-> T-API-06 (notifications)
                               └-> T-API-07 (access) -> T-API-08 (approvals)
    -> T-MOB-01 -> T-MOB-02 -> T-MOB-03
         -> T-MOB-04 (needs T-API-06)
         -> T-MOB-05 (needs T-API-07)
         -> T-MOB-06 (needs T-API-08)
         -> T-MOB-07 (needs T-API-10)
    -> T-L10N-01, T-QA-01, T-REL-01
```

---

## T-DOC-01 — Documentation intake & control system

| Field | Value |
|---|---|
| Title | Read all docs; create docs/_cursor control files |
| Description | Recursively read `/docs`, inspect skills/rules/repo; write all 10 control files; encode dependency graph |
| Source | `01_MASTER_CURSOR_PROMPT.md` §§1,7,19 |
| Dependencies | None |
| Files | `docs/_cursor/*` |
| Acceptance | All 10 control files exist and are substantive; understanding matches docs |
| Local tests | N/A (docs only) |
| GitHub CI | N/A this task |
| Branch/PR | Uncommitted on workspace (no feature branch push required until T-ENV-03) |
| Status | **passed** (this run) |

---

## T-ENV-01 — Detect & repair toolchain

| Field | Value |
|---|---|
| Title | Verify Node/npm/Flutter/Docker on WSL; install/fix |
| Description | Record versions in `05_ENVIRONMENT_SETUP.md`; fix PATH/install gaps |
| Source | Master §8; `05_ENVIRONMENTS_AND_CONFIG.md` |
| Dependencies | T-DOC-01 |
| Files | `docs/_cursor/05_ENVIRONMENT_SETUP.md`, `07_BLOCKERS.md` |
| Acceptance | `node`, `npm`, `flutter doctor`, `docker compose` usable |
| Local tests | Version commands succeed |
| GitHub CI | N/A (env only) |
| Branch/PR | `agent/T-ENV-01-setup-control` |
| Status | **passed** |

---

## T-ENV-02 — Scaffold repo structure

| Field | Value |
|---|---|
| Title | Create apps/api, apps/mobile, docker-compose, env examples, gitignore, README stub |
| Description | NestJS + Flutter minimal apps with lint/test/build/analyze scripts; compose Postgres+Redis |
| Source | `04_REPOSITORY_STRUCTURE.md`, `05`, `31` Task 1 |
| Dependencies | T-ENV-01 |
| Files | `apps/**`, `docker-compose.yml`, `.env.example`, `.gitignore`, `README.md` |
| Acceptance | Folders exist; `npm run lint/test/build` and `flutter analyze/test` runnable |
| Local tests | See acceptance |
| GitHub CI | pending push |
| Branch/PR | `agent/T-ENV-01-setup-control` |
| Status | **passed** |

---

## T-CI-01 — GitHub Actions CI

| Field | Value |
|---|---|
| Title | Create CI workflow |
| Description | Workflow: compose config, api ci/lint/test/build, flutter pub get/analyze/test; fail on error |
| Source | Master §9; `29_CI_CD_DEPLOYMENT.md` |
| Dependencies | T-ENV-02 |
| Files | `.github/workflows/ci.yml` |
| Acceptance | Workflow file present; jobs match local commands |
| Local tests | `actionlint` optional; validate YAML |
| GitHub CI | pending first run after push |
| Branch/PR | `agent/T-ENV-01-setup-control` |
| Status | **passed** (workflow created; green gate = T-ENV-03) |

---

## T-ENV-03 — First local validation + push + green CI

| Field | Value |
|---|---|
| Title | Run local validation; push setup branch; wait for green CI |
| Description | Align local/CI; fix failures; do not start feature implementation until green |
| Source | Master §19 steps 13–15 |
| Dependencies | T-CI-01 |
| Files | setup fixes as needed |
| Acceptance | Local validation pass; GitHub CI green on setup branch |
| Local tests | compose config; api lint/test/build; flutter analyze/test — **local PASS 2026-07-09** |
| GitHub CI | **success** — https://github.com/albarami/expoapp/actions/runs/29025032699 |
| Branch/PR | `agent/T-ENV-01-setup-control` (PR skipped: remote `main` missing) |
| Status | **passed** |

---

## T-API-01 — NestJS backend foundation

| Field | Value |
|---|---|
| Title | Config, validation pipe, exception filter, trace ID, Swagger, Helmet, Health |
| Source | `11_BACKEND_NESTJS_SPEC.md` |
| Dependencies | T-ENV-03 |
| Files | `apps/api/src/main.ts`, `app.module.ts`, `common/**`, `health/**`, `config/**` |
| Acceptance | `/health` works; Swagger loads; envelope/errors consistent |
| Local tests | `npm run lint/test/test:e2e/build`; manual `/health` + `/docs` — **PASS 2026-07-09** |
| GitHub CI | **green** — https://github.com/albarami/expoapp/actions/runs/29025984791 |
| Branch/PR | `agent/T-API-01-nest-foundation` |
| Status | **passed** |

---

## T-API-02 — Prisma schema + migration

| Field | Value |
|---|---|
| Title | Implement full schema; migrate init |
| Source | `07_DATA_MODEL.md`, `08_DATABASE_SCHEMA_PRISMA.md` |
| Dependencies | T-API-01 |
| Files | `apps/api/prisma/schema.prisma`, `prisma/migrations/*`, schema/migrate tests, CI migrate deploy |
| Acceptance | `prisma migrate dev` on clean DB succeeds; client generates |
| Local tests | migrate + generate + schema/smoke tests — **PASS 2026-07-09** |
| GitHub CI | **green** — https://github.com/albarami/expoapp/actions/runs/29026568179 |
| Branch/PR | `agent/T-API-02-prisma-schema` |
| Status | **passed** |

---

## T-API-03 — Auth + RBAC

| Field | Value |
|---|---|
| Title | Login, JWT, me, logout, guards, roles, permissions |
| Source | `14_AUTH_AND_RBAC.md`, `10_API_CONTRACT.md` |
| Dependencies | T-API-02 |
| Files | `apps/api/src/auth/**`, users as needed |
| Acceptance | Demo logins work after seed; guards enforce roles |
| Local tests | BU-01, BI-02, BI-03 |
| GitHub CI | green |
| Status | **pending** |

---

## T-API-04 — Seed data (core + full)

| Field | Value |
|---|---|
| Title | Idempotent seed per 09_SEED_DATA |
| Source | `09_SEED_DATA.md` |
| Dependencies | T-API-02 (expand after modules as needed) |
| Files | `apps/api/prisma/seed.ts` |
| Acceptance | All demo users/depts/systems/roles/notifications/requests/audit; second run safe |
| Local tests | `npm run seed` ×2 |
| GitHub CI | green |
| Status | **pending** |

---

## T-API-05 — Reference data + dashboard

| Field | Value |
|---|---|
| Title | GET /reference-data, GET /dashboard/summary |
| Source | `10_API_CONTRACT.md` |
| Dependencies | T-API-03, T-API-04 |
| Files | `reference-data/**`, `dashboard/**` |
| Acceptance | Role-aware dashboard; reference payload complete |
| Local tests | API tests |
| GitHub CI | green |
| Status | **pending** |

---

## T-API-06 — Notifications module

| Field | Value |
|---|---|
| Title | Full notifications API + audience + audit |
| Source | `15_NOTIFICATIONS_MODULE.md`, `10` |
| Dependencies | T-API-05; prefer T-API-10 audit helper |
| Files | `notifications/**` |
| Acceptance | Create/publish/list/read/stats/cancel; recipients; tests |
| Local tests | BU-02, BI-04 |
| GitHub CI | green |
| Status | **pending** |

---

## T-API-07 — Access requests module

| Field | Value |
|---|---|
| Title | Submit/list/detail/cancel + events + numbering |
| Source | `16_ACCESS_REQUESTS_WORKFLOW.md` |
| Dependencies | T-API-05, T-API-09, T-API-10 |
| Files | `access-requests/**` |
| Acceptance | Workflow start states; validation codes; timeline |
| Local tests | BI-05 |
| GitHub CI | green |
| Status | **pending** |

---

## T-API-08 — Approvals + mock provisioning

| Field | Value |
|---|---|
| Title | Approval engine + Fusion mock complete path |
| Source | `17_APPROVAL_ENGINE.md` |
| Dependencies | T-API-07, T-API-09 |
| Files | `approvals/**` |
| Acceptance | Manager/security decisions; transactional; mock complete |
| Local tests | BU-04, BI-06 |
| GitHub CI | green |
| Status | **pending** |

---

## T-API-09 — Fusion adapter

| Field | Value |
|---|---|
| Title | Interface + Mock + Oracle scaffold + provider |
| Source | `23_ORACLE_FUSION_ADAPTER.md`, `24` |
| Dependencies | T-API-01 |
| Files | `fusion/**` |
| Acceptance | Mock works; oracle throws clear config error; no controller coupling |
| Local tests | FUS-01..03 |
| GitHub CI | green |
| Status | **pending** |

---

## T-API-10 — Audit module

| Field | Value |
|---|---|
| Title | AuditService + GET /audit-logs |
| Source | `18_AUDIT_LOGGING.md` |
| Dependencies | T-API-03 |
| Files | `audit/**` |
| Acceptance | Record helper; admin-only list/filters; immutability |
| Local tests | AUD-*, BI-07 |
| GitHub CI | green |
| Status | **pending** |

---

## T-MOB-01 — Flutter foundation

| Field | Value |
|---|---|
| Title | App structure, theme, l10n, GoRouter stub, Dio, secure storage, shared widgets |
| Source | `12_FLUTTER_ARCHITECTURE.md`, `21`, `22` |
| Dependencies | T-ENV-03 |
| Files | `apps/mobile/lib/**` |
| Acceptance | App starts; analyze clean; Material 3 tokens; ARB wired |
| Skills | **ui-ux-pro-max** (+ flutter.csv) for widgets/theme |
| Local tests | `flutter analyze`, `flutter test` |
| GitHub CI | green |
| Status | **pending** |

---

## T-MOB-02 — Flutter auth + session + role shell

| Field | Value |
|---|---|
| Title | Login, demo buttons, token session, role tabs |
| Source | `14`, `13`, `20` screens 1–2 |
| Dependencies | T-MOB-01, T-API-03 |
| Files | `features/auth/**`, `app/router.dart` |
| Acceptance | All demo users login; tabs by role; 401 → login |
| Skills | ui-ux-pro-max |
| GitHub CI | green |
| Status | **pending** |

---

## T-MOB-03 — Flutter dashboard

| Field | Value |
|---|---|
| Title | Role-based dashboard from API |
| Source | `20` screen 3; `19` admin home |
| Dependencies | T-MOB-02, T-API-05 |
| Files | `features/dashboard/**` |
| Acceptance | Metrics/latest items; loading/error |
| Skills | ui-ux-pro-max |
| GitHub CI | green |
| Status | **pending** |

---

## T-MOB-04 — Flutter notifications (+ admin)

| Field | Value |
|---|---|
| Title | List/detail/read/create/stats |
| Source | `15`, `19`, `20` screens 4–6 |
| Dependencies | T-MOB-02, T-API-06 |
| Files | `features/notifications/**`, `features/admin/**` |
| Acceptance | E2E with seed/API; employee cannot open create |
| Skills | ui-ux-pro-max |
| GitHub CI | green |
| Status | **pending** |

---

## T-MOB-05 — Flutter access requests

| Field | Value |
|---|---|
| Title | My requests, form, detail/timeline, cancel |
| Source | `16`, `20` screens 7–9 |
| Dependencies | T-MOB-02, T-API-07 |
| Files | `features/access_requests/**` |
| Acceptance | Submit returns request number; timeline; validation |
| Skills | ui-ux-pro-max |
| GitHub CI | green |
| Status | **pending** |

---

## T-MOB-06 — Flutter approvals

| Field | Value |
|---|---|
| Title | Queue + decision UI |
| Source | `17`, `20` screens 10–11 |
| Dependencies | T-MOB-02, T-API-08 |
| Files | `features/approvals/**` |
| Acceptance | Approve/reject with confirm; refresh |
| Skills | ui-ux-pro-max |
| GitHub CI | green |
| Status | **pending** |

---

## T-MOB-07 — Flutter audit

| Field | Value |
|---|---|
| Title | Audit logs viewer |
| Source | `18`, `20` screen 12 |
| Dependencies | T-MOB-02, T-API-10 |
| Files | `features/audit/**` |
| Acceptance | Filters; metadata modal; route guard |
| Skills | ui-ux-pro-max |
| GitHub CI | green |
| Status | **pending** |

---

## T-L10N-01 — Localization & RTL polish

| Field | Value |
|---|---|
| Title | Full string audit; RTL; error code mapping |
| Source | `22`, `27` |
| Dependencies | T-MOB-03..07 |
| Files | `l10n/*.arb`, feature UIs |
| Acceptance | No hardcoded UI strings; Scenario 4 pass |
| GitHub CI | green |
| Status | **pending** |

---

## T-QA-01 — Automated + manual QA

| Field | Value |
|---|---|
| Title | Complete test matrix + demo scenarios |
| Source | `28`, `32`, `04_TEST_MATRIX.md` |
| Dependencies | Feature tasks merged |
| Files | `apps/api/test/**`, `apps/mobile/test/**` |
| Acceptance | Matrix statuses updated; MAN-01..05 pass |
| GitHub CI | green |
| Status | **pending** |

---

## T-REL-01 — Release readiness

| Field | Value |
|---|---|
| Title | README final; release checklist; handover; blockers for Phase 2 |
| Source | `33`, `36`, `06_RELEASE_CHECKLIST.md` |
| Dependencies | T-QA-01 |
| Files | `README.md`, `docs/_cursor/*` |
| Acceptance | Checklist complete; Phase 1 go-live verdict YES |
| GitHub CI | green on main |
| Status | **pending** |

---

## Priority queue (next actions)

1. ~~T-ENV-01~~ **passed**
2. ~~T-ENV-02~~ **passed**
3. ~~T-CI-01~~ **passed** (workflow exists)
4. ~~T-ENV-03~~ **passed** (CI green: run 29025032699)
5. ~~T-API-01~~ **passed** (CI green: run 29025984791)
6. ~~T-API-02~~ **passed** (CI green: run 29026568179)
7. **T-API-03** — Auth + RBAC (next)

**Resume at T-API-03.**
