# Product Scope and Delivery Definition

## Product name

Working name: **ExpoApp**

## Business objective

Provide Expo Saudi employees, managers, and security administrators with a fast mobile-first application for communication and security access request workflows while keeping Oracle Fusion as the main ERP and source of truth.

## Problem statement

Oracle Fusion is powerful but may not provide the speed, simplicity, and mobile experience needed for high-frequency operational workflows such as mass notifications and access requests. Users need a fast app that hides ERP complexity while preserving governance, approval controls, and auditability.

## Product positioning

ExpoApp is an experience layer and workflow accelerator. It is not an ERP replacement.

```text
Mobile App -> ExpoApp API -> ExpoApp Operational DB/Cache -> Oracle Fusion Adapter -> Oracle Fusion
```

## Phase 1 outcome: complete runnable system with production-shaped mock data

Phase 1 must deliver a complete system that works end-to-end without Oracle access:

- Real mobile app
- Real backend API
- Real database
- Seeded enterprise-style data
- Real role-based workflows
- Mock Fusion adapter
- No dependency on Oracle credentials
- No dependency on Apple/Google production accounts

## Phase 2 outcome: Oracle integration and deployment

Phase 2 replaces mock adapter calls with Oracle Fusion integration where the client provides:

- Fusion base URL
- API credentials or OAuth details
- Required role catalog source
- Security role provisioning method
- SSO identity provider details
- Network/VPN/IP allowlist requirements
- Deployment environment details
- App Store, Google Play, or MDM publishing path

## In scope for Phase 1

### Mobile app

- iOS support
- Android support
- English and Arabic support
- Mock login
- Role-based dashboard
- Notifications inbox
- Notification details
- Access request submission
- My request status list
- Manager approval queue
- Security approval queue
- Admin notification creation
- Audit log viewer for authorized users
- Profile/settings

### Backend

- Authentication
- Users
- Roles
- Departments
- Notification CRUD/publishing
- Notification recipients/read receipts
- Access request workflow
- Approval task generation
- Audit logging
- Reference data
- Mock Fusion adapter
- Swagger documentation
- Seed data

## Out of scope for Phase 1

These must be documented and structurally prepared, but not fully connected:

- Real Oracle Fusion API calls
- Real SSO
- Real push notification delivery through APNs/FCM
- Production cloud deployment
- Penetration testing
- App Store / Google Play publishing
- MDM configuration
- Formal Oracle security role provisioning

## In scope for Phase 2

- Replace mock auth with SSO/OIDC.
- Replace mock Fusion adapter with real Oracle Fusion REST/OIC calls.
- Configure push notification infrastructure.
- Complete security hardening.
- Complete cloud deployment.
- Complete mobile distribution.
- Conduct UAT and production readiness review.

## Success metrics

| Metric | Target |
|---|---:|
| Cold app launch to dashboard after saved login | < 2.5 seconds on normal device |
| API p95 response for dashboard | < 500 ms on local/mock setup |
| Notification publish action | < 1 second API response |
| Access request submission | < 1 second API response |
| Workflow audit coverage | 100% of submit/approve/reject/complete actions |
| Supported languages | English + Arabic |
| Supported roles | Employee, Manager, Security Admin, System Admin |

## Primary use cases

1. System admin sends a notification to all employees.
2. System admin sends a notification to a department or role.
3. Employee reads notification and marks it as read.
4. Employee requests access to a system/security role.
5. Manager approves or rejects.
6. Security admin approves, rejects, or completes provisioning.
7. Admin reviews audit trail.

## Product constraints

- The mobile app must be fast.
- The first version must be buildable from these docs alone.
- Oracle Fusion must not be called directly from the mobile app.
- The backend must be the single integration boundary.
- Every important business action must be audited.
- UI copy must be localizable.
- The app must be clean enough to show to executive stakeholders.
