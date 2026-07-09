import { UserRole } from '@prisma/client';

export interface UserListItemDepartment {
  id: string;
  code: string;
  nameEn: string;
  nameAr: string | null;
}

export interface UserListItem {
  id: string;
  email: string;
  fullNameEn: string;
  fullNameAr: string | null;
  employeeNumber: string;
  role: UserRole;
  department: UserListItemDepartment | null;
}

export interface UserListResult {
  items: UserListItem[];
  page: number;
  pageSize: number;
  total: number;
}
