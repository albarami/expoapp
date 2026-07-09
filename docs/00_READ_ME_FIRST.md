# ExpoApp Documentation Pack — Read Me First

## Purpose

This `/docs` folder is the build specification for `albarami/expoapp`.

Cursor must treat these documents as the source of truth for building a serious enterprise-grade application for Expo Saudi. The system is an app layer built on top of Oracle Fusion, not a replacement for Oracle Fusion.

The first runnable version must be complete end-to-end using a real backend, real database schema, seeded data, real workflows, role-based access, and real screens. Oracle Fusion integration is represented by a clean adapter layer in the first build, with `MockFusionAdapter` used locally and `OracleFusionAdapter` implemented when credentials and endpoint details are provided.

## What “mock data” means in this project

Mock data does **not** mean fake static screens.

Mock data means:

- Data is stored in PostgreSQL through Prisma.
- API endpoints are real.
- Mobile app calls the backend over HTTP.
- Authentication returns real JWT tokens for seeded users.
- Notifications are created, listed, read, filtered, and audited.
- Security access requests move through real workflow states.
- Approval tasks are generated and completed.
- Audit logs are written for meaningful actions.
- Oracle Fusion calls are abstracted behind an adapter interface.

The app should feel production-shaped even before Oracle credentials are available.

## Required outcome

Cursor must build:

```text
expoapp/
  apps/
    api/                 # NestJS backend
    mobile/              # Flutter iOS/Android app, also web-capable for admin testing
  docs/                  # These Markdown specifications
  docker-compose.yml
  README.md
  .env.example
```

## Main product modules

1. Authentication and role-based navigation
2. Dashboard
3. One-to-many notifications
4. Security access request submission
5. Manager and security approval workflow
6. Admin notification creation
7. Audit logging
8. Oracle Fusion adapter boundary
9. Arabic/English localization
10. Fast mobile UX for iOS and Android

## Implementation priority

Cursor must build in this order:

1. Repository structure and local development setup
2. Backend API, database schema, seed data, Swagger
3. Authentication and RBAC
4. Notification module
5. Access request workflow module
6. Audit log module
7. Flutter app architecture
8. Mobile screens and role-based navigation
9. Admin screens
10. Localization, error handling, loading states
11. Tests and final acceptance checklist

## Hard rules

- Do not hardcode lists inside Flutter screens except for temporary UI constants such as tabs.
- All business data must come from the backend API.
- Do not skip error states, loading states, empty states, and validation.
- Do not leave TODO placeholders for core features.
- Do not build Oracle Fusion directly into controllers. Use an adapter/service interface.
- Do not store secrets in source control.
- Do not make the user enter technical configuration repeatedly. Use `.env.example`.
- Do not implement only a clickable prototype. Build a working system with mock backend/data.

## User-facing language

The app must support:

- English
- Arabic
- Left-to-right and right-to-left layout switching
- No mixed hardcoded language strings in UI widgets

## Success definition

A stakeholder must be able to:

1. Run the backend locally.
2. Seed the database.
3. Open the mobile app.
4. Login as employee, manager, security admin, and system admin.
5. Send a broadcast notification as admin.
6. See it as an employee.
7. Submit a security access request as employee.
8. Approve it as manager.
9. Approve/finalize it as security admin.
10. View audit logs for the full transaction history.
