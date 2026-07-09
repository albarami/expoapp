import {
  AccessDuration,
  AccessUrgency,
  NotificationPriority,
  RiskLevel,
  UserRole,
} from '@prisma/client';

export interface ReferenceDepartment {
  id: string;
  code: string;
  nameEn: string;
  nameAr: string | null;
}

export interface ReferenceSystem {
  id: string;
  code: string;
  nameEn: string;
  nameAr: string | null;
  description: string | null;
  isActive: boolean;
}

export interface ReferenceSecurityRole {
  id: string;
  systemId: string;
  systemCode: string;
  code: string;
  nameEn: string;
  nameAr: string | null;
  description: string | null;
  riskLevel: RiskLevel;
  requiresManagerApproval: boolean;
  requiresSecurityApproval: boolean;
  isActive: boolean;
}

export interface ReferenceDataResponse {
  departments: ReferenceDepartment[];
  systems: ReferenceSystem[];
  securityRoles: ReferenceSecurityRole[];
  roles: UserRole[];
  notificationPriorities: NotificationPriority[];
  accessUrgencies: AccessUrgency[];
  accessDurations: AccessDuration[];
}
