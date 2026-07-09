# Database Schema — Prisma

Create `apps/api/prisma/schema.prisma`.

This schema is intentionally production-shaped even for mock mode.

```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

enum UserRole {
  EMPLOYEE
  MANAGER
  SECURITY_ADMIN
  SYSTEM_ADMIN
}

enum NotificationPriority {
  LOW
  NORMAL
  HIGH
  CRITICAL
}

enum NotificationStatus {
  DRAFT
  SCHEDULED
  PUBLISHED
  CANCELLED
  EXPIRED
}

enum AudienceType {
  ALL
  DEPARTMENT
  ROLE
  USERS
}

enum AccessDuration {
  TEMPORARY
  PERMANENT
}

enum AccessUrgency {
  NORMAL
  URGENT
  CRITICAL
}

enum AccessRequestStatus {
  DRAFT
  SUBMITTED
  MANAGER_PENDING
  MANAGER_APPROVED
  MANAGER_REJECTED
  SECURITY_PENDING
  SECURITY_APPROVED
  SECURITY_REJECTED
  PROVISIONING
  COMPLETED
  CANCELLED
  FAILED
}

enum AccessRequestStage {
  REQUESTER
  MANAGER
  SECURITY
  PROVISIONING
  COMPLETE
}

enum ApprovalStage {
  MANAGER
  SECURITY
}

enum ApprovalDecision {
  PENDING
  APPROVED
  REJECTED
  RETURNED
}

enum RiskLevel {
  LOW
  MEDIUM
  HIGH
  CRITICAL
}

enum OutboxStatus {
  PENDING
  PROCESSING
  COMPLETED
  FAILED
  CANCELLED
}

model Department {
  id        String   @id @default(uuid())
  code      String   @unique
  nameEn    String
  nameAr    String?
  users     User[]
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model User {
  id             String      @id @default(uuid())
  externalRef    String      @unique
  employeeNumber String      @unique
  fullNameEn     String
  fullNameAr     String?
  email          String      @unique
  phone          String?
  passwordHash   String?
  role           UserRole    @default(EMPLOYEE)
  departmentId   String?
  department     Department? @relation(fields: [departmentId], references: [id])
  managerId      String?
  manager        User?       @relation("ManagerRelation", fields: [managerId], references: [id])
  directReports  User[]      @relation("ManagerRelation")
  isActive       Boolean     @default(true)

  createdNotifications Notification[]         @relation("CreatedNotifications")
  recipients           NotificationRecipient[]
  accessRequests       AccessRequest[]        @relation("RequesterAccessRequests")
  approvalTasks        ApprovalTask[]         @relation("AssigneeApprovalTasks")
  auditLogs            AuditLog[]             @relation("ActorAuditLogs")
  requestEvents        AccessRequestEvent[]   @relation("ActorRequestEvents")
  deviceTokens         DeviceToken[]

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([email])
  @@index([role])
  @@index([managerId])
}

model DeviceToken {
  id        String   @id @default(uuid())
  userId    String
  user      User     @relation(fields: [userId], references: [id])
  platform  String
  token     String
  isActive  Boolean  @default(true)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@unique([platform, token])
  @@index([userId])
}

model AppSystem {
  id          String                @id @default(uuid())
  code        String                @unique
  nameEn      String
  nameAr      String?
  description String?
  isActive    Boolean               @default(true)
  roles       SecurityRoleCatalog[]
  requests    AccessRequest[]
  createdAt   DateTime              @default(now())
  updatedAt   DateTime              @updatedAt
}

model SecurityRoleCatalog {
  id                       String          @id @default(uuid())
  systemId                 String
  system                   AppSystem       @relation(fields: [systemId], references: [id])
  code                     String
  nameEn                   String
  nameAr                   String?
  description              String?
  riskLevel                RiskLevel       @default(LOW)
  requiresManagerApproval  Boolean         @default(true)
  requiresSecurityApproval Boolean         @default(true)
  isActive                 Boolean         @default(true)
  requests                 AccessRequest[]
  createdAt                DateTime        @default(now())
  updatedAt                DateTime        @updatedAt

  @@unique([systemId, code])
  @@index([riskLevel])
}

model Notification {
  id             String                 @id @default(uuid())
  titleEn        String
  titleAr        String?
  bodyEn         String
  bodyAr         String?
  priority       NotificationPriority   @default(NORMAL)
  status         NotificationStatus     @default(DRAFT)
  audienceType   AudienceType
  audienceFilter Json
  publishAt      DateTime?
  expiresAt      DateTime?
  createdById    String
  createdBy      User                   @relation("CreatedNotifications", fields: [createdById], references: [id])
  recipients     NotificationRecipient[]
  createdAt      DateTime               @default(now())
  updatedAt      DateTime               @updatedAt

  @@index([status])
  @@index([priority])
  @@index([createdById])
  @@index([publishAt])
}

model NotificationRecipient {
  id             String       @id @default(uuid())
  notificationId String
  notification   Notification @relation(fields: [notificationId], references: [id])
  userId         String
  user           User         @relation(fields: [userId], references: [id])
  deliveredAt    DateTime?
  readAt         DateTime?
  createdAt      DateTime     @default(now())

  @@unique([notificationId, userId])
  @@index([userId])
  @@index([readAt])
}

model AccessRequest {
  id                      String              @id @default(uuid())
  requestNumber           String              @unique
  requesterId             String
  requester               User                @relation("RequesterAccessRequests", fields: [requesterId], references: [id])
  systemId                String
  system                  AppSystem           @relation(fields: [systemId], references: [id])
  securityRoleId          String
  securityRole            SecurityRoleCatalog @relation(fields: [securityRoleId], references: [id])
  businessJustification   String
  accessDuration          AccessDuration
  startDate               DateTime?
  endDate                 DateTime?
  urgency                 AccessUrgency       @default(NORMAL)
  status                  AccessRequestStatus @default(DRAFT)
  currentStage            AccessRequestStage  @default(REQUESTER)
  submittedAt             DateTime?
  completedAt             DateTime?
  externalFusionRequestId String?

  approvals ApprovalTask[]
  events    AccessRequestEvent[]

  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([requesterId])
  @@index([status])
  @@index([currentStage])
  @@index([systemId])
  @@index([securityRoleId])
}

model ApprovalTask {
  id              String           @id @default(uuid())
  accessRequestId String
  accessRequest   AccessRequest    @relation(fields: [accessRequestId], references: [id])
  stage           ApprovalStage
  assigneeId      String
  assignee        User             @relation("AssigneeApprovalTasks", fields: [assigneeId], references: [id])
  decision        ApprovalDecision @default(PENDING)
  comment         String?
  decidedAt       DateTime?
  createdAt       DateTime         @default(now())
  updatedAt       DateTime         @updatedAt

  @@index([assigneeId])
  @@index([decision])
  @@index([accessRequestId])
}

model AccessRequestEvent {
  id              String        @id @default(uuid())
  accessRequestId String
  accessRequest   AccessRequest @relation(fields: [accessRequestId], references: [id])
  actorId         String?
  actor           User?         @relation("ActorRequestEvents", fields: [actorId], references: [id])
  eventType       String
  messageEn       String
  messageAr       String?
  metadata        Json?
  createdAt       DateTime      @default(now())

  @@index([accessRequestId])
  @@index([eventType])
}

model AuditLog {
  id         String   @id @default(uuid())
  actorId    String?
  actor      User?    @relation("ActorAuditLogs", fields: [actorId], references: [id])
  actorEmail String?
  action     String
  entityType String
  entityId   String?
  ipAddress  String?
  userAgent  String?
  metadata   Json?
  createdAt  DateTime @default(now())

  @@index([actorId])
  @@index([action])
  @@index([entityType])
  @@index([createdAt])
}

model IntegrationOutbox {
  id            String       @id @default(uuid())
  type          String
  payload       Json
  status        OutboxStatus @default(PENDING)
  attempts      Int          @default(0)
  lastError     String?
  nextAttemptAt DateTime?
  createdAt     DateTime     @default(now())
  updatedAt     DateTime     @updatedAt

  @@index([type])
  @@index([status])
  @@index([nextAttemptAt])
}
```

## Migration requirements

After creating the schema:

```bash
npx prisma generate
npx prisma migrate dev --name init
```

## Indexing notes

- Notification reads are user-scoped; index `NotificationRecipient.userId`.
- Approval queues are assignee-scoped; index `ApprovalTask.assigneeId`.
- Access request status filters need indexes on status/currentStage.
- Audit log queries need index on `createdAt`, `entityType`, and `actorId`.

## Data lifecycle

- Do not delete notifications after publish.
- Do not delete access requests.
- Do not delete audit logs.
- Use cancellation/expiry statuses.
- In production, audit logs should have retention rules aligned with client policy.
