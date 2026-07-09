import { UserRole } from '@prisma/client';

export interface JwtAccessPayload {
  sub: string;
  email: string;
  role: UserRole;
  typ: 'access';
}

export interface JwtRefreshPayload {
  sub: string;
  email: string;
  role: UserRole;
  typ: 'refresh';
}

export type JwtPayload = JwtAccessPayload | JwtRefreshPayload;
