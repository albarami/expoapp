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
| GitHub CI | **green** — https://github.com/albarami/expoapp/actions/runs/29030021235 |
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
| Files | `apps/api/src/auth/**`, `apps/api/prisma/seed.ts` (auth-ready depts/users), RBAC probe routes |
| Acceptance | Demo logins work after seed; guards enforce roles |
| Local tests | BU-01, BI-02, BI-03 — **PASS 2026-07-09** |
| GitHub CI | **green** — https://github.com/albarami/expoapp/actions/runs/29028053503 |
| Branch/PR | `agent/T-API-03-auth-rbac` |
| Status | **passed** |

---

## T-API-04 — Seed data (core + full)

| Field | Value |
|---|---|
| Title | Idempotent seed per 09_SEED_DATA |
| Source | `09_SEED_DATA.md` |
| Dependencies | T-API-02 (expand after modules as needed) |
| Files | `apps/api/prisma/seed.ts`, `apps/api/src/prisma/seed.idempotency.spec.ts` |
| Acceptance | All demo users/depts/systems/roles/notifications/requests/audit; second run safe |
| Local tests | `npm run seed` ×2 + BI-08 — **PASS 2026-07-09** (5 depts, 5 users, 5 systems, 9 roles, 6 notifs, 4 requests, 5 approval tasks, 11 events, 25 seed audit logs) |
| GitHub CI | **green** — https://github.com/albarami/expoapp/actions/runs/29028738943 |
| Branch/PR | `agent/T-API-04-seed-data` |
| Status | **passed** |

---

## T-API-05 — Reference data + dashboard

| Field | Value |
|---|---|
| Title | GET /reference-data, GET /dashboard/summary |
| Source | `10_API_CONTRACT.md` |
| Dependencies | T-API-03, T-API-04 |
| Files | `apps/api/src/reference-data/**`, `apps/api/src/dashboard/**`, `apps/api/test/reference-dashboard.e2e-spec.ts` |
| Acceptance | Role-aware dashboard; reference payload complete |
| Local tests | unit + e2e — **PASS 2026-07-09** |
| GitHub CI | **green** — https://github.com/albarami/expoapp/actions/runs/29030021235 |
| Branch/PR | `agent/T-API-05-reference-dashboard` |
| Status | **passed** |

---

## T-API-06 — Notifications module

| Field | Value |
|---|---|
| Title | Full notifications API + audience + audit |
| Source | `15_NOTIFICATIONS_MODULE.md`, `10` |
| Dependencies | T-API-05; prefer T-API-10 audit helper |
| Files | `notifications/**`, `audit/**` (record helper), RBAC probe trim |
| Acceptance | Create/publish/list/read/stats/cancel; recipients; tests |
| Local tests | BU-02, BI-04 — **PASS 2026-07-09** |
| GitHub CI | **green** — https://github.com/albarami/expoapp/actions/runs/29032026526 |
| Branch/PR | `agent/T-API-06-notifications` |
| Status | **passed** |

---

## T-API-07 — Access requests module

| Field | Value |
|---|---|
| Title | Submit/list/detail/cancel + events + numbering |
| Source | `16_ACCESS_REQUESTS_WORKFLOW.md` |
| Dependencies | T-API-05, T-API-09, T-API-10 |
| Files | `access-requests/**` |
| Acceptance | Workflow start states; validation codes; timeline |
| Local tests | BU-03, BU-07, BI-05 — **PASS 2026-07-09** |
| GitHub CI | **green** — https://github.com/albarami/expoapp/actions/runs/29035039147 |
| Branch/PR | `agent/T-API-07-access-requests` |
| Status | **passed** |

---

## T-API-08 — Approvals + mock provisioning

| Field | Value |
|---|---|
| Title | Approval engine + Fusion mock complete path |
| Source | `17_APPROVAL_ENGINE.md` |
| Dependencies | T-API-07, T-API-09 |
| Files | `approvals/**` |
| Acceptance | Manager/security decisions; transactional; mock complete |
| Local tests | BU-04, BI-06 — **PASS 2026-07-09** |
| GitHub CI | **green** — https://github.com/albarami/expoapp/actions/runs/29036247670 |
| Branch/PR | `agent/T-API-08-approvals` |
| Status | **passed** |

---

## T-API-09 — Fusion adapter

| Field | Value |
|---|---|
| Title | Interface + Mock + Oracle scaffold + provider |
| Source | `23_ORACLE_FUSION_ADAPTER.md`, `24` |
| Dependencies | T-API-01 |
| Files | `fusion/**` |
| Acceptance | Mock works; oracle throws clear config error; no controller coupling |
| Local tests | FUS-01..03, BU-06 (unit + e2e) |
| GitHub CI | green — https://github.com/albarami/expoapp/actions/runs/29032814249 |
| Branch/PR | `agent/T-API-09-fusion-adapter` |
| Status | **passed** |

---

## T-API-10 — Audit module

| Field | Value |
|---|---|
| Title | AuditService + GET /audit-logs |
| Source | `18_AUDIT_LOGGING.md` |
| Dependencies | T-API-03 |
| Files | `audit/**` |
| Acceptance | Record helper; admin-only list/filters; immutability |
| Local tests | BU-05, BI-03, BI-07, AUD-01/04 — **PASS 2026-07-09** |
| GitHub CI | **green** — https://github.com/albarami/expoapp/actions/runs/29033402305 |
| Branch/PR | `agent/T-API-10-audit-list` |
| Status | **passed** |

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
| Local tests | `flutter analyze`, `flutter test` — **PASS 2026-07-09** (14 tests) |
| GitHub CI | **green** — https://github.com/albarami/expoapp/actions/runs/29036867939 |
| Branch/PR | `agent/T-MOB-01-flutter-foundation` |
| Status | **passed** |

