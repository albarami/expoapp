# Demo Acceptance Criteria

## Purpose

This file defines what must work when presenting the system to Expo Saudi stakeholders.

## Build readiness

- [ ] Repo can be cloned.
- [ ] Docs exist under `/docs`.
- [ ] Backend runs locally.
- [ ] Mobile app runs locally.
- [ ] Seed data exists.
- [ ] Demo users can login.

## Backend acceptance

- [ ] `GET /health` returns ok.
- [ ] Swagger available at `/docs`.
- [ ] `POST /auth/login` works for all demo users.
- [ ] `GET /dashboard/summary` returns role-aware summary.
- [ ] `POST /notifications` creates notification as admin.
- [ ] Employee cannot call `POST /notifications`.
- [ ] `GET /notifications` returns user-specific notifications.
- [ ] `PATCH /notifications/:id/read` updates read status.
- [ ] `POST /access-requests` creates request and approval task.
- [ ] `GET /approvals` returns assigned tasks.
- [ ] Approval decision advances workflow.
- [ ] Security approval completes request in mock mode.
- [ ] `GET /audit-logs` returns events for admins only.

## Mobile acceptance

- [ ] Login screen works.
- [ ] Demo quick login buttons work in local/demo mode.
- [ ] Dashboard changes by role.
- [ ] Notifications list/detail works.
- [ ] Admin can create notification.
- [ ] Employee can submit request.
- [ ] Employee can track request.
- [ ] Manager can approve/reject.
- [ ] Security admin can approve/reject.
- [ ] Audit logs visible to admin/security admin.
- [ ] Employee cannot access admin screens.
- [ ] Arabic language works.
- [ ] RTL layout works.

## Demo script

### Part 1 — Fast app layer

Say:

```text
Oracle Fusion remains the ERP. This app is the fast mobile layer on top of it. The first version runs with production-shaped mock data and a real backend, so integration can be added without changing the user experience.
```

### Part 2 — Notification demo

1. Login as System Admin.
2. Show dashboard.
3. Create notification.
4. Select all users or Operations.
5. Publish.
6. Show recipient count.
7. Login as Noura.
8. Open notification.
9. Mark as read.

### Part 3 — Access request demo

1. Login as Noura.
2. Submit access request.
3. Show request status.
4. Login as Faisal.
5. Approve manager task.
6. Login as Reem.
7. Approve security task.
8. Show completed status and mock Fusion ID.

### Part 4 — Governance demo

1. Login as System Admin or Security Admin.
2. Open audit logs.
3. Show full transaction history.
4. Explain Oracle integration adapter.

## Failure conditions

The demo is not acceptable if:

- Screens are static with no backend.
- User roles do not change behavior.
- Approval workflow does not change status.
- Audit logs are missing.
- Arabic support is absent.
- Backend cannot be run locally.
- API calls are hardcoded inside UI widgets.
