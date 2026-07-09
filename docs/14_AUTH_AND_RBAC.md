# Authentication and RBAC

## Phase 1 authentication

Use mock username/password login backed by seeded users.

The backend returns:

- JWT access token
- refresh token or mock refresh token
- current user profile
- role
- permissions

## Phase 2 authentication

Replace mock login with SSO/OIDC when Expo provides identity provider details. Likely options:

- Microsoft Entra ID
- Oracle Identity / OCI IAM
- Other government identity provider

The app architecture must make this replacement straightforward.

## Backend JWT payload

JWT must include:

```json
{
  "sub": "user-uuid",
  "email": "admin@expo.sa",
  "role": "SYSTEM_ADMIN"
}
```

Do not include sensitive personal data in JWT.

## Password handling

For mock mode:

- Use bcrypt hashed password in DB.
- Default password only in seed data.
- Never log password.
- Never return password hash.

## Permissions

Permissions are derived from role.

Example permission map:

```ts
const ROLE_PERMISSIONS = {
  EMPLOYEE: [
    'notifications:read',
    'accessRequests:create',
    'accessRequests:readOwn'
  ],
  MANAGER: [
    'notifications:read',
    'accessRequests:create',
    'accessRequests:readOwn',
    'approvals:manager'
  ],
  SECURITY_ADMIN: [
    'notifications:read',
    'accessRequests:create',
    'accessRequests:readOwn',
    'approvals:security',
    'audit:read'
  ],
  SYSTEM_ADMIN: [
    'notifications:read',
    'notifications:create',
    'notifications:publish',
    'notifications:stats',
    'accessRequests:readAll',
    'audit:read'
  ]
};
```

## Backend guards

Use:

- `JwtAuthGuard`
- `RolesGuard`
- Optional `PermissionsGuard`

Example:

```ts
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.SYSTEM_ADMIN)
@Post()
createNotification(...) {}
```

## UI access control

The UI must:

- Hide unauthorized tabs.
- Hide unauthorized action buttons.
- Show "Not authorized" if user navigates manually to restricted path.
- Use backend error response as final authority.

## Session expiration

When API returns 401:

1. Clear tokens.
2. Clear session state.
3. Redirect to login.
4. Show message: "Your session has expired. Please sign in again."

Arabic:

```text
انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.
```

## Security assumptions

- Phase 1 uses demo authentication.
- Phase 2 must integrate SSO.
- Production must use HTTPS only.
- Tokens must be short-lived.
- Refresh token rotation should be implemented in production.
- MDM or private app distribution may be required depending on Expo policy.

## Login screen requirements

Fields:

- Email
- Password
- Language toggle
- Login button

Validation:

- Email required and valid format.
- Password required.
- Show friendly invalid credentials message.

Demo quick buttons:

- Employee
- Manager
- Security Admin
- System Admin

These buttons should be hidden if `ENABLE_DEMO_LOGIN=false`.
