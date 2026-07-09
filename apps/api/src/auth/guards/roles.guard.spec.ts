import { ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { UserRole } from '@prisma/client';
import { ROLES_KEY } from '../decorators/roles.decorator';
import { AuthUser } from '../types/auth-user';
import { RolesGuard } from './roles.guard';

describe('RolesGuard', () => {
  const reflector = {
    getAllAndOverride: jest.fn(),
  } as unknown as Reflector;

  const guard = new RolesGuard(reflector);

  function createContext(user?: AuthUser): ExecutionContext {
    return {
      getHandler: () => ({}),
      getClass: () => ({}),
      switchToHttp: () => ({
        getRequest: () => ({ user }),
      }),
    } as unknown as ExecutionContext;
  }

  const employee: AuthUser = {
    id: 'u1',
    email: 'noura.alharbi@expo.sa',
    fullNameEn: 'Noura',
    fullNameAr: null,
    role: UserRole.EMPLOYEE,
    departmentId: null,
    department: null,
    isActive: true,
    permissions: [],
  };

  it('allows when no roles metadata is set', () => {
    (reflector.getAllAndOverride as jest.Mock).mockReturnValue(undefined);
    expect(guard.canActivate(createContext(employee))).toBe(true);
  });

  it('allows matching role', () => {
    (reflector.getAllAndOverride as jest.Mock).mockImplementation((key) =>
      key === ROLES_KEY
        ? [UserRole.SYSTEM_ADMIN, UserRole.EMPLOYEE]
        : undefined,
    );
    expect(guard.canActivate(createContext(employee))).toBe(true);
  });

  it('forbids non-matching role', () => {
    (reflector.getAllAndOverride as jest.Mock).mockReturnValue([
      UserRole.SYSTEM_ADMIN,
    ]);
    expect(() => guard.canActivate(createContext(employee))).toThrow(
      /Insufficient permissions/,
    );
  });
});
