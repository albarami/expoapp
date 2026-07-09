# Environments and Configuration

## Environment modes

The app supports these modes:

| Mode | Purpose |
|---|---|
| `local` | Developer machine with Docker PostgreSQL/Redis |
| `demo` | Stable demo environment using mock Fusion adapter |
| `staging` | Client testing with SSO and partial integration |
| `production` | Final production deployment |

## Backend environment variables

Create `apps/api/.env.example`:

```bash
NODE_ENV=local
PORT=3000
API_PREFIX=api/v1

DATABASE_URL=postgresql://expoapp:expoapp@localhost:5432/expoapp?schema=public
REDIS_URL=redis://localhost:6379

JWT_SECRET=replace-with-local-dev-secret
JWT_EXPIRES_IN=8h
JWT_REFRESH_EXPIRES_IN=30d

CORS_ORIGINS=http://localhost:3000,http://localhost:8080,http://localhost:5173,http://localhost:5000

FUSION_MODE=mock
FUSION_BASE_URL=https://example.oraclecloud.com
FUSION_CLIENT_ID=
FUSION_CLIENT_SECRET=
FUSION_TOKEN_URL=
FUSION_SCOPE=

PUSH_MODE=mock
FCM_SERVER_KEY=
APNS_KEY_ID=
APNS_TEAM_ID=
APNS_BUNDLE_ID=

LOG_LEVEL=debug
```

## Mobile environment variables

Create `apps/mobile/.env.example` or use Dart defines:

```bash
APP_ENV=local
API_BASE_URL=http://10.0.2.2:3000/api/v1
API_BASE_URL_IOS_SIMULATOR=http://localhost:3000/api/v1
DEFAULT_LOCALE=en
ENABLE_DEMO_LOGIN=true
```

For Android emulator, `10.0.2.2` maps to host machine. For iOS simulator, use `localhost`.

## Docker Compose

Root `docker-compose.yml` must provide:

```yaml
services:
  postgres:
    image: postgres:16
    container_name: expoapp-postgres
    environment:
      POSTGRES_USER: expoapp
      POSTGRES_PASSWORD: expoapp
      POSTGRES_DB: expoapp
    ports:
      - "5432:5432"
    volumes:
      - expoapp-postgres-data:/var/lib/postgresql/data

  redis:
    image: redis:7
    container_name: expoapp-redis
    ports:
      - "6379:6379"

volumes:
  expoapp-postgres-data:
```

## Backend run commands

```bash
cd apps/api
npm install
npx prisma generate
npx prisma migrate dev --name init
npm run seed
npm run start:dev
```

## Mobile run commands

```bash
cd apps/mobile
flutter pub get
flutter gen-l10n
flutter run
```

## Recommended README content

Root README must include:

- Product summary
- Repo structure
- Prerequisites
- Local setup
- Environment setup
- Demo users
- Backend commands
- Mobile commands
- Troubleshooting
- Known assumptions
- How Oracle integration will be enabled later

## Config rules

- Never commit real credentials.
- Keep `.env.example` committed.
- Keep `.env` ignored.
- All URLs must be configurable.
- Backend must validate required environment variables at startup.
- Mobile must fail gracefully if API base URL is missing or unreachable.
