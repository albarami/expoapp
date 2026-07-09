import {
  AccessDuration,
  AccessRequestStage,
  AccessRequestStatus,
  AccessUrgency,
  ApprovalDecision,
  ApprovalStage,
  AudienceType,
  NotificationPriority,
  NotificationStatus,
  Prisma,
  PrismaClient,
  RiskLevel,
  UserRole,
} from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

const DEMO_PASSWORD = 'Password123!';
const BCRYPT_ROUNDS = 10;
const SEED_YEAR = 2026;

const AuditAction = {
  AuthLogin: 'AUTH_LOGIN',
  NotificationCreated: 'NOTIFICATION_CREATED',
  NotificationPublished: 'NOTIFICATION_PUBLISHED',
  AccessRequestSubmitted: 'ACCESS_REQUEST_SUBMITTED',
  ApprovalManagerApproved: 'APPROVAL_MANAGER_APPROVED',
  ApprovalManagerRejected: 'APPROVAL_MANAGER_REJECTED',
  ApprovalSecurityApproved: 'APPROVAL_SECURITY_APPROVED',
  AccessRequestCompleted: 'ACCESS_REQUEST_COMPLETED',
} as const;

const DEPARTMENTS = [
  { code: 'OPS', nameEn: 'Operations', nameAr: 'العمليات' },
  { code: 'SEC', nameEn: 'Security', nameAr: 'الأمن' },
  { code: 'TECH', nameEn: 'Technology', nameAr: 'التقنية' },
  { code: 'FIN', nameEn: 'Finance', nameAr: 'المالية' },
  { code: 'HR', nameEn: 'Human Resources', nameAr: 'الموارد البشرية' },
] as const;

type SeedUser = {
  externalRef: string;
  employeeNumber: string;
  email: string;
  fullNameEn: string;
  fullNameAr: string;
  role: UserRole;
  departmentCode: string;
  managerEmail?: string;
};

const USERS: SeedUser[] = [
  {
    externalRef: 'ext-e1001',
    employeeNumber: 'E1001',
    email: 'noura.alharbi@expo.sa',
    fullNameEn: 'Noura Alharbi',
    fullNameAr: 'نورة الحربي',
    role: UserRole.EMPLOYEE,
    departmentCode: 'OPS',
    managerEmail: 'faisal.otaibi@expo.sa',
  },
  {
    externalRef: 'ext-e1002',
    employeeNumber: 'E1002',
    email: 'salem.alqahtani@expo.sa',
    fullNameEn: 'Salem Alqahtani',
    fullNameAr: 'سالم القحطاني',
    role: UserRole.EMPLOYEE,
    departmentCode: 'OPS',
    managerEmail: 'faisal.otaibi@expo.sa',
  },
  {
    externalRef: 'ext-m2001',
    employeeNumber: 'M2001',
    email: 'faisal.otaibi@expo.sa',
    fullNameEn: 'Faisal Otaibi',
    fullNameAr: 'فيصل العتيبي',
    role: UserRole.MANAGER,
    departmentCode: 'OPS',
  },
  {
    externalRef: 'ext-s3001',
    employeeNumber: 'S3001',
    email: 'reem.security@expo.sa',
    fullNameEn: 'Reem Almutairi',
    fullNameAr: 'ريم المطيري',
    role: UserRole.SECURITY_ADMIN,
    departmentCode: 'SEC',
  },
  {
    externalRef: 'ext-a9001',
    employeeNumber: 'A9001',
    email: 'admin@expo.sa',
    fullNameEn: 'Expo System Admin',
    fullNameAr: 'مدير النظام',
    role: UserRole.SYSTEM_ADMIN,
    departmentCode: 'TECH',
  },
];

const SYSTEMS = [
  {
    code: 'ORACLE_FUSION_ERP',
    nameEn: 'Oracle Fusion ERP',
    nameAr: 'أوراكل فيوجن المالي',
    description: 'Finance and procurement ERP access',
  },
  {
    code: 'ORACLE_FUSION_HCM',
    nameEn: 'Oracle Fusion HCM',
    nameAr: 'أوراكل فيوجن الموارد البشرية',
    description: 'HR and employee data access',
  },
  {
    code: 'SECURITY_PORTAL',
    nameEn: 'Security Operations Portal',
    nameAr: 'بوابة العمليات الأمنية',
    description: 'Security operations access',
  },
  {
    code: 'EVENT_OPS',
    nameEn: 'Event Operations Dashboard',
    nameAr: 'لوحة عمليات الفعالية',
    description: 'Event operation dashboards',
  },
  {
    code: 'VENDOR_PORTAL',
    nameEn: 'Vendor Management Portal',
    nameAr: 'بوابة إدارة الموردين',
    description: 'Vendor onboarding and management',
  },
] as const;

