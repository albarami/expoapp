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

  it('gives SYSTEM_ADMIN and SECURITY_ADMIN notification admin permissions', () => {
    const adminPermissions = getPermissionsForRole(UserRole.SYSTEM_ADMIN);
    expect(adminPermissions).toEqual(
      expect.arrayContaining([
        'notifications:create',
        'notifications:publish',
        'notifications:stats',
        'audit:read',
      ]),
    );

    const securityPermissions = getPermissionsForRole(UserRole.SECURITY_ADMIN);
    expect(securityPermissions).toEqual(
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
