# Security and Privacy

## Security stance

This is a security-related workflow app. Even in mock mode, code must be written as if it will later go through enterprise review.

## Core requirements

- Backend authorization is mandatory.
- JWT tokens stored securely on mobile.
- No secrets in repository.
- No sensitive data in logs.
- Audit log for all security access actions.
- Role-based UI and API protection.
- HTTPS required in deployed environments.
- CORS controlled by environment.

## Data sensitivity

Data handled by app:

- Employee name
- Email
- Employee number
- Department
- Manager relationship
- Access request justification
- Security roles requested
- Approval comments
- Audit events

Treat all as internal confidential data.

## Authentication

Phase 1:

- Demo JWT auth.
- Seeded users.
- Bcrypt password hashing preferred.

Phase 2:

- SSO/OIDC.
- Production token policies.
- Device/session management.

## Authorization

Must be enforced server-side.

Do not rely on:

- Flutter route hiding
- UI conditions
- User-provided role in request body

Always derive user from JWT.

## Input validation

Backend DTO validation required for:

- Login
- Create notification
- Access request submit
- Approval decision
- Audit log filters

Use `class-validator`.

## Output filtering

Employee API responses must not include unrelated users' data.

Manager responses must be scoped to:

- own data
- assigned approval tasks
- direct report requests assigned to them

Security admin responses must be scoped to security workflow.

System admin can see broad data but should still avoid unnecessary sensitive fields.

## Logging rules

Never log:

- Passwords
- JWT tokens
- Oracle client secrets
- Full Authorization headers
- Raw Oracle access tokens

Mask:

- long tokens
- secrets
- sensitive integration payloads

## Audit immutability

Phase 1:

- No update/delete audit log API.

Production:

- Consider append-only storage or DB permissions preventing updates.
- Define retention with client.

## Mobile security

Use `flutter_secure_storage` for tokens.

Do not store:

- passwords
- secrets
- Oracle credentials
- full audit exports

## API security headers

Use Helmet in NestJS if possible.

## Rate limiting

Optional in Phase 1. Recommended in Phase 2:

- Login endpoint rate limiting.
- Notification creation throttling.
- Approval decision idempotency.

## Idempotency

For production:

- Notification publish should prevent duplicate recipient creation.
- Approval decision should reject already-decided task.
- Oracle provisioning should use request number as idempotency key where possible.

## Security review checklist

- [ ] Employee cannot create notification.
- [ ] Employee cannot view audit logs.
- [ ] Employee cannot approve own request unless assigned by policy, which should not happen.
- [ ] Manager cannot approve requests not assigned to them.
- [ ] Security admin cannot bypass manager approval unless policy says so.
- [ ] JWT required for protected endpoints.
- [ ] All critical events audited.
- [ ] No secrets committed.
- [ ] `.env` ignored.
