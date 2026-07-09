import { PrismaClient } from '@prisma/client';
import { seedDatabase } from '../../prisma/seed';

const databaseUrl = process.env.DATABASE_URL;
const shouldRunDbTests =
  typeof databaseUrl === 'string' &&
  databaseUrl.length > 0 &&
  process.env.PRISMA_SKIP_DB_TESTS !== '1';

const describeDb = shouldRunDbTests ? describe : describe.skip;

describeDb('Prisma seed idempotency (T-API-04 / BI-08)', () => {
  const prisma = new PrismaClient();

  afterAll(async () => {
    await prisma.$disconnect();
  });

  it('seeds expected demo entities and stays stable on a second run', async () => {
    const first = await seedDatabase();
    const second = await seedDatabase();

    expect(first).toEqual(second);

    expect(first.departments).toBeGreaterThanOrEqual(5);
    expect(first.users).toBeGreaterThanOrEqual(5);
    expect(first.systems).toBe(5);
    expect(first.securityRoles).toBe(9);
    expect(first.notifications).toBeGreaterThanOrEqual(6);
    expect(first.accessRequests).toBeGreaterThanOrEqual(4);
    expect(first.approvalTasks).toBeGreaterThanOrEqual(5);
    expect(first.accessRequestEvents).toBeGreaterThanOrEqual(11);
    expect(first.auditLogs).toBeGreaterThanOrEqual(15);

    const demoEmails = [
      'noura.alharbi@expo.sa',
      'salem.alqahtani@expo.sa',
      'faisal.otaibi@expo.sa',
      'reem.security@expo.sa',
      'admin@expo.sa',
    ];
    const users = await prisma.user.findMany({
      where: { email: { in: demoEmails } },
      select: { email: true, passwordHash: true, managerId: true },
    });
    expect(users).toHaveLength(5);
    expect(users.every((user) => Boolean(user.passwordHash))).toBe(true);

    const noura = await prisma.user.findUnique({
      where: { email: 'noura.alharbi@expo.sa' },
    });
    const faisal = await prisma.user.findUnique({
      where: { email: 'faisal.otaibi@expo.sa' },
    });
    expect(noura?.managerId).toBe(faisal?.id);

    const requestStatuses = await prisma.accessRequest.findMany({
      where: {
        requestNumber: {
          in: [
            'AR-2026-000001',
            'AR-2026-000002',
            'AR-2026-000003',
            'AR-2026-000004',
          ],
        },
      },
      select: { requestNumber: true, status: true },
      orderBy: { requestNumber: 'asc' },
    });
    expect(requestStatuses.map((row) => row.status)).toEqual([
      'MANAGER_PENDING',
      'SECURITY_PENDING',
      'COMPLETED',
      'MANAGER_REJECTED',
    ]);

    const systemCodes = await prisma.appSystem.findMany({
      select: { code: true },
      orderBy: { code: 'asc' },
    });
    expect(systemCodes.map((row) => row.code)).toEqual([
      'EVENT_OPS',
      'ORACLE_FUSION_ERP',
      'ORACLE_FUSION_HCM',
      'SECURITY_PORTAL',
      'VENDOR_PORTAL',
    ]);
  });
});
