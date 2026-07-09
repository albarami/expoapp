# Seed Data Specification

Create `apps/api/prisma/seed.ts`.

The seed must allow a complete demo without manual database work.

## Demo login behavior

For Phase 1, use seeded users with password:

```text
Password123!
```

Store the password as a bcrypt hash in `User.passwordHash`.

## Required departments

| Code | English name | Arabic name |
|---|---|---|
| `OPS` | Operations | العمليات |
| `SEC` | Security | الأمن |
| `TECH` | Technology | التقنية |
| `FIN` | Finance | المالية |
| `HR` | Human Resources | الموارد البشرية |

## Required users

| Role | Email | Name EN | Name AR | Employee # | Department |
|---|---|---|---|---|---|
| Employee | `noura.alharbi@expo.sa` | Noura Alharbi | نورة الحربي | E1001 | Operations |
| Employee | `salem.alqahtani@expo.sa` | Salem Alqahtani | سالم القحطاني | E1002 | Operations |
| Manager | `faisal.otaibi@expo.sa` | Faisal Otaibi | فيصل العتيبي | M2001 | Operations |
| Security Admin | `reem.security@expo.sa` | Reem Almutairi | ريم المطيري | S3001 | Security |
| System Admin | `admin@expo.sa` | Expo System Admin | مدير النظام | A9001 | Technology |

Relationships:

- Noura reports to Faisal.
- Salem reports to Faisal.
- Faisal has no manager in seed data.
- Reem has no manager in seed data.
- Admin has no manager in seed data.

## Required systems

| Code | Name EN | Name AR | Description |
|---|---|---|---|
| `ORACLE_FUSION_ERP` | Oracle Fusion ERP | أوراكل فيوجن المالي | Finance and procurement ERP access |
| `ORACLE_FUSION_HCM` | Oracle Fusion HCM | أوراكل فيوجن الموارد البشرية | HR and employee data access |
| `SECURITY_PORTAL` | Security Operations Portal | بوابة العمليات الأمنية | Security operations access |
| `EVENT_OPS` | Event Operations Dashboard | لوحة عمليات الفعالية | Event operation dashboards |
| `VENDOR_PORTAL` | Vendor Management Portal | بوابة إدارة الموردين | Vendor onboarding and management |

## Required security roles

| System | Code | Name EN | Risk | Manager approval | Security approval |
|---|---|---|---|---:|---:|
| Oracle Fusion ERP | `FUSION_AP_INQUIRY` | Accounts Payable Inquiry | MEDIUM | Yes | Yes |
| Oracle Fusion ERP | `FUSION_PROCUREMENT_REQUESTER` | Procurement Requester | MEDIUM | Yes | Yes |
| Oracle Fusion ERP | `FUSION_FINANCE_MANAGER` | Finance Manager Access | HIGH | Yes | Yes |
| Oracle Fusion HCM | `FUSION_HCM_EMPLOYEE_VIEW` | HCM Employee View | MEDIUM | Yes | Yes |
| Oracle Fusion HCM | `FUSION_HCM_MANAGER_VIEW` | HCM Manager View | HIGH | Yes | Yes |
| Security Portal | `SECURITY_INCIDENT_VIEWER` | Incident Viewer | MEDIUM | Yes | Yes |
| Security Portal | `SECURITY_INCIDENT_MANAGER` | Incident Manager | HIGH | Yes | Yes |
| Event Ops | `EVENT_OPS_DASHBOARD_VIEWER` | Dashboard Viewer | LOW | Yes | No |
| Vendor Portal | `VENDOR_REVIEWER` | Vendor Reviewer | MEDIUM | Yes | Yes |

## Required notifications

Seed at least six notifications:

1. High-priority all-staff announcement.
2. Operations department announcement.
3. Security policy reminder.
4. Technology maintenance message.
5. Arabic announcement with Arabic body.
6. Critical urgent message.

Example:

```json
{
  "titleEn": "Security access request process is now available",
  "titleAr": "أصبحت خدمة طلب الصلاحيات الأمنية متاحة",
  "bodyEn": "You can now request access directly from ExpoApp.",
  "bodyAr": "يمكنك الآن طلب الصلاحيات مباشرة من تطبيق إكسبو.",
  "priority": "HIGH",
  "audienceType": "ALL",
  "audienceFilter": { "all": true },
  "status": "PUBLISHED"
}
```

## Required access requests

Seed at least four access requests:

### Request 1 — Pending manager approval

Requester: Noura  
System: Oracle Fusion ERP  
Role: Accounts Payable Inquiry  
Status: `MANAGER_PENDING`  
Current stage: `MANAGER`  
Assigned approval task: Faisal, `PENDING`

### Request 2 — Pending security approval

Requester: Salem  
System: Security Portal  
Role: Incident Viewer  
Status: `SECURITY_PENDING`  
Current stage: `SECURITY`  
Manager task: Faisal, `APPROVED`  
Security task: Reem, `PENDING`

### Request 3 — Completed

Requester: Noura  
System: Event Ops  
Role: Dashboard Viewer  
Status: `COMPLETED`  
Completed by: Reem  
Include full event timeline.

### Request 4 — Rejected

Requester: Salem  
System: Oracle Fusion HCM  
Role: HCM Manager View  
Status: `MANAGER_REJECTED`  
Rejected by: Faisal  
Include rejection comment.

## Audit logs

Seed audit logs for:

- User login examples
- Notification creation
- Notification publish
- Access request submit
- Manager approval
- Security approval
- Rejection

## Seed script requirements

The seed script must be idempotent:

- Running it twice must not create duplicate users/departments/systems/roles.
- Use `upsert` where possible.
- Clean/demo reset may be implemented with a separate command.

## Demo credentials block for README

```text
Employee:
  noura.alharbi@expo.sa / Password123!

Manager:
  faisal.otaibi@expo.sa / Password123!

Security Admin:
  reem.security@expo.sa / Password123!

System Admin:
  admin@expo.sa / Password123!
```
