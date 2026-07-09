import { PrismaClient, UserRole } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

const DEMO_PASSWORD = 'Password123!';
const BCRYPT_ROUNDS = 10;

const DEPARTMENTS = [
  { code: 'OPS', nameEn: 'Operations', nameAr: 'العمليات' },
  { code: 'SEC', nameEn: 'Security', nameAr: 'الأمن' },
  { code: 'TECH', nameEn: 'Technology', nameAr: 'التقنية' },
  { code: 'FIN', nameEn: 'Finance', nameAr: 'المالية' },
  { code: 'HR', nameEn: 'Human Resources', nameAr: 'الموارد البشرية' },
] as const;

type SeedUser = {
  externalRef: string;
  employeeNumber: string;
  email: string;
  fullNameEn: string;
  fullNameAr: string;
  role: UserRole;
  departmentCode: string;
  managerEmail?: string;
};

const USERS: SeedUser[] = [
  {
    externalRef: 'ext-e1001',
    employeeNumber: 'E1001',
    email: 'noura.alharbi@expo.sa',
    fullNameEn: 'Noura Alharbi',
    fullNameAr: 'نورة الحربي',
    role: UserRole.EMPLOYEE,
    departmentCode: 'OPS',
    managerEmail: 'faisal.otaibi@expo.sa',
  },
  {
    externalRef: 'ext-e1002',
    employeeNumber: 'E1002',
    email: 'salem.alqahtani@expo.sa',
    fullNameEn: 'Salem Alqahtani',
    fullNameAr: 'سالم القحطاني',
    role: UserRole.EMPLOYEE,
    departmentCode: 'OPS',
    managerEmail: 'faisal.otaibi@expo.sa',
  },
  {
    externalRef: 'ext-m2001',
    employeeNumber: 'M2001',
    email: 'faisal.otaibi@expo.sa',
    fullNameEn: 'Faisal Otaibi',
    fullNameAr: 'فيصل العتيبي',
    role: UserRole.MANAGER,
    departmentCode: 'OPS',
  },
  {
    externalRef: 'ext-s3001',
    employeeNumber: 'S3001',
    email: 'reem.security@expo.sa',
    fullNameEn: 'Reem Almutairi',
    fullNameAr: 'ريم المطيري',
    role: UserRole.SECURITY_ADMIN,
    departmentCode: 'SEC',
  },
  {
    externalRef: 'ext-a9001',
    employeeNumber: 'A9001',
    email: 'admin@expo.sa',
    fullNameEn: 'Expo System Admin',
    fullNameAr: 'مدير النظام',
    role: UserRole.SYSTEM_ADMIN,
    departmentCode: 'TECH',
  },
];

async function main(): Promise<void> {
  const passwordHash = await bcrypt.hash(DEMO_PASSWORD, BCRYPT_ROUNDS);

  const departmentIds = new Map<string, string>();
  for (const department of DEPARTMENTS) {
    const row = await prisma.department.upsert({
      where: { code: department.code },
      create: {
        code: department.code,
        nameEn: department.nameEn,
        nameAr: department.nameAr,
      },
      update: {
        nameEn: department.nameEn,
        nameAr: department.nameAr,
      },
    });
    departmentIds.set(department.code, row.id);
  }

  // Managers first so employee managerId links resolve on second pass.
  const managersFirst = [...USERS].sort((a, b) => {
    const aRank = a.managerEmail ? 1 : 0;
    const bRank = b.managerEmail ? 1 : 0;
    return aRank - bRank;
  });

  const userIdsByEmail = new Map<string, string>();

  for (const user of managersFirst) {
    const departmentId = departmentIds.get(user.departmentCode);
    if (!departmentId) {
      throw new Error(`Missing department ${user.departmentCode}`);
    }

    const row = await prisma.user.upsert({
      where: { email: user.email },
      create: {
        externalRef: user.externalRef,
        employeeNumber: user.employeeNumber,
        email: user.email,
        fullNameEn: user.fullNameEn,
        fullNameAr: user.fullNameAr,
        role: user.role,
        departmentId,
        passwordHash,
        isActive: true,
      },
      update: {
        externalRef: user.externalRef,
        employeeNumber: user.employeeNumber,
        fullNameEn: user.fullNameEn,
        fullNameAr: user.fullNameAr,
        role: user.role,
        departmentId,
        passwordHash,
        isActive: true,
      },
    });
    userIdsByEmail.set(user.email, row.id);
  }

  for (const user of USERS) {
    if (!user.managerEmail) {
      continue;
    }
    const userId = userIdsByEmail.get(user.email);
    const managerId = userIdsByEmail.get(user.managerEmail);
    if (!userId || !managerId) {
      throw new Error(`Failed to link manager for ${user.email}`);
    }
    await prisma.user.update({
      where: { id: userId },
      data: { managerId },
    });
  }

  console.log(
    `Seed complete: ${DEPARTMENTS.length} departments, ${USERS.length} users (password: ${DEMO_PASSWORD})`,
  );
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (error: unknown) => {
    console.error(error);
    await prisma.$disconnect();
    process.exit(1);
  });
