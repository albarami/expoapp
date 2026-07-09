# Iterative Cursor Prompts

Use these prompts if Cursor gets stuck or starts building shallow code.

## Prompt 1 — Force full backend

```text
Read /docs/07_DATA_MODEL.md, /docs/08_DATABASE_SCHEMA_PRISMA.md, /docs/10_API_CONTRACT.md, and /docs/11_BACKEND_NESTJS_SPEC.md again. Implement the backend as a real NestJS API with Prisma/PostgreSQL persistence. Do not use in-memory arrays for business data. Add seed data and make the endpoints work through Swagger.
```

## Prompt 2 — Force real workflow

```text
The access request workflow must be real. Implement request submission, manager approval task generation, security approval task generation, status transitions, timeline events, and audit logs exactly as described in /docs/16_ACCESS_REQUESTS_WORKFLOW.md and /docs/17_APPROVAL_ENGINE.md. Do not fake workflow state in the Flutter UI.
```

## Prompt 3 — Force Flutter API integration

```text
Read /docs/12_FLUTTER_ARCHITECTURE.md, /docs/13_NAVIGATION_AND_STATE.md, and /docs/20_MOBILE_SCREEN_SPECIFICATIONS.md. Replace any hardcoded screen data with API repository calls. Use Riverpod AsyncValue loading/error/data states. The Flutter app must call the NestJS backend for notifications, access requests, approvals, audit logs, and dashboard summary.
```

## Prompt 4 — Force localization

```text
Audit the Flutter app for hardcoded user-facing strings. Move all labels, buttons, empty states, validation messages, and error messages into app_en.arb and app_ar.arb. Ensure Arabic triggers RTL layout and no main screen overflows.
```

## Prompt 5 — Force RBAC

```text
Implement backend RBAC guards for all protected endpoints and frontend route guards for restricted screens. Employee must not access notification creation or audit logs. Manager must only decide assigned tasks. Security admin must only decide security tasks assigned to them unless explicitly allowed.
```

## Prompt 6 — Force acceptance demo

```text
Run through /docs/32_ACCEPTANCE_CRITERIA_DEMO.md. Fix every failing item. The demo must show admin notification creation, employee notification read, employee access request submission, manager approval, security approval, completed status, and audit log trail.
```

## Prompt 7 — Clean README

```text
Update root README.md with exact local setup commands, demo credentials, repo structure, API docs URL, mobile run commands, and known limitations. A new developer must be able to run the system from clean checkout.
```

## Prompt 8 — Prevent shallow implementation

```text
Search the codebase for TODO, placeholder, hardcoded demo arrays in Flutter screens, and fake service methods that bypass the API/database. Replace them with real implementation matching /docs.
```
