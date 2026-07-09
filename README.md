# ExpoApp

Enterprise Flutter + NestJS application for Expo Saudi — notifications, security access requests, approvals, dashboards, and audit tracking on top of Oracle Fusion (mock adapter in Phase 1).

**Phase 1 status:** Go-live ready for local/demo share. See [`docs/_cursor/06_RELEASE_CHECKLIST.md`](docs/_cursor/06_RELEASE_CHECKLIST.md). Demo walkthrough: [`docs/32_ACCEPTANCE_CRITERIA_DEMO.md`](docs/32_ACCEPTANCE_CRITERIA_DEMO.md).

## What's built (Phase 1) vs Phase 2

### Phase 1 (built — do not reinvent)

- NestJS API with JWT demo auth + RBAC (employee, manager, security admin, system admin)
- Prisma + PostgreSQL schema, migrations, and idempotent seed data
- Notifications (list/read/mark), device-token registration, scheduled publisher (push delivery mocked)
- Access requests + multi-step approvals workflow
- Dashboard / reference data endpoints
- Audit event listing
- Oracle Fusion **mock** adapter (`FUSION_MODE=mock`)
- Flutter app: auth/session, dashboard, notifications, access requests, approvals, audit, settings/profile, AR/EN polish
- Docker Compose for Postgres + Redis; GitHub Actions CI (API lint/test/e2e/build + Flutter analyze/test)

### Phase 2 (not built — client externals)

- Real Oracle Fusion / OIC integration
- Real SSO / OIDC
- Real FCM / APNs push delivery
- Store signing and production hosting
- Optional interactive device/web sign-off beyond automated QA

Track Phase 2 blockers in [`docs/_cursor/07_BLOCKERS.md`](docs/_cursor/07_BLOCKERS.md). Resume agent work from [`docs/_cursor/NEXT_RUN.md`](docs/_cursor/NEXT_RUN.md).

## Stack

| Layer | Technology |
|---|---|
| Mobile / Web | Flutter (iOS, Android, Web) |
| Backend | NestJS + TypeScript + Prisma |
| Database | PostgreSQL 16 |
| Cache | Redis 7 |
| Auth | JWT demo auth (SSO later) |

## Repository structure

```text
expoapp/
  apps/api/          NestJS API
  apps/mobile/       Flutter app
  docs/              Product & engineering specs
  docs/_cursor/      Agent control / resume / blockers
  docker-compose.yml Postgres + Redis
  scripts/           Empty placeholder — use npm/prisma commands below
```

## Prerequisites

- Node.js 20+ (22 OK)
- npm
- Flutter stable
- Docker + Docker Compose
- Git

## Ports

| Service | Host port | Notes |
|---|---|---|
| API | **3000** | `http://localhost:3000/api/v1` |
| Flutter web | **8080** (typical) | Also allowlisted in CORS |
| Postgres | **5433** | Maps to container 5432 |
| Redis | **6380** | Maps to container 6379 |

Details: [`PORTS.md`](PORTS.md).

## Local setup

```bash
# 1. Clone
git clone https://github.com/albarami/expoapp.git
cd expoapp

# 2. Environment (never commit real .env files)
cp .env.example .env
cp apps/api/.env.example apps/api/.env
# Edit JWT_SECRET locally if you want; keep placeholders out of git

# 3. Infrastructure
docker compose up -d

# 4. Backend
cd apps/api
npm install
npx prisma generate
npx prisma migrate deploy
npm run seed
npm run start:dev

# 5. Mobile (another terminal)
cd apps/mobile
flutter pub get
```

### Flutter run with API base URL

Android emulator (default host loopback mapping):

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
```

Web / iOS simulator / desktop:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000/api/v1
```

API: `http://localhost:3000/api/v1`  
Swagger: `http://localhost:3000/docs`  
Health: `http://localhost:3000/api/v1/health`

## How to stop services

```bash
# Stop API: Ctrl+C in the terminal running npm run start:dev

# Stop Postgres + Redis
docker compose down

# Optional: also remove volumes (wipes local DB data)
docker compose down -v
```

## Demo users (after `npm run seed`)

Password for all: `Password123!`

```text
noura.alharbi@expo.sa       # Employee
salem.alqahtani@expo.sa     # Employee (second)
faisal.otaibi@expo.sa       # Manager
reem.security@expo.sa       # Security Admin
admin@expo.sa               # System Admin
```

## Backend commands (`apps/api`)

There is **no** `npm run migrate`. Use Prisma CLI:

```bash
cd apps/api
npx prisma generate          # generate client (also runs on postinstall)
npx prisma migrate deploy    # apply migrations
npm run seed                 # seed demo users + sample data
npm run start:dev            # Nest watch mode
npm run lint
npm run test                 # unit tests
npm run test:e2e             # e2e (runInBand)
npm run build
```

