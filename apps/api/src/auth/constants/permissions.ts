import { UserRole } from '@prisma/client';

export const ROLE_PERMISSIONS: Record<UserRole, readonly string[]> = {
  [UserRole.EMPLOYEE]: [
    'notifications:read',
    'accessRequests:create',
    'accessRequests:readOwn',
  ],
  [UserRole.MANAGER]: [
    'notifications:read',
    'accessRequests:create',
    'accessRequests:readOwn',
    'approvals:manager',
  ],
  [UserRole.SECURITY_ADMIN]: [
    'notifications:read',
    'accessRequests:create',
    'accessRequests:readOwn',
    'approvals:security',
    'audit:read',
  ],
  [UserRole.SYSTEM_ADMIN]: [
    'notifications:read',
    'notifications:create',
    'notifications:publish',
    'notifications:stats',
    'accessRequests:readAll',
    'audit:read',
  ],
};

export function getPermissionsForRole(role: UserRole): string[] {
  return [...ROLE_PERMISSIONS[role]];
}

export function roleHasPermission(role: UserRole, permission: string): boolean {
  return ROLE_PERMISSIONS[role].includes(permission);
}
