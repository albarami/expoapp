export const AuthAuditAction = {
  LOGIN: 'AUTH_LOGIN',
  LOGOUT: 'AUTH_LOGOUT',
} as const;

export type AuthAuditAction =
  (typeof AuthAuditAction)[keyof typeof AuthAuditAction];
