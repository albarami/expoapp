# NEXT_RUN.md — Resume Point

**Updated:** 2026-07-09 (T-API-01 local green; push/CI pending)  
**Read this file first on every new Cursor session.**

---

## Current phase

**T-API-01 Nest foundation implemented locally** (config validation, exception filter, response envelope, trace ID, Swagger/Helmet polish, hardened health).  
**Awaiting GitHub CI green on `agent/T-API-01-nest-foundation`.**  
After CI green → mark T-API-01 **passed**, then start **T-API-02** (Prisma schema).

---

## Current branch

- Branch: `agent/T-API-01-nest-foundation`
- Remote: `origin` → `https://github.com/albarami/expoapp.git`
- CI: pending first push of this branch
- PR: not created (`main` does not exist yet on remote)

---

## Current task

| Now | Next exact task |
|---|---|
| T-API-01 local **PASS** (lint/test/e2e/build/health/docs) | Confirm CI green → then **T-API-02** Prisma schema |

---

## Completed this run

1. Branched `agent/T-API-01-nest-foundation` from setup HEAD
2. ConfigModule + `validateEnv` (required env at startup)
3. Global ValidationPipe (whitelist, forbidNonWhitelisted, transform)
4. `GlobalExceptionFilter` + `BusinessException` + stable error envelope
5. Trace ID middleware (`x-trace-id`) + response envelope interceptor (`data`/`meta`)
6. Helmet + Swagger polish (`/docs`, bearer auth scheme)
7. Health service checks DB + Redis + fusionMode; envelope response
8. Unit tests (16) + e2e (2); local health 200 + Swagger 200

---

## Exact next actions (in order)

### 1. Finish T-API-01 gate

- Push branch if not yet pushed
- Wait for GitHub Actions green
- Update ledger T-API-01 → **passed** with CI run URL
- Update this file resume point to T-API-02

### 2. Start T-API-02 (Prisma schema)

Implement full schema per `07_DATA_MODEL.md` + `08_DATABASE_SCHEMA_PRISMA.md`; migrate init.  
Do **not** start auth (T-API-03) until schema migrates cleanly.

No parallel feature agents until foundations per `08_PARALLEL_EXECUTION_PLAN.md`.

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

- Do not skip CI green gate for T-API-01
- Do not spawn parallel feature agents yet
- Do not create Expo React Native apps
- Do not force-push `main`
- Do not ask the user questions unless a true external credential blocker appears
