# NEXT_RUN.md — Resume Point

**Updated:** 2026-07-09 (CI green confirmed)  
**Read this file first on every new Cursor session.**

---

## Current phase

**Phase 1 foundations complete for env/CI.** GitHub Actions is green on the setup branch.  
**Resume at T-API-01** (NestJS backend foundation).

---

## Current branch

- Branch: `agent/T-ENV-01-setup-control`
- Remote: `origin` → `https://github.com/albarami/expoapp.git`
- CI: **success** — https://github.com/albarami/expoapp/actions/runs/29025032699
- PR: not created (`main` does not exist yet on remote)

---

## Current task

| Now | Next exact task |
|---|---|
| T-ENV-03 **passed** (local + CI green) | Start **T-API-01** — Nest foundation |

---

## Completed this run

1. T-ENV-01 — Verified Node 22.22.1, npm 9.2.0, Docker 29.6.1, Compose v5.3.0, Git 2.53.0; installed Flutter 3.44.5 stable to `~/flutter`
2. T-ENV-02 — Scaffolded `apps/api` (NestJS + Prisma), `apps/mobile` (Flutter), `docker-compose.yml`, `.env.example`, `.gitignore`, `README.md`, `PORTS.md`
3. T-CI-01 — Added `.github/workflows/ci.yml` (compose + api + flutter jobs)
4. Local validation — compose config/up, API lint/test/build, health 200, Flutter analyze/test — all pass
5. Host ports remapped to **5433** (Postgres) / **6380** (Redis) due to `uaid_os` occupying 5432/6379
6. Git init + remote + branch `agent/T-ENV-01-setup-control`
7. T-ENV-03 — Pushed setup branch; GitHub Actions CI **green** (run 29025032699)

---

## Exact next actions (in order)

### 1. Start T-API-01 (Nest foundation)

Implement per `11_BACKEND_NESTJS_SPEC.md`:

- ConfigModule validation
- Global ValidationPipe (already partial)
- Exception filter + response envelope
- Trace ID middleware/interceptor
- Helmet (already partial)
- Swagger polish
- Health endpoint hardened
- Do **not** jump to full Prisma product schema yet (that is T-API-02)

Branch pattern: continue on setup branch if still open, or `agent/T-API-01-nest-foundation`.

### 2. Then sequential foundation

T-API-02 (full Prisma schema) → T-API-03 (auth) → T-API-04 (seed) → … per `03_TASK_LEDGER.md`  
No parallel feature agents until `08_PARALLEL_EXECUTION_PLAN.md` foundations are stable.

Optional later: create `main` from this branch / open PR once default branch exists.

---

## Skills reminder for later UI work

Before any Flutter UI/UX implementation:

1. Read `.cursor/skills/ui-ux-pro-max/SKILL.md`
2. Use Flutter stack data: `.cursor/skills/ui-ux-pro-max/data/stacks/flutter.csv`
3. Follow `.cursor/rules/use-available-skills.mdc`

---

## Local ports reminder

| Service | Host port |
|---|---|
| Postgres | 5433 |
| Redis | 6380 |
| API | 3000 |

See `PORTS.md`.

---

## Do not do next

- Do not skip T-API-01 and jump to T-API-02+ or T-MOB-*
- Do not spawn parallel feature agents yet
- Do not create Expo React Native apps
- Do not force-push `main`
- Do not ask the user questions unless a true external credential blocker appears