const SECURITY_ROLES = [
  {
    systemCode: 'ORACLE_FUSION_ERP',
    code: 'FUSION_AP_INQUIRY',
    nameEn: 'Accounts Payable Inquiry',
    riskLevel: RiskLevel.MEDIUM,
    requiresManagerApproval: true,
    requiresSecurityApproval: true,
  },
  {
    systemCode: 'ORACLE_FUSION_ERP',
    code: 'FUSION_PROCUREMENT_REQUESTER',
    nameEn: 'Procurement Requester',
    riskLevel: RiskLevel.MEDIUM,
    requiresManagerApproval: true,
    requiresSecurityApproval: true,
  },
  {
    systemCode: 'ORACLE_FUSION_ERP',
    code: 'FUSION_FINANCE_MANAGER',
    nameEn: 'Finance Manager Access',
    riskLevel: RiskLevel.HIGH,
    requiresManagerApproval: true,
    requiresSecurityApproval: true,
  },
  {
    systemCode: 'ORACLE_FUSION_HCM',
    code: 'FUSION_HCM_EMPLOYEE_VIEW',
    nameEn: 'HCM Employee View',
    riskLevel: RiskLevel.MEDIUM,
    requiresManagerApproval: true,
    requiresSecurityApproval: true,
  },
  {
    systemCode: 'ORACLE_FUSION_HCM',
    code: 'FUSION_HCM_MANAGER_VIEW',
    nameEn: 'HCM Manager View',
    riskLevel: RiskLevel.HIGH,
    requiresManagerApproval: true,
    requiresSecurityApproval: true,
  },
  {
    systemCode: 'SECURITY_PORTAL',
    code: 'SECURITY_INCIDENT_VIEWER',
    nameEn: 'Incident Viewer',
    riskLevel: RiskLevel.MEDIUM,
    requiresManagerApproval: true,
    requiresSecurityApproval: true,
  },
  {
    systemCode: 'SECURITY_PORTAL',
    code: 'SECURITY_INCIDENT_MANAGER',
    nameEn: 'Incident Manager',
    riskLevel: RiskLevel.HIGH,
    requiresManagerApproval: true,
    requiresSecurityApproval: true,
  },
  {
    systemCode: 'EVENT_OPS',
    code: 'EVENT_OPS_DASHBOARD_VIEWER',
    nameEn: 'Dashboard Viewer',
    riskLevel: RiskLevel.LOW,
    requiresManagerApproval: true,
    requiresSecurityApproval: false,
  },
  {
    systemCode: 'VENDOR_PORTAL',
    code: 'VENDOR_REVIEWER',
    nameEn: 'Vendor Reviewer',
    riskLevel: RiskLevel.MEDIUM,
    requiresManagerApproval: true,
    requiresSecurityApproval: true,
  },
] as const;

type SeedNotification = {
  seedKey: string;
  titleEn: string;
  titleAr: string;
  bodyEn: string;
  bodyAr: string;
  priority: NotificationPriority;
  audienceType: AudienceType;
  audienceFilter: Prisma.InputJsonValue;
  status: NotificationStatus;
};

const NOTIFICATIONS: SeedNotification[] = [
  {
    seedKey: 'notif-all-staff-high',
    titleEn: 'Security access request process is now available',
    titleAr: 'أصبحت خدمة طلب الصلاحيات الأمنية متاحة',
    bodyEn: 'You can now request access directly from ExpoApp.',
    bodyAr: 'يمكنك الآن طلب الصلاحيات مباشرة من تطبيق إكسبو.',
    priority: NotificationPriority.HIGH,
    audienceType: AudienceType.ALL,
    audienceFilter: { all: true },
    status: NotificationStatus.PUBLISHED,
  },
  {
    seedKey: 'notif-ops-department',
    titleEn: 'Operations weekly briefing',
    titleAr: 'إحاطة العمليات الأسبوعية',
    bodyEn: 'Please review the operations checklist before the weekend shift.',
    bodyAr: 'يرجى مراجعة قائمة عمليات التحقق قبل وردية نهاية الأسبوع.',
    priority: NotificationPriority.NORMAL,
    audienceType: AudienceType.DEPARTMENT,
    audienceFilter: { departmentCodes: ['OPS'] },
    status: NotificationStatus.PUBLISHED,
  },
  {
    seedKey: 'notif-security-policy',
    titleEn: 'Security policy reminder',
    titleAr: 'تذكير بسياسة الأمن',
    bodyEn: 'Do not share credentials. Report suspicious access immediately.',
    bodyAr: 'لا تشارك بيانات الدخول. أبلغ عن أي وصول مشبوه فوراً.',
    priority: NotificationPriority.HIGH,
    audienceType: AudienceType.DEPARTMENT,
    audienceFilter: { departmentCodes: ['SEC', 'OPS'] },
    status: NotificationStatus.PUBLISHED,
  },
  {
    seedKey: 'notif-tech-maintenance',
    titleEn: 'Technology maintenance window',
    titleAr: 'نافذة صيانة التقنية',
    bodyEn: 'Planned maintenance for ExpoApp APIs on Friday 22:00–23:00 AST.',
    bodyAr: 'صيانة مخططة لواجهات تطبيق إكسبو يوم الجمعة 22:00–23:00 بتوقيت السعودية.',
    priority: NotificationPriority.NORMAL,
    audienceType: AudienceType.DEPARTMENT,
    audienceFilter: { departmentCodes: ['TECH'] },
    status: NotificationStatus.PUBLISHED,
  },
  {
    seedKey: 'notif-arabic-announcement',
    titleEn: 'Arabic announcement',
    titleAr: 'إعلان هام للموظفين',
    bodyEn: 'Please read the Arabic body for the official message.',
    bodyAr:
      'يرجى الالتزام بإجراءات طلب الصلاحيات عبر التطبيق وعدم إرسال الطلبات عبر البريد.',
    priority: NotificationPriority.NORMAL,
    audienceType: AudienceType.ALL,
    audienceFilter: { all: true },
    status: NotificationStatus.PUBLISHED,
  },
  {
    seedKey: 'notif-critical-urgent',
    titleEn: 'Critical: verify your manager assignment',
    titleAr: 'حرج: تحقق من تعيين مديرك',
    bodyEn: 'Access requests cannot route without an active manager. Contact HR if missing.',
    bodyAr: 'لا يمكن توجيه طلبات الصلاحيات بدون مدير نشط. تواصل مع الموارد البشرية إن لزم.',
    priority: NotificationPriority.CRITICAL,
    audienceType: AudienceType.ROLE,
    audienceFilter: { roles: ['EMPLOYEE', 'MANAGER'] },
    status: NotificationStatus.PUBLISHED,
  },
];

