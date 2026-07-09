# Parallel Execution Plan — ExpoApp

**Generated:** 2026-07-09  
**Rule:** Parallel/multi-agent work ONLY after foundational architecture, CI, auth, navigation, Prisma schema, localization, and shared contracts are stable and CI is green.

---

## Sequential foundation (MUST NOT parallelize)

These tasks share critical files. One agent / one branch at a time. Integration owner = primary agent.

| Order | Task IDs | Why sequential |
|---|---|---|
| 1 | T-DOC-01 | Intake (this run) |
| 2 | T-ENV-01, T-ENV-02, T-CI-01 | Env + scaffold + CI |
| 3 | T-API-01, T-API-02 | Nest bootstrap + Prisma schema |
| 4 | T-API-03, T-API-04 | Auth/RBAC + seed core |
| 5 | T-API-05 | Reference data + dashboard |
| 6 | T-MOB-01 | Flutter foundation (app root, router, Dio, l10n, theme) |
| 7 | T-MOB-02 | Auth + session + shell |

**Critical files (single-writer):**
- `apps/api/src/app.module.ts`, `main.ts`
- `apps/api/prisma/schema.prisma`
- Auth module / guards
- `apps/mobile/lib/main.dart`, `app/router.dart`, `app/theme.dart`
- Global Riverpod providers / ApiClient
- `l10n/*.arb`, localization config
- `.env.example`, `docker-compose.yml`, `.github/workflows/*`
- Shared DTO/contract types

---

## Feature waves (after foundation CI green)

### Wave A — Backend feature modules (limited parallel)

Safe **after** T-API-05 merged, if each agent owns a module directory and Integration Owner merges:

| Stream | Task | Branch pattern | Owns |
|---|---|---|---|
| A1 | T-API-06 Notifications | `agent/T-API-06-notifications` | `notifications/` |
| A2 | T-API-09 Fusion adapter | `agent/T-API-09-fusion` | `fusion/` |
| A3 | T-API-10 Audit service core | `agent/T-API-10-audit` | `audit/` (service first) |

**Not parallel with each other if both touch seed.ts or app.module** — prefer A2+A3 first (small), then A1, then access/approvals sequentially:

| Stream | Task | Notes |
|---|---|---|
| A4 | T-API-07 Access requests | After audit helper exists |
| A5 | T-API-08 Approvals | After access requests (shared workflow) |

**Recommendation:** Keep A4→A5 sequential. Parallelize only A2 (fusion) with early A3 (audit service) before notifications if desired.

### Wave B — Flutter features (after T-MOB-02 + matching APIs green)

| Stream | Task | Requires API | Owns |
|---|---|---|---|
| B1 | T-MOB-03 Dashboard | T-API-05 | `features/dashboard/` |
| B2 | T-MOB-04 Notifications UI | T-API-06 | `features/notifications/` |
| B3 | T-MOB-05 Access requests UI | T-API-07 | `features/access_requests/` |
| B4 | T-MOB-06 Approvals UI | T-API-08 | `features/approvals/` |
| B5 | T-MOB-07 Audit UI | T-API-10 | `features/audit/` |

B2–B5 may run in parallel **only if** router changes are coordinated by Integration Owner (single PR for route table, or rebase order).

### Wave C — Cross-cutting (parallel after screens exist)

| Stream | Task |
|---|---|
| C1 | T-L10N-01 Full string/RTL audit |
| C2 | T-QA-01 Expand automated tests |
| C3 | T-UX-01 Design-system polish (`ui-ux-pro-max`) |
| C4 | T-SEC-01 Security checklist verification |
| C5 | Docs/README polish |

---

## Multi-agent protocol

1. Each agent: own branch `agent/<task-id>-<slug>` or isolated worktree
2. Read relevant `/docs` + `docs/_cursor` before coding
3. Follow `.cursor/rules` and Flutter UI skill for UI tasks
4. Update `03_TASK_LEDGER.md` status
5. Local validation for owned task
6. Push + PR; **do not mark complete until GitHub CI green**
7. Dependent tasks wait for prerequisite merge
8. Integration Owner: pull main, full validation, conflict resolution, ledger update

---

## Integration ownership model

| Role | Responsibility |
|---|---|
| Integration Owner | `app.module`, Prisma, router, CI, merges, ledger |
| NestJS Backend Lead | API modules |
| Flutter Mobile Lead | Features + shell |
| Flutter UI/UX Lead | Design system; must invoke `ui-ux-pro-max` |
| QA Automation | Test matrix execution |
| DevOps | CI/Docker/env |
| Security Engineer | RBAC/audit/secrets review |

---

## When NOT to parallelize

- Any change to Prisma schema while another agent migrates
- Simultaneous edits to GoRouter root
- Simultaneous seed.ts rewrites without coordination
- CI workflow edits during feature PRs
- “Fix CI” + feature work on same branch without isolation

---

## Current parallelization status

**DISABLED.** Scaffold + CI exist; waiting on setup-branch CI green, then sequential T-API-01 → … per ledger. No multi-agent feature waves yet.
