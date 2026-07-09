# ExpoApp

Enterprise Flutter + NestJS application for Expo Saudi — notifications, security access requests, approvals, dashboards, and audit tracking on top of Oracle Fusion (mock adapter in Phase 1).

**Phase 1 status:** Go-live ready. See [`docs/_cursor/06_RELEASE_CHECKLIST.md`](docs/_cursor/06_RELEASE_CHECKLIST.md). Demo walkthrough: [`docs/32_ACCEPTANCE_CRITERIA_DEMO.md`](docs/32_ACCEPTANCE_CRITERIA_DEMO.md).

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
  apps/api/       NestJS API
  apps/mobile/    Flutter app
  docs/           Product & engineering specs
  docker-compose.yml
```

## Prerequisites

- Node.js 20+ (22 OK)
- npm
- Flutter stable
- Docker + Docker Compose
- Git

## Local setup

```bash
# 1. Clone
git clone https://github.com/albarami/expoapp.git
cd expoapp

# 2. Environment
cp .env.example .env
cp apps/api/.env.example apps/api/.env

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
flutter run
# Admin/web demo:
flutter run -d chrome
```

API: `http://localhost:3000/api/v1`  
Swagger: `http://localhost:3000/docs`  
Health: `http://localhost:3000/api/v1/health`

Local host ports: Postgres **5433**, Redis **6380** (see `PORTS.md`).

## Demo users (after seed)

```text
noura.alharbi@expo.sa / Password123!     # Employee
faisal.otaibi@expo.sa / Password123!     # Manager
reem.security@expo.sa / Password123!     # Security Admin
admin@expo.sa / Password123!             # System Admin
```

## Backend commands

```bash
cd apps/api
npm run lint
npm run test
npm run test:e2e
npm run build
npm run start:dev
npm run seed
```

## Mobile commands

```bash
cd apps/mobile
flutter pub get
flutter analyze
flutter test
flutter run
```

## CI

GitHub Actions runs on push/PR: Docker Compose config validation, API lint/test/**e2e**/build, Flutter analyze/test.

Latest green QA run: https://github.com/albarami/expoapp/actions/runs/29044389419

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

## Documentation

- Start: `docs/00_READ_ME_FIRST.md` and `docs/01_MASTER_CURSOR_PROMPT.md`
- Demo script: `docs/32_ACCEPTANCE_CRITERIA_DEMO.md`
- Release status: `docs/_cursor/06_RELEASE_CHECKLIST.md`
- Agent control: `docs/_cursor/`

## Troubleshooting

| Issue | Fix |
|---|---|
| Port 5432/6379 in use | ExpoApp maps Postgres to host 5433 and Redis to host 6380 to avoid conflicts |
| Flutter not found | Install SDK and add `$HOME/flutter/bin` to PATH |
| Prisma generate fails | Ensure `apps/api/.env` has `DATABASE_URL` |
| Android emulator API | Use `http://10.0.2.2:3000/api/v1` |
| iOS simulator API | Use `http://localhost:3000/api/v1` |

## License

Private — Expo Saudi / albarami.
