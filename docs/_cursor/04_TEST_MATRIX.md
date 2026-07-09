# Test Matrix — ExpoApp

**Generated:** 2026-07-09  
**Sources:** `28_TESTING_QA_ACCEPTANCE.md`, `11_BACKEND_NESTJS_SPEC.md`, master prompt §9

**Legend:** Status = pending | exists | passing | failing | N/A  
Update this file as tests are added.

---

## Backend unit tests

| ID | Area | Cases | Command | Status |
|---|---|---|---|---|
| BU-01 | AuthService | Login success; wrong password; inactive user | `cd apps/api && npm run test` | **passing** |
| BU-08 | ReferenceDataService | Departments/systems/securityRoles + enum catalogs | same | **passing** |
| BU-09 | DashboardService | Employee core counters; manager team; security widgets; admin stats | same | **passing** |
| BU-02 | Audience resolver | ALL / DEPARTMENT / ROLE / USERS; exclude inactive; invalid filter | same | **passing** |
| BU-03 | Access request validation | Justification length; dates; inactive role; missing manager; duplicate active | same | **passing** |
| BU-04 | Approval transitions | Manager approve→security; manager reject; security approve→complete (mock); security reject; already decided | same | pending |
| BU-05 | AuditService | record writes expected fields; no secrets; list filters/pagination | same | **passing** |
| BU-06 | MockFusionAdapter | profile; roles; validate; provision; status | same | **passing** |
| BU-07 | Request number | Format `AR-YYYY-######` | same | **passing** (covered in access-requests unit submit) |

---

## Backend integration / API tests

| ID | Area | Cases | Command | Status |
|---|---|---|---|---|
| BI-01 | Health | GET `/health` ok with DB | `npm run test` / e2e | **passing** (e2e envelope; DB via health unit/service) |
| BI-02 | Auth | Login all demo users; `/auth/me`; logout | same | **passing** |
| BI-03 | Authz | Missing token → 401; employee POST notifications → 403; employee GET audit → 403 | same | **passing** (real POST /notifications + real GET /audit-logs) |
| BI-04 | Notifications | Admin create+recipients; employee list/detail/read; stats; cancel | `npm run test:e2e` (`notifications.e2e-spec.ts`) | **passing** |
| BI-05 | Access requests | Submit → MANAGER_PENDING + task; list scoped; cancel rules | `npm run test:e2e` (`access-requests.e2e-spec.ts`) | **passing** |
| BI-06 | Approvals | Manager approve creates security task; wrong assignee 403; security completes mock | same | pending |
| BI-07 | Audit | Admin list/filters/pagination; employee/manager 403 | `npm run test:e2e` (`audit.e2e-spec.ts`) | **passing** (list/filters; submit/cancel writes covered by T-API-07; approve writes still T-API-08) |
| BI-08 | Seed | Idempotent second run; expected entity counts/statuses | `npm run seed` ×2 + `npm run test` (`seed.idempotency.spec.ts`) | **passing** |
| BI-09 | Reference + dashboard | Auth required; reference payload complete; role-aware `/dashboard/summary` | `npm run test:e2e` (`reference-dashboard.e2e-spec.ts`) | **passing** |

---

## Flutter widget / unit tests

| ID | Area | Cases | Command | Status |
|---|---|---|---|---|
| FU-01 | Login | Validation; invalid credentials message | `cd apps/mobile && flutter test` | pending |
| FU-02 | Dashboard | Renders metrics for each role (mocked providers) | same | pending |
| FU-03 | Notification card | Localized title; priority chip | same | pending |
| FU-04 | Access request form | Min justification; temporary needs end date | same | pending |
| FU-05 | Approval confirm | Approve/reject sheets | same | pending |
| FU-06 | Router guards | Employee blocked from `/audit` | same | pending |
| FU-07 | Error mapping | Known codes → l10n | same | pending |

---

## Navigation tests

| ID | Cases | Status |
|---|---|---|
| NAV-01 | Unauthenticated → `/login` | pending |
| NAV-02 | Authenticated `/login` → `/` | pending |
| NAV-03 | Role tab sets match `06` / `13` | pending |
| NAV-04 | Deep restricted route shows unauthorized | pending |

---

## Repository / provider tests