---

## T-MOB-02 — Flutter auth + session + role shell

| Field | Value |
|---|---|
| Title | Login, demo buttons, token session, role tabs |
| Source | `14`, `13`, `20` screens 1–2 |
| Dependencies | T-MOB-01, T-API-03 |
| Files | `features/auth/**`, `app/router.dart`, `core/auth/**` |
| Acceptance | All demo users login; tabs by role; 401 → login |
| Skills | ui-ux-pro-max |
| Local tests | `flutter analyze`, `flutter test` — **PASS 2026-07-09** (29 tests) |
| GitHub CI | **green** — https://github.com/albarami/expoapp/actions/runs/29037687031 |
| Branch/PR | `agent/T-MOB-02-auth-session` |
| Status | **passed** |

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
| Local tests | `flutter analyze`, `flutter test` — **PASS 2026-07-09** (37 tests) |
| GitHub CI | **green** — https://github.com/albarami/expoapp/actions/runs/29038786051 |
| Branch/PR | `agent/T-MOB-03-dashboard` |
| Status | **passed** |

---

## T-MOB-04 — Flutter notifications (+ admin)

| Field | Value |
|---|---|
| Title | List/detail/read/create/stats |
| Source | `15`, `19`, `20` screens 4–6 |
| Dependencies | T-MOB-02, T-API-06 |
| Files | `features/notifications/**`, create under admin route |
| Acceptance | E2E with seed/API; employee cannot open create |
| Skills | ui-ux-pro-max |
| Local tests | `flutter analyze`, `flutter test` — **PASS 2026-07-09** (52 tests) |
| GitHub CI | **green** — https://github.com/albarami/expoapp/actions/runs/29039489370 |
| Branch/PR | `agent/T-MOB-04-notifications` |
| Status | **passed** |

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
| Local tests | `flutter analyze`, `flutter test` — **PASS 2026-07-09** (63 tests) |
| GitHub CI | **green** — https://github.com/albarami/expoapp/actions/runs/29040425846 |
| Branch/PR | `agent/T-MOB-05-access-requests` |
| Status | **passed** |

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
| Local tests | `flutter analyze`, `flutter test` — **PASS 2026-07-09** (73 tests) |
| GitHub CI | **green** — https://github.com/albarami/expoapp/actions/runs/29041340812 |
| Branch/PR | `agent/T-MOB-06-approvals` |
| Status | **passed** |

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
| Local tests | `flutter analyze` + `flutter test` — **PASS** (81 tests) |
| GitHub CI | **green** — https://github.com/albarami/expoapp/actions/runs/29042259598 |
| Branch/PR | `agent/T-MOB-07-audit` |
| Status | **passed** |

---

## T-L10N-01 — Localization & RTL polish

| Field | Value |
|---|---|
| Title | Full string audit; RTL; error code mapping |
| Source | `22`, `27` |
| Dependencies | T-MOB-03..07 |
| Files | `l10n/*.arb`, feature UIs |
| Acceptance | No hardcoded UI strings; Scenario 4 pass |
| GitHub CI | **green** — https://github.com/albarami/expoapp/actions/runs/29043070135 |
| Status | **passed** |

---

## T-QA-01 — Automated + manual QA

| Field | Value |
|---|---|
| Title | Complete test matrix + demo scenarios |
| Source | `28`, `32`, `04_TEST_MATRIX.md` |
| Dependencies | Feature tasks merged |
| Files | `apps/api/test/qa-scenarios.e2e-spec.ts`, Flutter FV tests, `.github/workflows/ci.yml`, `docs/_cursor/04_TEST_MATRIX.md` |
| Acceptance | Matrix statuses updated; MAN-01..05 pass |
| Local tests | API lint/test/e2e (78 unit + 47 e2e) + flutter analyze/test (91) — **PASS 2026-07-09** |
| GitHub CI | pending push |
| Branch/PR | `agent/T-QA-01-qa` |
| Status | **in_progress** |

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
3. ~~T-CI-01~~ **passed**
4. ~~T-ENV-03~~ **passed**
5. ~~T-API-01~~ … ~~T-API-10~~ **passed**
6. ~~T-MOB-01~~ **passed** (CI green: run 29036867939)
7. ~~T-MOB-02~~ **passed** (CI green: run 29037687031)
8. ~~T-MOB-03~~ **passed** (CI green: run 29038786051)
9. ~~T-MOB-04~~ **passed** (CI green: run 29039489370)
10. ~~T-MOB-05~~ **passed** (CI green: run 29040425846)
11. ~~T-MOB-06~~ **passed** (CI green: run 29041340812)
12. ~~T-MOB-07~~ **passed** (CI green: run 29042259598)
13. ~~T-L10N-01~~ **passed** (CI green: run 29043070135)
14. **T-QA-01** — Automated + manual QA (**in_progress** — local PASS; awaiting CI)
15. **T-REL-01** — Release readiness (next after T-QA-01 CI green)

**Resume at T-QA-01 CI gate, then T-REL-01.**
