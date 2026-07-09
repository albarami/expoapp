# Oracle Fusion Adapter Specification

## Purpose

Prepare the system for Oracle Fusion integration without blocking Phase 1.

Oracle Fusion must remain the source of truth for ERP/security records where applicable. ExpoApp must not call Oracle Fusion directly from the mobile app. Only the backend adapter may call Oracle/OIC.

## Adapter modes

| Mode | Description |
|---|---|
| `mock` | Uses seeded database data and fake provisioning responses |
| `fusion` | Calls Oracle Fusion/OIC endpoints |
| `hybrid` | Future option: reads from cache but writes to Oracle |

Environment variable:

```bash
FUSION_MODE=mock
```

## Adapter interface

Create:

```text
apps/api/src/fusion/fusion-adapter.interface.ts
```

Interface:

```ts
export interface FusionEmployeeProfile {
  externalRef: string;
  employeeNumber: string;
  fullNameEn: string;
  fullNameAr?: string;
  email: string;
  departmentCode?: string;
  managerExternalRef?: string;
}

export interface RoleCatalogQuery {
  systemCode?: string;
  search?: string;
}

export interface FusionSecurityRole {
  externalRoleId: string;
  systemCode: string;
  code: string;
  nameEn: string;
  nameAr?: string;
  description?: string;
  riskLevel: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';
}

export interface ValidateFusionAccessRequestInput {
  requesterExternalRef: string;
  systemCode: string;
  roleCode: string;
}

export interface ValidationResult {
  valid: boolean;
  code?: string;
  message?: string;
}

export interface SubmitFusionProvisioningInput {
  requestNumber: string;
  requesterExternalRef: string;
  systemCode: string;
  roleCode: string;
  justification: string;
  startDate?: string;
  endDate?: string;
  approvedByExternalRefs: string[];
}

export interface FusionProvisioningResult {
  externalRequestId: string;
  status: 'SUBMITTED' | 'COMPLETED' | 'FAILED';
  message?: string;
}

export interface FusionProvisioningStatus {
  externalRequestId: string;
  status: 'SUBMITTED' | 'IN_PROGRESS' | 'COMPLETED' | 'FAILED';
  message?: string;
}

export interface FusionAdapter {
  getEmployeeProfile(userExternalRef: string): Promise<FusionEmployeeProfile>;
  listAvailableSecurityRoles(input: RoleCatalogQuery): Promise<FusionSecurityRole[]>;
  validateAccessRequest(input: ValidateFusionAccessRequestInput): Promise<ValidationResult>;
  submitAccessProvisioning(input: SubmitFusionProvisioningInput): Promise<FusionProvisioningResult>;
  getProvisioningStatus(externalRequestId: string): Promise<FusionProvisioningStatus>;
}
```

## MockFusionAdapter

Create:

```text
apps/api/src/fusion/mock-fusion.adapter.ts
```

Behavior:

- `getEmployeeProfile` returns matching seeded user.
- `listAvailableSecurityRoles` returns seeded role catalog.
- `validateAccessRequest` returns valid if role exists and active.
- `submitAccessProvisioning` returns fake external request ID.
- `getProvisioningStatus` returns completed for mock IDs.

Example mock external ID:

```text
MOCK-FUSION-AR-2026-000001
```

## OracleFusionAdapter scaffold

Create:

```text
apps/api/src/fusion/oracle-fusion.adapter.ts
```

The class should exist but can throw a clear configuration error if real settings are missing.

Required config:

```bash
FUSION_BASE_URL=
FUSION_CLIENT_ID=
FUSION_CLIENT_SECRET=
FUSION_TOKEN_URL=
FUSION_SCOPE=
```

## Real integration strategy

The exact Oracle endpoint depends on the client's Fusion modules, security configuration, identity setup, and whether they use Oracle Integration Cloud.

Preferred production strategy:

```text
ExpoApp API -> Oracle Integration Cloud process/API -> Oracle Fusion
```

Alternative:

```text
ExpoApp API -> Oracle Fusion REST APIs
```

Only if Oracle team confirms exact APIs and permissions.

## Integration operations required

### Read operations

- Get employee profile by external reference/email.
- Get manager reference.
- Get active user status.
- Get requestable security roles.
- Validate whether role exists and is active.

### Write operations

- Submit approved access provisioning request.
- Store external Oracle/Fusion request ID.
- Check provisioning status.
- Optionally revoke/expire temporary access in future.

## Integration outbox

For production mode, use `IntegrationOutbox` for provisioning operations:

1. Final approval writes outbox item.
2. Worker submits to Oracle/OIC.
3. On success, update request external ID/status.
4. On failure, retry with backoff.
5. After max attempts, mark failed and alert admin.

## Security requirements

- Store Oracle credentials only in environment/secrets manager.
- Use HTTPS.
- Do not log access tokens.
- Do not log full Oracle responses if sensitive.
- Mask personal data in errors.
- Restrict integration endpoints to backend only.

## Controller rule

No controller should call `OracleFusionAdapter` directly. Controllers call services. Services call `FusionAdapter`.

## Future endpoints from Oracle team

Expo/client must provide a filled integration worksheet:

| Required item | Value |
|---|---|
| Fusion tenant base URL | TBD |
| Authentication method | TBD |
| Token URL | TBD |
| Client ID | TBD |
| Scope/resource | TBD |
| Employee lookup endpoint | TBD |
| Security role catalog endpoint/process | TBD |
| Access request/provisioning endpoint/process | TBD |
| Callback endpoint requirement | TBD |
| Error code mapping | TBD |
| Rate limits | TBD |
