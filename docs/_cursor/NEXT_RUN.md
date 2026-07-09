# NEXT_RUN.md — Resume Point

**Updated:** 2026-07-09 (foundation setup run)  
**Read this file first on every new Cursor session.**

---

## Current phase

**Phase 1 foundations nearly complete.** Local validation passed.  
**STOP feature work until GitHub CI is green on the setup branch**, then start **T-API-01**.

---

## Current branch

- Branch: `agent/T-ENV-01-setup-control`
- Remote: `origin` → `https://github.com/albarami/expoapp.git`
- Push: done this run (or in progress — verify with `gh run list`)

---

## Current task

| Now | Next exact task |
|---|---|
| T-ENV-03 **in_progress** (local PASS) | Confirm GitHub Actions **green** on setup branch → mark T-ENV-03 **passed** → start **T-API-01** |

---

## Completed this run

1. T-ENV-01 — Verified Node 22.22.1, npm 9.2.0, Docker 29.6.1, Compose v5.3.0, Git 2.53.0; installed Flutter 3.44.5 stable to `~/flutter`
2. T-ENV-02 — Scaffolded `apps/api` (NestJS + Prisma), `apps/mobile` (Flutter), `docker-compose.yml`, `.env.example`, `.gitignore`, `README.md`, `PORTS.md`
3. T-CI-01 — Added `.github/workflows/ci.yml` (compose + api + flutter jobs)
4. Local validation — compose config/up, API lint/test/build, health 200, Flutter analyze/test — all pass
5. Host ports remapped to **5433** (Postgres) / **6380** (Redis) due to `uaid_os` occupying 5432/6379
6. Git init + remote + branch `agent/T-ENV-01-setup-control`

---

## Exact next actions (in order)

### 1. Confirm CI green (finish T-ENV-03)

```bash
cd /home/barami/projects/expoapp
git checkout agent/T-ENV-01-setup-control
gh run list --branch agent/T-ENV-01-setup-control --limit 5
# If red: fix, commit, push, wait again
# If green: update ledger T-ENV-03 → passed; clear B-003
```

Optional: open PR into `main` once CI green (remote was empty — first push may establish branch; create `main` via PR merge when ready).

### 2. Start T-API-01 (Nest foundation) — ONLY after CI green

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

### 3. Then sequential foundation

T-API-02 (full Prisma schema) → T-API-03 (auth) → T-API-04 (seed) → … per `03_TASK_LEDGER.md`  
No parallel feature agents until `08_PARALLEL_EXECUTION_PLAN.md` foundations are stable.

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

- Do not start T-API-02+ or T-MOB-* while T-ENV-03 CI is red/unknown
- Do not spawn parallel feature agents yet
- Do not create Expo React Native apps
- Do not force-push `main`
- Do not ask the user questions unless a true external credential blocker appears
