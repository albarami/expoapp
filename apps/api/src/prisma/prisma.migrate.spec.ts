import { PrismaClient } from '@prisma/client';

const databaseUrl = process.env.DATABASE_URL;
const shouldRunDbTests =
  typeof databaseUrl === 'string' &&
  databaseUrl.length > 0 &&
  process.env.PRISMA_SKIP_DB_TESTS !== '1';

const describeDb = shouldRunDbTests ? describe : describe.skip;

describeDb('Prisma schema smoke (T-API-02)', () => {
  const prisma = new PrismaClient();

  afterAll(async () => {
    await prisma.$disconnect();
  });

  it('exposes core domain tables after migrate deploy', async () => {
    const rows = await prisma.$queryRaw<
      {
        table_name: string;
      }[]
    >`
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = 'public'
        AND table_type = 'BASE TABLE'
        AND table_name IN (
          'Department',
          'User',
          'AccessRequest',
          'Notification',
          'AuditLog',
          'IntegrationOutbox'
        )
      ORDER BY table_name
    `;

    expect(rows.map((row) => row.table_name)).toEqual([
      'AccessRequest',
      'AuditLog',
      'Department',
      'IntegrationOutbox',
      'Notification',
      'User',
    ]);
  });

  it('round-trips a Department row against the migrated schema', async () => {
    const code = `TAPI02_${Date.now()}`;
    const created = await prisma.department.create({
      data: {
        code,
        nameEn: 'T-API-02 Smoke',
        nameAr: 'test-ar',
      },
    });

    const found = await prisma.department.findUnique({
      where: { id: created.id },
    });

    expect(found?.code).toBe(code);
    expect(found?.nameEn).toBe('T-API-02 Smoke');

    await prisma.department.delete({ where: { id: created.id } });
  });
});