function requestNumber(sequence: number): string {
  return `AR-${SEED_YEAR}-${String(sequence).padStart(6, '0')}`;
}

async function upsertAuditLog(input: {
  seedKey: string;
  actorId: string;
  actorEmail: string;
  action: string;
  entityType: string;
  entityId: string;
  metadata?: Prisma.InputJsonObject;
}): Promise<void> {
  const existing = await prisma.auditLog.findFirst({
    where: {
      action: input.action,
      entityType: input.entityType,
      entityId: input.entityId,
      metadata: { path: ['seedKey'], equals: input.seedKey },
    },
  });

  const metadata: Prisma.InputJsonObject = {
    seedKey: input.seedKey,
    ...(input.metadata ?? {}),
  };

  if (existing) {
    await prisma.auditLog.update({
      where: { id: existing.id },
      data: {
        actorId: input.actorId,
        actorEmail: input.actorEmail,
        metadata,
      },
    });
    return;
  }

  await prisma.auditLog.create({
    data: {
      actorId: input.actorId,
      actorEmail: input.actorEmail,
      action: input.action,
      entityType: input.entityType,
      entityId: input.entityId,
      metadata,
    },
  });
}

async function syncApprovalTask(input: {
  accessRequestId: string;
  stage: ApprovalStage;
  assigneeId: string;
  decision: ApprovalDecision;
  comment?: string;
  decidedAt?: Date | null;
}): Promise<string> {
  const existing = await prisma.approvalTask.findFirst({
    where: {
      accessRequestId: input.accessRequestId,
      stage: input.stage,
    },
  });

  if (existing) {
    const updated = await prisma.approvalTask.update({
      where: { id: existing.id },
      data: {
        assigneeId: input.assigneeId,
        decision: input.decision,
        comment: input.comment ?? null,
        decidedAt: input.decidedAt ?? null,
      },
    });
    return updated.id;
  }

  const created = await prisma.approvalTask.create({
    data: {
      accessRequestId: input.accessRequestId,
      stage: input.stage,
      assigneeId: input.assigneeId,
      decision: input.decision,
      comment: input.comment ?? null,
      decidedAt: input.decidedAt ?? null,
    },
  });
  return created.id;
}

async function syncRequestEvents(
  accessRequestId: string,
  events: Array<{
    eventType: string;
    actorId?: string;
    messageEn: string;
    messageAr: string;
    metadata?: Prisma.InputJsonObject;
  }>,
): Promise<void> {
  await prisma.accessRequestEvent.deleteMany({ where: { accessRequestId } });
  for (const event of events) {
    await prisma.accessRequestEvent.create({
      data: {
        accessRequestId,
        actorId: event.actorId,
        eventType: event.eventType,
        messageEn: event.messageEn,
        messageAr: event.messageAr,
        metadata: event.metadata,
      },
    });
  }
}

