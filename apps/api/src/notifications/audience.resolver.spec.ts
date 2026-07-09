import { AudienceType, UserRole } from '@prisma/client';
import { ErrorCode } from '../common/constants/error-codes';
import { BusinessException } from '../common/exceptions/business.exception';
import { AudienceResolver } from './audience.resolver';

describe('AudienceResolver (BU-02)', () => {
  const activeUsers = [
    {
      id: 'u-ops-emp',
      email: 'ops@expo.sa',
      role: UserRole.EMPLOYEE,
      isActive: true,
      department: { code: 'OPS' },
    },
    {
      id: 'u-sec-admin',
      email: 'sec@expo.sa',
      role: UserRole.SECURITY_ADMIN,
      isActive: true,
      department: { code: 'SEC' },
    },
    {
      id: 'u-inactive',
      email: 'inactive@expo.sa',
      role: UserRole.EMPLOYEE,
      isActive: false,
      department: { code: 'OPS' },
    },
  ];

  function createResolver(
    users: typeof activeUsers = activeUsers.filter((u) => u.isActive),
  ): AudienceResolver {
    const prisma = {
      user: {
        findMany: jest.fn().mockResolvedValue(users),
      },
    };
    return new AudienceResolver(prisma as never);
  }

  it('resolves ALL to active users only', async () => {
    const resolver = createResolver();
    const result = await resolver.resolveAudience({
      audienceType: AudienceType.ALL,
      audienceFilter: { all: true },
    });
    expect(result.map((u) => u.id).sort()).toEqual([
      'u-ops-emp',
      'u-sec-admin',
    ]);
  });

  it('resolves DEPARTMENT by department codes', async () => {
    const resolver = createResolver();
    const result = await resolver.resolveAudience({
      audienceType: AudienceType.DEPARTMENT,
      audienceFilter: { departmentCodes: ['OPS'] },
    });
    expect(result.map((u) => u.id)).toEqual(['u-ops-emp']);
  });

  it('resolves ROLE by roles', async () => {
    const resolver = createResolver();
    const result = await resolver.resolveAudience({
      audienceType: AudienceType.ROLE,
      audienceFilter: { roles: [UserRole.SECURITY_ADMIN] },
    });
    expect(result.map((u) => u.id)).toEqual(['u-sec-admin']);
  });

  it('resolves USERS by userIds among active users', async () => {
    const resolver = createResolver();
    const result = await resolver.resolveAudience({
      audienceType: AudienceType.USERS,
      audienceFilter: { userIds: ['u-ops-emp', 'missing', 'u-inactive'] },
    });
    expect(result.map((u) => u.id)).toEqual(['u-ops-emp']);
  });

  it('rejects invalid audience filters', () => {
    const resolver = createResolver();
    expect(() =>
      resolver.validateAndNormalizeFilter(AudienceType.ALL, { all: false }),
    ).toThrow(BusinessException);

    try {
      resolver.validateAndNormalizeFilter(AudienceType.DEPARTMENT, {
        departmentCodes: [],
      });
      fail('expected throw');
    } catch (error) {
      expect(error).toBeInstanceOf(BusinessException);
      expect((error as BusinessException).code).toBe(
        ErrorCode.INVALID_AUDIENCE_FILTER,
      );
    }
  });
});
