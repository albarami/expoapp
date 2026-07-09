import { UserRole } from '@prisma/client';
import { ListUsersQueryDto } from './dto/list-users-query.dto';
import { UsersService } from './users.service';

interface CapturedFindMany {
  where: Record<string, unknown>;
  skip: number;
  take: number;
}

function makeQuery(
  overrides: Partial<ListUsersQueryDto> = {},
): ListUsersQueryDto {
  const query = new ListUsersQueryDto();
  Object.assign(query, overrides);
  return query;
}

function makePrisma(rows: unknown[], total: number) {
  const captured: {
    count?: Record<string, unknown>;
    findMany?: CapturedFindMany;
  } = {};
  const prisma = {
    user: {
      count: jest.fn((args: { where: Record<string, unknown> }) => {
        captured.count = args.where;
        return Promise.resolve(total);
      }),
      findMany: jest.fn((args: CapturedFindMany) => {
        captured.findMany = args;
        return Promise.resolve(rows);
      }),
    },
    $transaction: jest.fn((operations: Promise<unknown>[]) =>
      Promise.all(operations),
    ),
  };
  return { prisma, captured };
}

const sampleRow = {
  id: 'u1',
  email: 'noura.alharbi@expo.sa',
  fullNameEn: 'Noura Alharbi',
  fullNameAr: 'نورة الحربي',
  employeeNumber: 'E1001',
  role: UserRole.EMPLOYEE,
  department: {
    id: 'd1',
    code: 'OPS',
    nameEn: 'Operations',
    nameAr: 'العمليات',
  },
};

describe('UsersService', () => {
  it('lists active users with pagination metadata (happy path)', async () => {
    const { prisma, captured } = makePrisma([sampleRow], 42);
    const service = new UsersService(prisma as never);

    const result = await service.list(makeQuery({ page: 2, pageSize: 10 }));

    expect(result.total).toBe(42);
    expect(result.page).toBe(2);
    expect(result.pageSize).toBe(10);
    expect(result.items).toEqual([
      expect.objectContaining({
        id: 'u1',
        email: 'noura.alharbi@expo.sa',
        employeeNumber: 'E1001',
        role: UserRole.EMPLOYEE,
        department: expect.objectContaining({ code: 'OPS' }) as object,
      }),
    ]);
    expect(captured.findMany?.skip).toBe(10);
    expect(captured.findMany?.take).toBe(10);
    expect(captured.findMany?.where).toEqual(
      expect.objectContaining({ isActive: true }),
    );
  });

  it('applies search across name, email, and employee number (edge)', async () => {
    const { prisma, captured } = makePrisma([], 0);
    const service = new UsersService(prisma as never);

    const result = await service.list(makeQuery({ search: '  noura ' }));

    expect(result.items).toEqual([]);
    const where = captured.findMany?.where as { OR?: unknown[] };
    expect(where.OR).toHaveLength(4);
    expect(where.OR).toEqual(
      expect.arrayContaining([
        { fullNameEn: { contains: 'noura', mode: 'insensitive' } },
        { email: { contains: 'noura', mode: 'insensitive' } },
      ]),
    );
  });

  it('filters by role and department code (edge)', async () => {
    const { prisma, captured } = makePrisma([], 0);
    const service = new UsersService(prisma as never);

    await service.list(
      makeQuery({ role: UserRole.MANAGER, departmentCode: 'OPS' }),
    );

    expect(captured.findMany?.where).toEqual(
      expect.objectContaining({
        isActive: true,
        role: UserRole.MANAGER,
        department: { code: 'OPS' },
      }),
    );
  });
});
