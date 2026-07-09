# Oracle Fusion Integration Mapping

## Purpose

Define how ExpoApp data maps to future Oracle Fusion/OIC integration.

## Key principle

The app must not depend on exact Oracle API fields in Flutter. Internal DTOs stay stable. The Fusion adapter maps internal DTOs to Oracle/OIC-specific payloads.

## Identity mapping

| ExpoApp field | Source now | Future source |
|---|---|---|
| `User.id` | ExpoApp UUID | ExpoApp UUID |
| `User.externalRef` | Seed value | Oracle person/user GUID or SSO subject |
| `User.employeeNumber` | Seed value | Oracle employee/person number |
| `User.email` | Seed value | SSO/Oracle work email |
| `User.department.code` | Seed value | Oracle department/org code |
| `User.manager.externalRef` | Seed relation | Oracle manager/person relationship |

## Role catalog mapping

| ExpoApp field | Future Oracle/OIC source |
|---|---|
| `AppSystem.code` | System/application code agreed with security team |
| `SecurityRoleCatalog.code` | Oracle role code or OIC role code |
| `SecurityRoleCatalog.nameEn` | Role display name |
| `SecurityRoleCatalog.riskLevel` | Security governance mapping |
| `requiresManagerApproval` | ExpoApp workflow policy or OIC policy |
| `requiresSecurityApproval` | ExpoApp workflow policy or OIC policy |

## Access request outbound payload

Internal DTO:

```json
{
  "requestNumber": "AR-2026-000001",
  "requesterExternalRef": "FUSION_PERSON_1001",
  "systemCode": "ORACLE_FUSION_ERP",
  "roleCode": "FUSION_AP_INQUIRY",
  "justification": "Need temporary inquiry access for vendor invoice validation.",
  "startDate": "2026-07-10",
  "endDate": "2026-08-10",
  "approvedByExternalRefs": [
    "FUSION_PERSON_2001",
    "FUSION_PERSON_3001"
  ]
}
```

Potential OIC payload:

```json
{
  "sourceSystem": "EXPOAPP",
  "requestId": "AR-2026-000001",
  "personRef": "FUSION_PERSON_1001",
  "application": "ORACLE_FUSION_ERP",
  "entitlement": "FUSION_AP_INQUIRY",
  "businessReason": "Need temporary inquiry access for vendor invoice validation.",
  "validFrom": "2026-07-10",
  "validTo": "2026-08-10",
  "approvals": [
    {
      "approverRef": "FUSION_PERSON_2001",
      "stage": "MANAGER"
    },
    {
      "approverRef": "FUSION_PERSON_3001",
      "stage": "SECURITY"
    }
  ]
}
```

## Provisioning result mapping

| Oracle/OIC response | ExpoApp field |
|---|---|
| external request id | `AccessRequest.externalFusionRequestId` |
| submitted/in progress | `PROVISIONING` |
| success/completed | `COMPLETED` |
| rejected/failed | `FAILED` or `SECURITY_REJECTED` depending stage |
| error message | `IntegrationOutbox.lastError` and request event metadata |

## Sync strategy

### Phase 1

Seed data only.

### Phase 2 minimum

Manual or scheduled sync of:

- Users
- Departments
- Role catalog

### Phase 2 better

Automated scheduled sync:

```text
Every 15 minutes:
  sync users changed recently
  sync departments
  sync role catalog

Every 5 minutes:
  check provisioning statuses for in-progress requests
```

### Phase 3 advanced

Event-driven integration via OIC events/callbacks.

## Caching strategy

Cache reference data:

- departments
- systems
- security roles
- role policy

Cache TTL:

- local/demo: no strict TTL
- production: 5-15 minutes depending client policy

## Required client decisions

Before real integration, client must answer:

1. Are access requests for Oracle Fusion roles specifically or all enterprise applications?
2. Is Oracle Fusion Security Console the final role source?
3. Is Oracle Integration Cloud available?
4. Will provisioning be automatic or task-based/manual?
5. Which identity provider is authoritative?
6. Are temporary access expiries enforced in Oracle?
7. Is manager hierarchy from Oracle HCM or another HR system?
8. Who owns the security role catalog and risk ratings?
