# ExpoApp

Enterprise Flutter + NestJS application for Expo Saudi — notifications, security access requests, approvals, dashboards, and audit tracking on top of Oracle Fusion (mock adapter in Phase 1).

## Stack

| Layer | Technology |
|---|---|
| Mobile / Web | Flutter (iOS, Android, Web) |
| Backend | NestJS + TypeScript + Prisma |
| Database | PostgreSQL 16 |
| Cache | Redis 7 |
| Auth | JWT (SSO later) |

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
# Full migrate/seed arrives with T-API-02 / T-API-04
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

GitHub Actions runs on push/PR: Docker Compose config validation, API lint/test/build, Flutter analyze/test.

## Oracle Fusion

Phase 1 uses `FUSION_MODE=mock`. Real Oracle credentials are Phase 2 — see `docs/23_ORACLE_FUSION_ADAPTER.md`.

## Documentation

Start at `docs/00_READ_ME_FIRST.md` and `docs/01_MASTER_CURSOR_PROMPT.md`. Agent control files live in `docs/_cursor/`.

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
