# Oracle References and Integration Notes

## Purpose

This document records the official Oracle documentation areas Cursor/developers should use when implementing Phase 2 integration.

## Official reference areas

Oracle publishes REST API documentation for Oracle Fusion Cloud Applications and HCM. The current public documentation pages indicate that Oracle REST APIs are used to view and manage data stored in Fusion Cloud Applications/HCM and include quick starts, use cases, and resource details.

Use the latest Oracle documentation at implementation time because Fusion API versions and available resources can vary by release and tenant configuration.

## Integration guidance for this project

Do not assume a specific Oracle endpoint until the client provides the actual module, process, and credentials. The app must therefore use:

```text
FusionAdapter interface
  -> MockFusionAdapter for Phase 1
  -> OracleFusionAdapter/OIC adapter for Phase 2
```

## Information needed from Oracle team

| Area | Required details |
|---|---|
| Tenant | Base URL, environment name, sandbox/prod |
| Auth | OAuth/basic/service account details, token URL, scopes |
| Identity | User/person identifier, employee number source |
| Manager hierarchy | HCM source and lookup endpoint/report |
| Role catalog | Role source, role code, display name, risk rating |
| Provisioning | REST endpoint, OIC process, or manual workflow |
| Status | Status lookup API/callback method |
| Errors | Error payloads and retry behavior |
| Limits | Rate limits and throttling |
| Security | IP allowlisting, certificate/VPN requirements |

## Implementation sequence for Phase 2

1. Confirm exact Oracle/OIC process.
2. Map current `SecurityRoleCatalog` to Oracle role codes.
3. Implement token acquisition in `OracleFusionAdapter`.
4. Implement read operations.
5. Implement provisioning submission.
6. Implement status polling/callback.
7. Enable outbox retries.
8. Test against Oracle sandbox.
9. Add production secrets/environment.
10. Disable demo auth and mock mode.

## No direct mobile integration

The Flutter app must never store Oracle credentials and must never call Oracle Fusion directly.
