import { UserRole } from '@prisma/client';
import {
  getPermissionsForRole,
  ROLE_PERMISSIONS,
  roleHasPermission,
} from './permissions';

describe('ROLE_PERMISSIONS', () => {
  it('maps every UserRole to a non-empty permission list', () => {
    for (const role of Object.values(UserRole)) {
      expect(ROLE_PERMISSIONS[role].length).toBeGreaterThan(0);
    }
  });

  it('gives SYSTEM_ADMIN notification create/publish permissions', () => {
    const permissions = getPermissionsForRole(UserRole.SYSTEM_ADMIN);
    expect(permissions).toEqual(
      expect.arrayContaining([
        'notifications:create',
        'notifications:publish',
        'notifications:stats',
        'audit:read',
      ]),
    );
  });

  it('does not give EMPLOYEE notification create permission', () => {
    expect(roleHasPermission(UserRole.EMPLOYEE, 'notifications:create')).toBe(
      false,
    );
    expect(roleHasPermission(UserRole.EMPLOYEE, 'notifications:read')).toBe(
      true,
    );
  });

  it('gives MANAGER approvals:manager and SECURITY_ADMIN approvals:security', () => {
    expect(roleHasPermission(UserRole.MANAGER, 'approvals:manager')).toBe(true);
    expect(
      roleHasPermission(UserRole.SECURITY_ADMIN, 'approvals:security'),
    ).toBe(true);
    expect(roleHasPermission(UserRole.EMPLOYEE, 'approvals:manager')).toBe(
      false,
    );
  });
});
