# Performance, Caching, and Offline Readiness

## Performance goal

The app must feel very fast because it is an experience layer on top of Oracle Fusion.

Target local/mock performance:

| Operation | Target |
|---|---:|
| Login API | < 500 ms |
| Dashboard API | < 500 ms |
| Notifications list | < 500 ms |
| Access request submit | < 800 ms |
| Approval decision | < 1000 ms |
| App screen transition | immediate/smooth |

## Architecture for speed

```text
Flutter UI
  -> Dio API client
    -> NestJS API
      -> PostgreSQL operational DB
      -> Redis/cache where useful
      -> FusionAdapter for integration operations
```

Do not call Oracle Fusion directly from Flutter.

## Backend caching

Phase 1:

- Cache reference data in memory or Redis optional.
- Cache dashboard counts briefly if needed.

Phase 2:

- Cache Oracle reference data in PostgreSQL.
- Use Redis for hot reference data if traffic grows.
- Use outbox for slow integration writes.

## Reference data caching

Reference data includes:

- departments
- systems
- security roles
- enum values

Mobile can cache this for current session.

Refresh:

- on login
- manual refresh
- app restart
- after 15 minutes in production if implemented

## Pagination

Use pagination for:

- notifications
- requests
- approvals
- audit logs
- users

Default:

```text
page=1&pageSize=20
```

Max page size:

```text
100
```

## Mobile performance rules

- Avoid fetching all data on startup.
- Fetch dashboard summary first.
- Fetch lists when screen opens.
- Use pull-to-refresh.
- Keep widgets small.
- Avoid heavy JSON processing in build methods.
- Do not use huge images/assets.
- Use const constructors where possible.
- Use `ListView.builder`.

## Offline readiness

Full offline mode is not required in Phase 1, but app should behave gracefully when offline.

Minimum:

- Show friendly network error.
- Retry button.
- Keep session token.
- Do not lose form input if API submit fails.
- For future, cache last successful notifications list.

## Slow integration strategy

Oracle Fusion operations may be slower than normal app operations.

Therefore:

- User-facing approval should complete quickly.
- Provisioning can move to `PROVISIONING`.
- Backend outbox processes Oracle call.
- UI shows status updates.

Mock mode can complete immediately for demo.

## Loading UX

Use:

- Small spinners inside buttons for actions.
- Full-screen loading only on first screen load.
- Pull-to-refresh for list updates.
- Optimistic read marking optional but backend truth wins.

## Performance anti-patterns

- No direct mobile-to-Fusion calls.
- No fetching audit logs for non-admin dashboard.
- No loading all users for normal employee screens.
- No creating notification recipients on the client.
- No screen-level static data pretending to be API data.
