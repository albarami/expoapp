import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { ListUsersQueryDto } from './dto/list-users-query.dto';
import { UserListItem, UserListResult } from './users.types';

const USER_SELECT = {
  id: true,
  email: true,
  fullNameEn: true,
  fullNameAr: true,
  employeeNumber: true,
  role: true,
  department: {
    select: { id: true, code: true, nameEn: true, nameAr: true },
  },
} satisfies Prisma.UserSelect;

type UserRow = Prisma.UserGetPayload<{ select: typeof USER_SELECT }>;

/**
 * Admin user lookup powering the USERS audience picker (docs 10 + 19).
 * Only active users are returned because published notifications resolve
 * recipients from active users only (doc 15).
 */
@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async list(query: ListUsersQueryDto): Promise<UserListResult> {
    const search = query.search?.trim();

    const where: Prisma.UserWhereInput = {
      isActive: true,
      ...(query.role ? { role: query.role } : {}),
      ...(query.departmentCode
        ? { department: { code: query.departmentCode } }
        : {}),
      ...(search
        ? {
            OR: [
              { fullNameEn: { contains: search, mode: 'insensitive' } },
              { fullNameAr: { contains: search, mode: 'insensitive' } },
              { email: { contains: search, mode: 'insensitive' } },
              { employeeNumber: { contains: search, mode: 'insensitive' } },
            ],
          }
        : {}),
    };

    const [total, rows] = await this.prisma.$transaction([
      this.prisma.user.count({ where }),
      this.prisma.user.findMany({
        where,
        select: USER_SELECT,
        orderBy: [{ fullNameEn: 'asc' }, { email: 'asc' }],
        skip: (query.page - 1) * query.pageSize,
        take: query.pageSize,
      }),
    ]);

    return {
      items: rows.map((row) => this.toListItem(row)),
      page: query.page,
      pageSize: query.pageSize,
      total,
    };
  }

  private toListItem(row: UserRow): UserListItem {
    return {
      id: row.id,
      email: row.email,
      fullNameEn: row.fullNameEn,
      fullNameAr: row.fullNameAr,
      employeeNumber: row.employeeNumber,
      role: row.role,
      department: row.department,
    };
  }
}
