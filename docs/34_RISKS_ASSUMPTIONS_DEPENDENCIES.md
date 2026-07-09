# Risks, Assumptions, and Dependencies

## Assumptions

- Oracle Fusion remains the ERP/source of truth.
- Phase 1 has no Oracle credentials.
- Phase 1 uses seeded users and mock Fusion adapter.
- The app must support iOS and Android.
- Cost and speed matter.
- Admin functions can live inside the same Flutter app.
- Arabic/English are required.
- Security access workflow requires auditability.
- The client will provide Oracle/SSO/deployment details for Phase 2.

## Key risks

| Risk | Impact | Mitigation |
|---|---|---|
| Oracle endpoint details unavailable | Integration delay | Build adapter boundary now |
| SSO details unavailable | Deployment delay | Use mock login in Phase 1 |
| App Store accounts not ready | Mobile deployment delay | Use Android APK/TestFlight/Flutter web demo |
| Scope expands beyond notifications/access | Timeline risk | Keep MVP scope locked |
| Security review adds controls | Rework risk | Build RBAC/audit/secrets discipline now |
| Brand assets unavailable | UI delay | Use neutral theme placeholders |
| Push notification certificates unavailable | Delay | Implement in-app notifications first |
| Manager hierarchy unclear | Workflow risk | Seed manager relation and make source configurable |

## Dependencies for Phase 2

### Oracle

- Fusion base URL
- API authentication method
- Endpoint list
- Role catalog source
- Access provisioning method
- Rate limits
- Sandbox credentials
- Error response examples

### Identity

- SSO provider
- Client ID
- Tenant ID/issuer
- Redirect URIs
- Mobile auth flow requirements
- Test users

### Deployment

- Hosting target
- Database target
- Network/firewall rules
- SSL certificates
- Domain names
- Monitoring/logging requirements

### Mobile

- Apple developer account
- Google Play account
- Bundle/application IDs
- Signing keys
- Distribution method
- Push notification setup

## Scope control

The MVP must stay focused on:

1. Notifications.
2. Security access requests.
3. Approvals.
4. Audit.
5. Oracle adapter readiness.

Do not add:

- Chat
- AI assistant
- Visitor app features
- Digital ID
- QR access
- Facility access hardware integration
- Payment
- Vendor onboarding
- HR self-service

unless explicitly moved to Phase 2/3.

## Decision log

| Date | Decision | Owner | Notes |
|---|---|---|---|
| 2026-07-09 | Use Flutter + NestJS + PostgreSQL | Project | Initial build spec |
| 2026-07-09 | Use mock Fusion adapter for Phase 1 | Project | Real integration later |
