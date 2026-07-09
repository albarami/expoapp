import { AudienceType, UserRole } from '@prisma/client';

export type AudienceFilterAll = {
  all: true;
};

export type AudienceFilterDepartment = {
  departmentCodes: string[];
};

export type AudienceFilterRole = {
  roles: UserRole[];
};

export type AudienceFilterUsers = {
  userIds: string[];
};

export type AudienceFilter =
  | AudienceFilterAll
  | AudienceFilterDepartment
  | AudienceFilterRole
  | AudienceFilterUsers;

export type ResolvedAudienceUser = {
  id: string;
  email: string;
  role: UserRole;
  departmentCode: string | null;
  isActive: boolean;
};

export type ResolveAudienceInput = {
  audienceType: AudienceType;
  audienceFilter: unknown;
};
