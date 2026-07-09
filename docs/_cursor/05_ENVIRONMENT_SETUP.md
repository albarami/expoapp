# Environment Setup — ExpoApp

**Updated:** 2026-07-09 (T-ENV-01/02/03 setup run)  
**Status:** Toolchain verified; scaffold + local validation passed

---

## Detected toolchain (WSL Ubuntu)

| Tool | Version / path | Status |
|---|---|---|
| Node.js | v22.22.1 (`/usr/bin/node`) | OK |
| npm | 9.2.0 (`/usr/bin/npm`) | OK |
| Flutter | 3.44.5 stable (`~/flutter`) | OK — installed this run |
| Dart | 3.12.2 | OK |
| Docker | 29.6.1 | OK |
| Docker Compose | v5.3.0 | OK |
| Git | 2.53.0 | OK |
| gh CLI | authenticated as `albarami` | OK |

### Flutter doctor (summary)

- Flutter SDK: OK
- Android toolchain: missing (not required for analyze/test CI)
- Chrome: missing (optional for web demo)
- Linux desktop toolchain: incomplete (optional)
- Network: OK

### Package manager

- Backend: **npm** (`apps/api/package-lock.json` present)
- Mobile: `flutter pub`

---

## Detected repository state

| Item | Status |
|---|---|
| `/docs` specification pack | Present |
| `docs/_cursor` control files | Present |
| `apps/api` | Present (NestJS + Prisma scaffold) |
| `apps/mobile` | Present (Flutter scaffold) |
| `docker-compose.yml` | Present (Postgres 16 + Redis 7) |
| `.env.example` | Present |
| `README.md` | Present |
| `.gitignore` | Present |
| `.github/workflows/ci.yml` | Present |
| Git remote | `https://github.com/albarami/expoapp.git` |
| Setup branch | `agent/T-ENV-01-setup-control` |

---

## Local Docker host ports

Host **5432** / **6379** are occupied by another project (`uaid_os`). ExpoApp maps:

| Service | Host | Container |
|---|---|---|
| Postgres | **5433** | 5432 |
| Redis | **6380** | 6379 |

See `PORTS.md`. `DATABASE_URL` / `REDIS_URL` in `.env.example` use these host ports.

---

## Backend commands

```bash
cd apps/api && npm install
npx prisma generate
# Full migrate/seed: T-API-02 / T-API-04
npm run start:dev
npm run lint && npm run test && npm run build
```

- Swagger: `http://localhost:3000/docs`
- API: `http://localhost:3000/api/v1`
- Health: `http://localhost:3000/api/v1/health` → `{"status":"ok"}`

---

## Flutter commands

```bash
cd apps/mobile
flutter pub get
flutter analyze
flutter test
flutter run
flutter run -d chrome   # needs Chrome
```

---

## Docker Compose

```bash
docker compose up -d
docker compose config
docker compose down
```

---

## Environment variables

Root / `apps/api/.env.example` use host ports **5433** / **6380**. Never commit real secrets.

Mobile: `apps/mobile/.env.example` (Dart defines later in T-MOB-01).

---

## CI command mapping

| Local | GitHub Actions |
|---|---|
| `docker compose config` | compose job |
| `cd apps/api && npm ci` | setup-node + npm ci |
| `npm run lint` / `test` / `build` | api job (+ prisma generate) |
| `flutter pub get` / `analyze` / `test` | mobile job (subosito/flutter-action) |

Workflow: `.github/workflows/ci.yml`

---

## First local validation (2026-07-09)

| Check | Result |
|---|---|
| `docker compose config` | pass |
| `docker compose up -d` | pass (healthy) |
| API lint / test / build | pass |
| API `/api/v1/health` | pass HTTP 200 |
| Flutter analyze / test | pass |

---

## Demo credentials (after seed)

```text
noura.alharbi@expo.sa / Password123!     # Employee
faisal.otaibi@expo.sa / Password123!     # Manager
reem.security@expo.sa / Password123!     # Security Admin
admin@expo.sa / Password123!             # System Admin
```