async function resolveAudienceUserIds(
  audienceType: AudienceType,
  audienceFilter: Prisma.InputJsonValue,
  usersByEmail: Map<string, { id: string; role: UserRole; departmentCode: string }>,
): Promise<string[]> {
  const allUsers = [...usersByEmail.values()];
  const filter =
    audienceFilter && typeof audienceFilter === 'object' && !Array.isArray(audienceFilter)
      ? (audienceFilter as Prisma.JsonObject)
      : {};

  if (audienceType === AudienceType.ALL) {
    return allUsers.map((user) => user.id);
  }

  if (audienceType === AudienceType.DEPARTMENT) {
    const codes = (filter.departmentCodes as string[] | undefined) ?? [];
    return allUsers
      .filter((user) => codes.includes(user.departmentCode))
      .map((user) => user.id);
  }

  if (audienceType === AudienceType.ROLE) {
    const roles = (filter.roles as string[] | undefined) ?? [];
    return allUsers
      .filter((user) => roles.includes(user.role))
      .map((user) => user.id);
  }

  return [];
}

export async function seedDatabase(): Promise<{
  departments: number;
  users: number;
  systems: number;
  securityRoles: number;
  notifications: number;
  accessRequests: number;
  approvalTasks: number;
  accessRequestEvents: number;
  auditLogs: number;
}> {
  const passwordHash = await bcrypt.hash(DEMO_PASSWORD, BCRYPT_ROUNDS);

  const departmentIds = new Map<string, string>();
  for (const department of DEPARTMENTS) {
    const row = await prisma.department.upsert({
      where: { code: department.code },
      create: {
        code: department.code,
        nameEn: department.nameEn,
        nameAr: department.nameAr,
      },
      update: {
        nameEn: department.nameEn,
        nameAr: department.nameAr,
      },
    });
    departmentIds.set(department.code, row.id);
  }

  const managersFirst = [...USERS].sort((a, b) => {
    const aRank = a.managerEmail ? 1 : 0;
    const bRank = b.managerEmail ? 1 : 0;
    return aRank - bRank;
  });

  const userIdsByEmail = new Map<string, string>();
  const userMetaByEmail = new Map<
    string,
    { id: string; role: UserRole; departmentCode: string }
  >();

  for (const user of managersFirst) {
    const departmentId = departmentIds.get(user.departmentCode);
    if (!departmentId) {
      throw new Error(`Missing department ${user.departmentCode}`);
    }

    const row = await prisma.user.upsert({
      where: { email: user.email },
      create: {
        externalRef: user.externalRef,
        employeeNumber: user.employeeNumber,
        email: user.email,
        fullNameEn: user.fullNameEn,
        fullNameAr: user.fullNameAr,
        role: user.role,
        departmentId,
        passwordHash,
        isActive: true,
      },
      update: {
        externalRef: user.externalRef,
        employeeNumber: user.employeeNumber,
        fullNameEn: user.fullNameEn,
        fullNameAr: user.fullNameAr,
        role: user.role,
        departmentId,
        passwordHash,
        isActive: true,
      },
    });
    userIdsByEmail.set(user.email, row.id);
    userMetaByEmail.set(user.email, {
      id: row.id,
      role: user.role,
      departmentCode: user.departmentCode,
    });
  }

  for (const user of USERS) {
    if (!user.managerEmail) {
      continue;
    }
    const userId = userIdsByEmail.get(user.email);
    const managerId = userIdsByEmail.get(user.managerEmail);
    if (!userId || !managerId) {
      throw new Error(`Failed to link manager for ${user.email}`);
    }
    await prisma.user.update({
      where: { id: userId },
      data: { managerId },
    });
  }

  const systemIds = new Map<string, string>();
  for (const system of SYSTEMS) {
    const row = await prisma.appSystem.upsert({
      where: { code: system.code },
      create: {
        code: system.code,
        nameEn: system.nameEn,
        nameAr: system.nameAr,
        description: system.description,
        isActive: true,
      },
      update: {
        nameEn: system.nameEn,
        nameAr: system.nameAr,
        description: system.description,
        isActive: true,
      },
    });
    systemIds.set(system.code, row.id);
  }

  const roleIds = new Map<string, string>();
  for (const role of SECURITY_ROLES) {
    const systemId = systemIds.get(role.systemCode);
    if (!systemId) {
      throw new Error(`Missing system ${role.systemCode}`);
    }
    const row = await prisma.securityRoleCatalog.upsert({
      where: {
        systemId_code: {
          systemId,
          code: role.code,
        },
      },
      create: {
        systemId,
        code: role.code,
        nameEn: role.nameEn,
        riskLevel: role.riskLevel,
        requiresManagerApproval: role.requiresManagerApproval,
        requiresSecurityApproval: role.requiresSecurityApproval,
        isActive: true,
      },
      update: {
        nameEn: role.nameEn,
        riskLevel: role.riskLevel,
        requiresManagerApproval: role.requiresManagerApproval,
        requiresSecurityApproval: role.requiresSecurityApproval,
        isActive: true,
      },
    });
    roleIds.set(`${role.systemCode}:${role.code}`, row.id);
  }

  const adminId = userIdsByEmail.get('admin@expo.sa');
  const nouraId = userIdsByEmail.get('noura.alharbi@expo.sa');
  const salemId = userIdsByEmail.get('salem.alqahtani@expo.sa');
  const faisalId = userIdsByEmail.get('faisal.otaibi@expo.sa');
  const reemId = userIdsByEmail.get('reem.security@expo.sa');
  if (!adminId || !nouraId || !salemId || !faisalId || !reemId) {
    throw new Error('Required demo users missing after upsert');
  }

  const publishedAt = new Date(`${SEED_YEAR}-06-01T08:00:00.000Z`);
  const notificationIds = new Map<string, string>();

  for (const notification of NOTIFICATIONS) {
    const existing = await prisma.notification.findFirst({
      where: {
        createdById: adminId,
        titleEn: notification.titleEn,
      },
    });

    const data = {
      titleEn: notification.titleEn,
      titleAr: notification.titleAr,
      bodyEn: notification.bodyEn,
      bodyAr: notification.bodyAr,
      priority: notification.priority,
      status: notification.status,
      audienceType: notification.audienceType,
      audienceFilter: notification.audienceFilter,
      publishAt: publishedAt,
      createdById: adminId,
    };

    const row = existing
      ? await prisma.notification.update({
          where: { id: existing.id },
          data,
        })
      : await prisma.notification.create({ data });

    notificationIds.set(notification.seedKey, row.id);

    const recipientIds = await resolveAudienceUserIds(
      notification.audienceType,
      notification.audienceFilter,
      userMetaByEmail,
    );

    await prisma.notificationRecipient.deleteMany({
      where: { notificationId: row.id },
    });
    if (recipientIds.length > 0) {
      await prisma.notificationRecipient.createMany({
        data: recipientIds.map((userId) => ({
          notificationId: row.id,
          userId,
          deliveredAt: publishedAt,
        })),
      });
    }

    await upsertAuditLog({
      seedKey: `${notification.seedKey}-created`,
      actorId: adminId,
      actorEmail: 'admin@expo.sa',
      action: AuditAction.NotificationCreated,
      entityType: 'Notification',
      entityId: row.id,
    });
    await upsertAuditLog({
      seedKey: `${notification.seedKey}-published`,
      actorId: adminId,
      actorEmail: 'admin@expo.sa',
      action: AuditAction.NotificationPublished,
      entityType: 'Notification',
      entityId: row.id,
    });
  }

  const now = new Date(`${SEED_YEAR}-06-15T10:00:00.000Z`);
  const day = 24 * 60 * 60 * 1000;

  // Request 1 — Pending manager approval (Noura → FUSION_AP_INQUIRY)
  const req1Number = requestNumber(1);
  const req1RoleId = roleIds.get('ORACLE_FUSION_ERP:FUSION_AP_INQUIRY');
  const req1SystemId = systemIds.get('ORACLE_FUSION_ERP');
  if (!req1RoleId || !req1SystemId) {
    throw new Error('Missing ERP AP inquiry role/system');
  }
  const request1 = await prisma.accessRequest.upsert({
    where: { requestNumber: req1Number },
    create: {
      requestNumber: req1Number,
      requesterId: nouraId,
      systemId: req1SystemId,
      securityRoleId: req1RoleId,
      businessJustification:
        'Need AP inquiry access to reconcile vendor invoices for operations.',
      accessDuration: AccessDuration.TEMPORARY,
      startDate: now,
      endDate: new Date(now.getTime() + 90 * day),
      urgency: AccessUrgency.NORMAL,
      status: AccessRequestStatus.MANAGER_PENDING,
      currentStage: AccessRequestStage.MANAGER,
      submittedAt: now,
    },
    update: {
      requesterId: nouraId,
      systemId: req1SystemId,
      securityRoleId: req1RoleId,
      businessJustification:
        'Need AP inquiry access to reconcile vendor invoices for operations.',
      accessDuration: AccessDuration.TEMPORARY,
      startDate: now,
      endDate: new Date(now.getTime() + 90 * day),
      urgency: AccessUrgency.NORMAL,
      status: AccessRequestStatus.MANAGER_PENDING,
      currentStage: AccessRequestStage.MANAGER,
      submittedAt: now,
      completedAt: null,
      externalFusionRequestId: null,
    },
  });
  await syncApprovalTask({
    accessRequestId: request1.id,
    stage: ApprovalStage.MANAGER,
    assigneeId: faisalId,
    decision: ApprovalDecision.PENDING,
  });
  await syncRequestEvents(request1.id, [
    {
      eventType: 'SUBMITTED',
      actorId: nouraId,
      messageEn: 'Request submitted',
      messageAr: 'تم تقديم الطلب',
    },
    {
      eventType: 'MANAGER_TASK_ASSIGNED',
      actorId: faisalId,
      messageEn: 'Manager approval task assigned',
      messageAr: 'تم تعيين مهمة موافقة المدير',
    },
  ]);
  await upsertAuditLog({
    seedKey: 'audit-req1-submitted',
    actorId: nouraId,
    actorEmail: 'noura.alharbi@expo.sa',
    action: AuditAction.AccessRequestSubmitted,
    entityType: 'AccessRequest',
    entityId: request1.id,
    metadata: { requestNumber: req1Number },
  });

  // Request 2 — Pending security approval (Salem → SECURITY_INCIDENT_VIEWER)
  const req2Number = requestNumber(2);
  const req2RoleId = roleIds.get('SECURITY_PORTAL:SECURITY_INCIDENT_VIEWER');
  const req2SystemId = systemIds.get('SECURITY_PORTAL');
  if (!req2RoleId || !req2SystemId) {
    throw new Error('Missing security incident viewer role/system');
  }
  const req2Submitted = new Date(now.getTime() - 2 * day);
  const req2ManagerApproved = new Date(now.getTime() - 1 * day);
  const request2 = await prisma.accessRequest.upsert({
    where: { requestNumber: req2Number },
    create: {
      requestNumber: req2Number,
      requesterId: salemId,
      systemId: req2SystemId,
      securityRoleId: req2RoleId,
      businessJustification:
        'Need incident viewer access to support operations security reviews.',
      accessDuration: AccessDuration.PERMANENT,
      startDate: req2Submitted,
      urgency: AccessUrgency.URGENT,
      status: AccessRequestStatus.SECURITY_PENDING,
      currentStage: AccessRequestStage.SECURITY,
      submittedAt: req2Submitted,
    },
    update: {
      requesterId: salemId,
      systemId: req2SystemId,
      securityRoleId: req2RoleId,
      businessJustification:
        'Need incident viewer access to support operations security reviews.',
      accessDuration: AccessDuration.PERMANENT,
      startDate: req2Submitted,
      endDate: null,
      urgency: AccessUrgency.URGENT,
      status: AccessRequestStatus.SECURITY_PENDING,
      currentStage: AccessRequestStage.SECURITY,
      submittedAt: req2Submitted,
      completedAt: null,
      externalFusionRequestId: null,
    },
  });
  await syncApprovalTask({
    accessRequestId: request2.id,
    stage: ApprovalStage.MANAGER,
    assigneeId: faisalId,
    decision: ApprovalDecision.APPROVED,
    comment: 'Approved for operations security support.',
    decidedAt: req2ManagerApproved,
  });
  await syncApprovalTask({
    accessRequestId: request2.id,
    stage: ApprovalStage.SECURITY,
    assigneeId: reemId,
    decision: ApprovalDecision.PENDING,
  });
  await syncRequestEvents(request2.id, [
    {
      eventType: 'SUBMITTED',
      actorId: salemId,
      messageEn: 'Request submitted',
      messageAr: 'تم تقديم الطلب',
    },
    {
      eventType: 'MANAGER_APPROVED',
      actorId: faisalId,
      messageEn: 'Manager approved',
      messageAr: 'وافق المدير',
      metadata: { comment: 'Approved for operations security support.' },
    },
    {
      eventType: 'SECURITY_TASK_ASSIGNED',
      actorId: reemId,
      messageEn: 'Security approval task assigned',
      messageAr: 'تم تعيين مهمة موافقة الأمن',
    },
  ]);
  await upsertAuditLog({
    seedKey: 'audit-req2-submitted',
    actorId: salemId,
    actorEmail: 'salem.alqahtani@expo.sa',
    action: AuditAction.AccessRequestSubmitted,
    entityType: 'AccessRequest',
    entityId: request2.id,
    metadata: { requestNumber: req2Number },
  });
  await upsertAuditLog({
    seedKey: 'audit-req2-manager-approved',
    actorId: faisalId,
    actorEmail: 'faisal.otaibi@expo.sa',
    action: AuditAction.ApprovalManagerApproved,
    entityType: 'ApprovalTask',
    entityId: request2.id,
    metadata: { requestNumber: req2Number },
  });

  // Request 3 — Completed (Noura → EVENT_OPS_DASHBOARD_VIEWER)
  const req3Number = requestNumber(3);
  const req3RoleId = roleIds.get('EVENT_OPS:EVENT_OPS_DASHBOARD_VIEWER');
  const req3SystemId = systemIds.get('EVENT_OPS');
  if (!req3RoleId || !req3SystemId) {
    throw new Error('Missing event ops dashboard viewer role/system');
  }
  const req3Submitted = new Date(now.getTime() - 10 * day);
  const req3ManagerApproved = new Date(now.getTime() - 9 * day);
  const req3Completed = new Date(now.getTime() - 8 * day);
  const request3 = await prisma.accessRequest.upsert({
    where: { requestNumber: req3Number },
    create: {
      requestNumber: req3Number,
      requesterId: nouraId,
      systemId: req3SystemId,
      securityRoleId: req3RoleId,
      businessJustification:
        'Need event operations dashboard view for shift coordination.',
      accessDuration: AccessDuration.PERMANENT,
      startDate: req3Submitted,
      urgency: AccessUrgency.NORMAL,
      status: AccessRequestStatus.COMPLETED,
      currentStage: AccessRequestStage.COMPLETE,
      submittedAt: req3Submitted,
      completedAt: req3Completed,
      externalFusionRequestId: `MOCK-FUSION-${req3Number}`,
    },
    update: {
      requesterId: nouraId,
      systemId: req3SystemId,
      securityRoleId: req3RoleId,
      businessJustification:
        'Need event operations dashboard view for shift coordination.',
      accessDuration: AccessDuration.PERMANENT,
      startDate: req3Submitted,
      endDate: null,
      urgency: AccessUrgency.NORMAL,
      status: AccessRequestStatus.COMPLETED,
      currentStage: AccessRequestStage.COMPLETE,
      submittedAt: req3Submitted,
      completedAt: req3Completed,
      externalFusionRequestId: `MOCK-FUSION-${req3Number}`,
    },
  });
  await syncApprovalTask({
    accessRequestId: request3.id,
    stage: ApprovalStage.MANAGER,
    assigneeId: faisalId,
    decision: ApprovalDecision.APPROVED,
    comment: 'Approved for event operations visibility.',
    decidedAt: req3ManagerApproved,
  });
  // EVENT_OPS_DASHBOARD_VIEWER does not require security approval; Reem completes provisioning.
  await prisma.approvalTask.deleteMany({
    where: {
      accessRequestId: request3.id,
      stage: ApprovalStage.SECURITY,
    },
  });
  await syncRequestEvents(request3.id, [
    {
      eventType: 'SUBMITTED',
      actorId: nouraId,
      messageEn: 'Request submitted',
      messageAr: 'تم تقديم الطلب',
    },
    {
      eventType: 'MANAGER_APPROVED',
      actorId: faisalId,
      messageEn: 'Manager approved',
      messageAr: 'وافق المدير',
    },
    {
      eventType: 'PROVISIONING_STARTED',
      actorId: reemId,
      messageEn: 'Provisioning started',
      messageAr: 'بدأت عملية التفعيل',
    },
    {
      eventType: 'COMPLETED',
      actorId: reemId,
      messageEn: 'Access request completed by security admin',
      messageAr: 'اكتمل طلب الصلاحية بواسطة مسؤول الأمن',
    },
  ]);
  await upsertAuditLog({
    seedKey: 'audit-req3-submitted',
    actorId: nouraId,
    actorEmail: 'noura.alharbi@expo.sa',
    action: AuditAction.AccessRequestSubmitted,
    entityType: 'AccessRequest',
    entityId: request3.id,
    metadata: { requestNumber: req3Number },
  });
  await upsertAuditLog({
    seedKey: 'audit-req3-manager-approved',
    actorId: faisalId,
    actorEmail: 'faisal.otaibi@expo.sa',
    action: AuditAction.ApprovalManagerApproved,
    entityType: 'ApprovalTask',
    entityId: request3.id,
    metadata: { requestNumber: req3Number },
  });
  // Role skips formal security task; Reem still records completion as security admin.
  await upsertAuditLog({
    seedKey: 'audit-req3-security-completed',
    actorId: reemId,
    actorEmail: 'reem.security@expo.sa',
    action: AuditAction.ApprovalSecurityApproved,
    entityType: 'AccessRequest',
    entityId: request3.id,
    metadata: {
      requestNumber: req3Number,
      note: 'Security admin completed provisioning (role does not require security stage)',
    },
  });
  await upsertAuditLog({
    seedKey: 'audit-req3-completed',
    actorId: reemId,
    actorEmail: 'reem.security@expo.sa',
    action: AuditAction.AccessRequestCompleted,
    entityType: 'AccessRequest',
    entityId: request3.id,
    metadata: { requestNumber: req3Number },
  });

  // Request 4 — Rejected by manager (Salem → FUSION_HCM_MANAGER_VIEW)
  const req4Number = requestNumber(4);
  const req4RoleId = roleIds.get('ORACLE_FUSION_HCM:FUSION_HCM_MANAGER_VIEW');
  const req4SystemId = systemIds.get('ORACLE_FUSION_HCM');
  if (!req4RoleId || !req4SystemId) {
    throw new Error('Missing HCM manager view role/system');
  }
  const req4Submitted = new Date(now.getTime() - 5 * day);
  const req4Rejected = new Date(now.getTime() - 4 * day);
  const rejectionComment =
    'Role exceeds current job scope. Re-request with manager-level justification.';
  const request4 = await prisma.accessRequest.upsert({
    where: { requestNumber: req4Number },
    create: {
      requestNumber: req4Number,
      requesterId: salemId,
      systemId: req4SystemId,
      securityRoleId: req4RoleId,
      businessJustification: 'Need HCM manager view for team headcount planning.',
      accessDuration: AccessDuration.TEMPORARY,
      startDate: req4Submitted,
      endDate: new Date(req4Submitted.getTime() + 30 * day),
      urgency: AccessUrgency.NORMAL,
      status: AccessRequestStatus.MANAGER_REJECTED,
      currentStage: AccessRequestStage.MANAGER,
      submittedAt: req4Submitted,
    },
    update: {
      requesterId: salemId,
      systemId: req4SystemId,
      securityRoleId: req4RoleId,
      businessJustification: 'Need HCM manager view for team headcount planning.',
      accessDuration: AccessDuration.TEMPORARY,
      startDate: req4Submitted,
      endDate: new Date(req4Submitted.getTime() + 30 * day),
      urgency: AccessUrgency.NORMAL,
      status: AccessRequestStatus.MANAGER_REJECTED,
      currentStage: AccessRequestStage.MANAGER,
      submittedAt: req4Submitted,
      completedAt: null,
      externalFusionRequestId: null,
    },
  });
  await syncApprovalTask({
    accessRequestId: request4.id,
    stage: ApprovalStage.MANAGER,
    assigneeId: faisalId,
    decision: ApprovalDecision.REJECTED,
    comment: rejectionComment,
    decidedAt: req4Rejected,
  });
  await syncRequestEvents(request4.id, [
    {
      eventType: 'SUBMITTED',
      actorId: salemId,
      messageEn: 'Request submitted',
      messageAr: 'تم تقديم الطلب',
    },
    {
      eventType: 'MANAGER_REJECTED',
      actorId: faisalId,
      messageEn: 'Manager rejected',
      messageAr: 'رفض المدير',
      metadata: { comment: rejectionComment },
    },
  ]);
  await upsertAuditLog({
    seedKey: 'audit-req4-submitted',
    actorId: salemId,
    actorEmail: 'salem.alqahtani@expo.sa',
    action: AuditAction.AccessRequestSubmitted,
    entityType: 'AccessRequest',
    entityId: request4.id,
    metadata: { requestNumber: req4Number },
  });
  await upsertAuditLog({
    seedKey: 'audit-req4-manager-rejected',
    actorId: faisalId,
    actorEmail: 'faisal.otaibi@expo.sa',
    action: AuditAction.ApprovalManagerRejected,
    entityType: 'ApprovalTask',
    entityId: request4.id,
    metadata: { requestNumber: req4Number, comment: rejectionComment },
  });

  // Sample login audit entries for demo users
  for (const email of [
    'noura.alharbi@expo.sa',
    'faisal.otaibi@expo.sa',
    'reem.security@expo.sa',
    'admin@expo.sa',
  ] as const) {
    const userId = userIdsByEmail.get(email);
    if (!userId) {
      continue;
    }
    await upsertAuditLog({
      seedKey: `audit-login-${email}`,
      actorId: userId,
      actorEmail: email,
      action: AuditAction.AuthLogin,
      entityType: 'User',
      entityId: userId,
    });
  }

  const [
    departments,
    users,
    systems,
    securityRoles,
    notifications,
    accessRequests,
    approvalTasks,
    accessRequestEvents,
    auditLogRows,
  ] = await Promise.all([
    prisma.department.count(),
    prisma.user.count(),
    prisma.appSystem.count(),
    prisma.securityRoleCatalog.count(),
    prisma.notification.count(),
    prisma.accessRequest.count(),
    prisma.approvalTask.count(),
    prisma.accessRequestEvent.count(),
    prisma.$queryRaw<Array<{ count: bigint }>>`
      SELECT COUNT(*)::bigint AS count
      FROM "AuditLog"
      WHERE metadata->>'seedKey' IS NOT NULL
    `,
  ]);

  return {
    departments,
    users,
    systems,
    securityRoles,
    notifications,
    accessRequests,
    approvalTasks,
    accessRequestEvents,
    auditLogs: Number(auditLogRows[0]?.count ?? 0),
  };
}

async function main(): Promise<void> {
  const summary = await seedDatabase();
  console.log(
    `Seed complete: ${summary.departments} departments, ${summary.users} users, ` +
      `${summary.systems} systems, ${summary.securityRoles} security roles, ` +
      `${summary.notifications} notifications, ${summary.accessRequests} access requests, ` +
      `${summary.approvalTasks} approval tasks, ${summary.accessRequestEvents} request events, ` +
      `${summary.auditLogs} seed audit logs (password: ${DEMO_PASSWORD})`,
  );
}

if (require.main === module) {
  main()
    .then(async () => {
      await prisma.$disconnect();
    })
    .catch(async (error: unknown) => {
      console.error(error);
      await prisma.$disconnect();
      process.exit(1);
    });
}
