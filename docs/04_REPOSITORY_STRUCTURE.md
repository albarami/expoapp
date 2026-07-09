# Repository Structure

## Required root structure

```text
expoapp/
  apps/
    api/
      prisma/
        schema.prisma
        seed.ts
      src/
        app.module.ts
        main.ts
        common/
        config/
        auth/
        users/
        departments/
        notifications/
        access-requests/
        approvals/
        audit/
        dashboard/
        fusion/
      test/
      package.json
      tsconfig.json
      .env.example

    mobile/
      lib/
        main.dart
        app/
        core/
        features/
        l10n/
        shared/
      assets/
        images/
        icons/
      test/
      pubspec.yaml

  docs/
    *.md

  docker-compose.yml
  README.md
  .env.example
  .gitignore
```

## Backend folder rules

```text
src/
  common/
    decorators/
    filters/
    guards/
    interceptors/
    pipes/
    types/
    utils/

  config/
    app.config.ts
    database.config.ts
    jwt.config.ts

  auth/
    auth.controller.ts
    auth.module.ts
    auth.service.ts
    dto/
    strategies/
    guards/

  users/
    users.controller.ts
    users.module.ts
    users.service.ts
    dto/

  notifications/
    notifications.controller.ts
    notifications.module.ts
    notifications.service.ts
    dto/

  access-requests/
    access-requests.controller.ts
    access-requests.module.ts
    access-requests.service.ts
    dto/

  approvals/
    approvals.controller.ts
    approvals.module.ts
    approvals.service.ts
    dto/

  audit/
    audit.controller.ts
    audit.module.ts
    audit.service.ts

  fusion/
    fusion.module.ts
    fusion-adapter.interface.ts
    mock-fusion.adapter.ts
    oracle-fusion.adapter.ts
    dto/
```

## Flutter folder rules

```text
lib/
  main.dart

  app/
    app.dart
    router.dart
    theme.dart
    localization.dart

  core/
    api/
      api_client.dart
      api_error.dart
    auth/
      token_storage.dart
      session_controller.dart
    config/
      app_config.dart
    constants/
    errors/
    routing/
    localization/

  shared/
    widgets/
      app_scaffold.dart
      loading_view.dart
      empty_state.dart
      error_view.dart
      primary_button.dart
      status_chip.dart
    models/
    utils/

  features/
    auth/
      data/
      domain/
      presentation/

    dashboard/
      data/
      domain/
      presentation/

    notifications/
      data/
      domain/
      presentation/

    access_requests/
      data/
      domain/
      presentation/

    approvals/
      data/
      domain/
      presentation/

    audit/
      data/
      domain/
      presentation/

    admin/
      data/
      domain/
      presentation/

  l10n/
    app_en.arb
    app_ar.arb
```

## Naming conventions

| Layer | Convention |
|---|---|
| Backend files | `kebab-case.ts` |
| Backend classes | `PascalCase` |
| Backend DTOs | `CreateNotificationDto` |
| Flutter files | `snake_case.dart` |
| Flutter classes | `PascalCase` |
| Flutter providers | `xxxProvider` |
| Database models | Singular PascalCase |
| API routes | kebab-case plural nouns |

## Commit/build checkpoints

Cursor should use these checkpoints internally:

1. Project scaffolding works.
2. Backend health endpoint works.
3. Database migration and seed work.
4. Auth and role guards work.
5. Notification API works.
6. Access request workflow works.
7. Flutter login works.
8. Flutter dashboard works.
9. Notification UI works.
10. Access request UI works.
11. Approval queues work.
12. Admin screens work.
13. Arabic/English switching works.
14. Full demo scenario passes.