The root `scripts/` folder is intentionally empty; prefer the commands above.

## Mobile commands (`apps/mobile`)

```bash
cd apps/mobile
flutter pub get
flutter analyze
flutter test
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000/api/v1
```

## Environment & secrets

- `.env` and `apps/api/.env` are **gitignored** — copy from the matching `.env.example` files.
- Committed examples use placeholders only (e.g. `JWT_SECRET=replace-with-local-dev-secret`).
- Keep root `.env.example` and `apps/api/.env.example` in sync (including `FCM_*` / `APNS_*` placeholders).

## Contributing / continuing work

1. Read [`docs/_cursor/NEXT_RUN.md`](docs/_cursor/NEXT_RUN.md) for the resume point.
2. Check [`docs/_cursor/07_BLOCKERS.md`](docs/_cursor/07_BLOCKERS.md) before starting Phase 2 externals.
3. Follow task ledger / architecture notes under [`docs/_cursor/`](docs/_cursor/).
4. Use conventional commits (`feat(scope):`, `fix(scope):`, `docs(scope):`, …).
5. Open PRs against `main`; do not force-push `main`.
6. Handover checklist: [`docs/33_HANDOVER_CHECKLIST.md`](docs/33_HANDOVER_CHECKLIST.md).

## Architecture & docs

| Doc | Purpose |
|---|---|
| [`docs/00_READ_ME_FIRST.md`](docs/00_READ_ME_FIRST.md) | Docs entry |
| [`docs/01_MASTER_CURSOR_PROMPT.md`](docs/01_MASTER_CURSOR_PROMPT.md) | Master agent prompt |
| [`docs/_cursor/01_ARCHITECTURE_DECISIONS.md`](docs/_cursor/01_ARCHITECTURE_DECISIONS.md) | ADRs |
| [`docs/_cursor/02_IMPLEMENTATION_PLAN.md`](docs/_cursor/02_IMPLEMENTATION_PLAN.md) | Implementation plan |
| [`docs/_cursor/03_TASK_LEDGER.md`](docs/_cursor/03_TASK_LEDGER.md) | Task ledger |
| [`docs/_cursor/05_ENVIRONMENT_SETUP.md`](docs/_cursor/05_ENVIRONMENT_SETUP.md) | Environment notes |
| [`docs/23_ORACLE_FUSION_ADAPTER.md`](docs/23_ORACLE_FUSION_ADAPTER.md) | Fusion adapter |
| [`docs/32_ACCEPTANCE_CRITERIA_DEMO.md`](docs/32_ACCEPTANCE_CRITERIA_DEMO.md) | Demo script |
| [`docs/33_HANDOVER_CHECKLIST.md`](docs/33_HANDOVER_CHECKLIST.md) | Handover checklist |

## CI

GitHub Actions runs on push/PR: Docker Compose config validation, API lint/test/**e2e**/build, Flutter analyze/test.

Latest green QA run (reference): https://github.com/albarami/expoapp/actions/runs/29044389419

## Oracle Fusion

Phase 1 uses `FUSION_MODE=mock`. Real Oracle credentials are Phase 2 — see `docs/23_ORACLE_FUSION_ADAPTER.md` and `docs/_cursor/07_BLOCKERS.md`.

## Known limitations (Phase 1)

- **Oracle Fusion** — mock adapter only (`FUSION_MODE=mock`); real Fusion/OIC is Phase 2
- **Auth** — JWT demo auth; no real SSO/OIDC yet
- **Push** — `PUSH_MODE=mock`; no FCM/APNs delivery
- **Local ports** — Postgres host **5433**, Redis host **6380** (container internals remain 5432/6379)
- **iOS simulator** — not available on WSL/Linux hosts; Flutter iOS-ready code retained
- **Interactive device/web sign-off** — optional; automated QA covers workflows (API e2e + Flutter tests)
- **Store signing / production hosting** — Phase 2 (Apple/Google credentials, deploy targets)

## Troubleshooting

| Issue | Fix |
|---|---|
| Port 5432/6379 in use | ExpoApp maps Postgres to host 5433 and Redis to host 6380 |
| Flutter not found | Install SDK and add `$HOME/flutter/bin` to PATH |
| Prisma generate fails | Ensure `apps/api/.env` has `DATABASE_URL` |
| Android emulator cannot reach API | `--dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1` |
| Web/iOS cannot reach API | `--dart-define=API_BASE_URL=http://localhost:3000/api/v1` |
| Looking for `npm run migrate` | Use `npx prisma migrate deploy` (and `npx prisma generate`) |

## License

Private — Expo Saudi / albarami.
