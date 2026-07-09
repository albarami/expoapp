# Local Docker host ports

`uaid_os-postgres-1` and `uaid_os-redis-1` already bind host **5432** and **6379**.

ExpoApp compose therefore maps:
- Postgres: `5433:5432` -> `DATABASE_URL=...@localhost:5433/...`
- Redis: `6380:6379` -> `REDIS_URL=redis://localhost:6380`

Container-internal ports remain 5432 / 6379.
