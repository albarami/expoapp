import {
  AudienceType,
  NotificationPriority,
  NotificationStatus,
} from '@prisma/client';

export const DEFAULT_NOTIFICATION_PAGE = 1;
export const DEFAULT_NOTIFICATION_PAGE_SIZE = 20;
export const MAX_NOTIFICATION_PAGE_SIZE = 100;

export type NotificationListItem = {
  id: string;
  titleEn: string;
  titleAr: string | null;
  bodyEn: string;
  bodyAr: string | null;
  priority: NotificationPriority;
  status: NotificationStatus;
  audienceType: AudienceType;
  readAt: string | null;
  createdAt: string;
};

export type NotificationDetail = NotificationListItem & {
  audienceFilter: unknown;
  publishAt: string | null;
  expiresAt: string | null;
  deliveredAt: string | null;
};

export type CreateNotificationResult = {
  id: string;
  status: NotificationStatus;
  recipientCount: number;
};

export type NotificationStats = {
  notificationId: string;
  recipientCount: number;
  deliveredCount: number;
  readCount: number;
  unreadCount: number;
  readPercentage: number;
};

export type CancelNotificationResult = {
  id: string;
  status: NotificationStatus;
};

export type NotificationListResult = {
  items: NotificationListItem[];
  page: number;
  pageSize: number;
  total: number;
};
