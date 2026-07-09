# Cursor Build Tasks

Use this as the implementation checklist.

## Task 0 — Read documentation

- [ ] Read all files in `/docs`.
- [ ] Use `01_MASTER_CURSOR_PROMPT.md` as instruction.
- [ ] Do not build before reading data model, API contract, and screens.

## Task 1 — Scaffold repository

- [ ] Create root README.
- [ ] Create `.gitignore`.
- [ ] Create `.env.example`.
- [ ] Create `docker-compose.yml`.
- [ ] Create `apps/api`.
- [ ] Create `apps/mobile`.

## Task 2 — Backend foundation

- [ ] Create NestJS app.
- [ ] Add config module.
- [ ] Add Prisma.
- [ ] Add health endpoint.
- [ ] Add global validation pipe.
- [ ] Add global exception filter.
- [ ] Add Swagger.
- [ ] Add request trace ID.

## Task 3 — Database

- [ ] Implement Prisma schema.
- [ ] Generate migration.
- [ ] Implement seed script.
- [ ] Verify seed idempotency.
- [ ] Add demo users.

## Task 4 — Auth/RBAC

- [ ] Implement login.
- [ ] Implement JWT.
- [ ] Implement `/auth/me`.
- [ ] Implement guards/decorators.
- [ ] Implement role permission mapping.
- [ ] Add auth audit events.

## Task 5 — Reference data

- [ ] Implement departments.
- [ ] Implement systems.
- [ ] Implement security roles.
- [ ] Implement `/reference-data`.

## Task 6 — Notifications backend

- [ ] Implement create notification DTO.
- [ ] Implement audience resolver.
- [ ] Implement recipient creation.
- [ ] Implement list notifications.
- [ ] Implement detail/read.
- [ ] Implement stats.
- [ ] Implement audit events.
- [ ] Add tests.

## Task 7 — Access requests backend

- [ ] Implement create request DTO.
- [ ] Implement validation.
- [ ] Implement request number generation.
- [ ] Implement workflow state.
- [ ] Implement approval task generation.
- [ ] Implement request list/detail/cancel.
- [ ] Implement events/timeline.
- [ ] Implement audit events.
- [ ] Add tests.

## Task 8 — Approvals backend

- [ ] Implement approval list.
- [ ] Implement decision endpoint.
- [ ] Implement manager approve/reject.
- [ ] Implement security approve/reject.
- [ ] Implement mock provisioning.
- [ ] Implement audit events.
- [ ] Add tests.

## Task 9 — Fusion adapter

- [ ] Create adapter interface.
- [ ] Create mock adapter.
- [ ] Create real adapter scaffold.
- [ ] Wire provider based on `FUSION_MODE`.

## Task 10 — Audit backend

- [ ] Implement audit service.
- [ ] Implement audit list endpoint.
- [ ] Implement filters.
- [ ] Protect endpoint by roles.

## Task 11 — Flutter foundation

- [ ] Create Flutter app.
- [ ] Add packages.
- [ ] Configure theme.
- [ ] Configure localization.
- [ ] Configure GoRouter.
- [ ] Configure Riverpod.
- [ ] Build API client.
- [ ] Build token storage.
- [ ] Build session controller.

## Task 12 — Flutter auth

- [ ] Build login screen.
- [ ] Build demo login buttons.
- [ ] Call backend login.
- [ ] Store tokens.
- [ ] Route after login.
- [ ] Logout.

## Task 13 — Flutter dashboard

- [ ] Build role-based dashboard.
- [ ] Fetch summary from API.
- [ ] Show metrics/latest items.
- [ ] Add loading/error states.

## Task 14 — Flutter notifications

- [ ] Build list.
- [ ] Build details.
- [ ] Mark as read.
- [ ] Build admin create notification.
- [ ] Build stats view.
- [ ] Add filters/search.
- [ ] Add loading/error/empty states.

## Task 15 — Flutter access requests

- [ ] Build my requests list.
- [ ] Build new request form.
- [ ] Fetch reference data.
- [ ] Submit request.
- [ ] Build request detail/timeline.
- [ ] Cancel if allowed.

## Task 16 — Flutter approvals

- [ ] Build approval queue.
- [ ] Build approval detail.
- [ ] Approve/reject with comment.
- [ ] Refresh dashboard/list after decision.

## Task 17 — Flutter audit

- [ ] Build audit logs screen.
- [ ] Add filters.
- [ ] Add metadata modal.
- [ ] Protect route.

## Task 18 — Localization/RTL

- [ ] Create EN/AR ARB files.
- [ ] Replace hardcoded strings.
- [ ] Test RTL screens.
- [ ] Add language switcher.

## Task 19 — QA

- [ ] Run backend tests.
- [ ] Run Flutter analyze.
- [ ] Run Flutter tests.
- [ ] Complete manual demo scenarios.
- [ ] Fix failures.

## Task 20 — Final polish

- [ ] Review design consistency.
- [ ] Remove core TODOs.
- [ ] Update README.
- [ ] Verify commands.
- [ ] Ensure project builds from clean checkout.