| ID | Cases | Status |
|---|---|---|
| RP-01 | ApiClient attaches Bearer; maps 401 | pending |
| RP-02 | NotificationsProvider loading/error/data | pending |
| RP-03 | SessionController restore from secure storage | pending |

---

## Role / permission tests

| ID | Cases | Status |
|---|---|---|
| RBAC-01 | Matrix from `06_PERSONAS_ROLES_PERMISSIONS.md` API-level | pending |
| RBAC-02 | UI tabs hidden for unauthorized roles | pending |
| RBAC-03 | Manager cannot decide non-assigned task | pending |

---

## Form validation tests

| ID | Forms | Status |
|---|---|---|
| FV-01 | Login email/password | pending |
| FV-02 | Create notification fields + audience | pending |
| FV-03 | Access request fields | pending |
| FV-04 | Reject requires comment | pending |

---

## Localization tests

| ID | Cases | Status |
|---|---|---|
| L10N-01 | ARB keys for all primary screens | pending |
| L10N-02 | Arabic sets RTL | pending |
| L10N-03 | Fallback to EN when AR missing | pending |
| L10N-04 | Manual Scenario 4 Arabic UI | pending |

---

## Audit-log tests

| ID | Cases | Status |
|---|---|---|
| AUD-01 | Login success/failure audited | **passing** (`audit.e2e-spec.ts`) |
| AUD-02 | Notification create/publish/read/cancel | **passing** (covered in BI-04 e2e audit assertions) |
| AUD-03 | Access submit/cancel + approvals + provisioning | pending |
| AUD-04 | No password/token in metadata | **passing** (`audit.e2e-spec.ts` login audit scan) |

---

## Oracle adapter tests

| ID | Cases | Status |
|---|---|---|
| FUS-01 | Mock provision returns MOCK-FUSION-* | **passing** (unit + e2e `fusion.e2e-spec.ts`) |
| FUS-02 | Oracle adapter throws FUSION_CONFIGURATION_MISSING without env | **passing** |
| FUS-03 | Services use interface token only | **passing** (`FusionModule` `FUSION_ADAPTER` token) |

---

## Error / loading / empty-state tests

| ID | Cases | Status |
|---|---|---|
| UX-01 | Each list screen empty copy EN/AR | pending |
| UX-02 | Error + retry on failed fetch | pending |
| UX-03 | Button loading disables double submit | pending |
| UX-04 | Offline message | pending |

---

## Platform checks

| ID | Platform | Check | Status |
|---|---|---|---|
| PL-01 | Android | `flutter run` login + dashboard | pending |
| PL-02 | iOS | Simulator when available | pending / note if host lacks Xcode |
| PL-03 | Web | `flutter run -d chrome` admin create notification | pending |
| PL-04 | Safe area / keyboard | Forms on mobile | pending |
| PL-05 | RTL overflow | Main screens in AR | pending |

---

## Manual acceptance scenarios

| ID | Scenario | Source | Status |
|---|---|---|---|
| MAN-01 | Employee notification E2E | `28` Scenario 1 | pending |
| MAN-02 | Access request approval E2E | `28` Scenario 2 | pending |
| MAN-03 | Unauthorized access | `28` Scenario 3 | pending |
| MAN-04 | Arabic UI | `28` Scenario 4 | pending |
| MAN-05 | Full demo script | `32_ACCEPTANCE_CRITERIA_DEMO.md` | pending |

---

## CI / release readiness checks

| ID | Check | Status |
|---|---|---|
| CI-01 | docker compose config | **passing** (CI job) |
| CI-02 | api lint | **passing** |
| CI-03 | api test | **passing** |
| CI-04 | api build | **passing** |
| CI-05 | flutter analyze | **passing** |
| CI-06 | flutter test | **passing** |
| CI-07 | GitHub Actions workflow exists & green | **passing** (https://github.com/albarami/expoapp/actions/runs/29032814249) |
| REL-01 | Release checklist `06_RELEASE_CHECKLIST.md` | pending |

---

## Notes for hosts without iOS

If WSL/Linux cannot run iOS simulator, mark PL-02 as **documented limitation** in blockers (not a Phase 1 product blocker) and still keep iOS-ready code (no Android-only APIs).
