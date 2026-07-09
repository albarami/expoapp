export const DEFAULT_AUDIT_PAGE = 1;
export const DEFAULT_AUDIT_PAGE_SIZE = 20;
export const MAX_AUDIT_PAGE_SIZE = 100;

export interface AuditInput {
  actorId?: string;
  actorEmail?: string;
  action: string;
  entityType: string;
  entityId?: string;
  metadata?: Record<string, unknown>;
  ipAddress?: string;
  userAgent?: string;
}

export type AuditLogListItem = {
  id: string;
  actorId: string | null;
  actorEmail: string | null;
  action: string;
  entityType: string;
  entityId: string | null;
  metadata: Record<string, unknown> | null;
  ipAddress: string | null;
  userAgent: string | null;
  createdAt: string;
};

export type AuditLogListResult = {
  items: AuditLogListItem[];
  page: number;
  pageSize: number;
  total: number;
};
