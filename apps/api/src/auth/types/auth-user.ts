import { UserRole } from '@prisma/client';

export interface AuthUserDepartment {
  id: string;
  code: string;
  nameEn: string;
  nameAr: string | null;
}

export interface AuthUser {
  id: string;
  email: string;
  fullNameEn: string;
  fullNameAr: string | null;
  role: UserRole;
  departmentId: string | null;
  department: AuthUserDepartment | null;
  isActive: boolean;
  permissions: string[];
}
