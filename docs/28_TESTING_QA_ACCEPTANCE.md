# Testing, QA, and Acceptance

## Testing goal

Prove that the app is not a static prototype. It must work end-to-end with real API/database/mock adapter.

## Backend test types

### Unit tests

- Auth service
- Notification audience resolver
- Access request validation
- Approval workflow transitions
- Audit service calls
- Fusion mock adapter

### Integration tests

- Login returns token.
- Protected route rejects missing token.
- Admin creates notification and recipients are created.
- Employee sees notification.
- Employee marks notification read.
- Employee submits access request.
- Manager approval creates security task.
- Security approval completes request in mock mode.
- Audit logs are written.

## Flutter test types

Minimum widget tests:

- Login validation.
- Dashboard renders for each role.
- Notification card renders localized title.
- Access request form validation.
- Approval decision confirmation.

Manual acceptance testing is more important for Phase 1 if time is short.

## Required manual demo scenarios

### Scenario 1: Employee notification

1. Login as `admin@expo.sa`.
2. Create notification for all users.
3. Logout.
4. Login as `noura.alharbi@expo.sa`.
5. Open notifications.
6. See notification.
7. Open details.
8. Mark as read.
9. Dashboard unread count decreases.

Pass criteria:

- Notification created through API.
- Recipient record exists.
- Read timestamp updates.
- Audit log exists.

### Scenario 2: Access request approval

1. Login as Noura.
2. Submit access request for Oracle Fusion ERP / AP Inquiry.
3. Confirm request status is pending manager.
4. Logout.
5. Login as Faisal.
6. Open approvals.
7. Approve Noura's request.
8. Confirm status becomes pending security.
9. Logout.
10. Login as Reem.
11. Open security approvals.
12. Approve request.
13. Confirm request becomes completed in mock mode.
14. View audit logs.

Pass criteria:

- Status transitions correctly.
- Manager cannot be skipped.
- Security task generated.
- External mock Fusion ID saved.
- Audit logs show each step.

### Scenario 3: Unauthorized access

1. Login as employee.
2. Attempt to navigate to audit logs.
3. UI blocks route or shows unauthorized.
4. Direct API call to `/audit-logs` with employee token returns 403.

Pass criteria:

- Backend enforcement works.

### Scenario 4: Arabic UI

1. Switch language to Arabic.
2. Navigate dashboard, notifications, requests.
3. Confirm RTL layout.
4. Confirm Arabic strings display.
5. Submit request.

Pass criteria:

- No layout overflow.
- Key actions localize.

## Acceptance checklist

- [ ] Backend starts successfully.
- [ ] Swagger available.
- [ ] Database migration works.
- [ ] Seed script works idempotently.
- [ ] All demo logins work.
- [ ] Flutter app starts on Android emulator.
- [ ] Flutter app starts on iOS simulator where available.
- [ ] Dashboard displays role-specific data.
- [ ] Notifications workflow works.
- [ ] Access request workflow works.
- [ ] Approval workflow works.
- [ ] Audit logs work.
- [ ] Arabic/English switching works.
- [ ] Unauthorized routes are blocked.
- [ ] No core TODO placeholders remain.
- [ ] README run commands are accurate.

## Definition of done

A feature is done only when:

- Backend endpoint exists.
- Endpoint is documented in Swagger.
- DTO validation exists.
- Authorization exists.
- Flutter repository calls endpoint.
- UI screen uses real API data.
- Loading/error/empty states exist.
- Audit log exists where relevant.
- Manual scenario passes.
