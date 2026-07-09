import { Injectable } from '@nestjs/common';
import {
  AccessRequestStatus,
  ApprovalStage,
  NotificationStatus,
  UserRole,
} from '@prisma/client';
import { AuthUser } from '../auth/types/auth-user';
import { PrismaService } from '../prisma/prisma.service';
import {
  DashboardAccessWorkflowStats,
  DashboardAuditItem,
  DashboardNotificationItem,
  DashboardNotificationStats,
  DashboardRequestItem,
  DashboardSummaryResponse,
  HIGH_RISK_LEVELS,
  LATEST_ITEMS_LIMIT,
  MANAGER_APPROVAL_STAGE,
  OPEN_ACCESS_REQUEST_STATUSES,
  PENDING_APPROVAL_DECISION,
  RECENT_AUDIT_LIMIT,
  SECURITY_APPROVAL_STAGE,
} from './dashboard.types';

@Injectable()
export class DashboardService {
  constructor(private readonly prisma: PrismaService) {}

  async getSummary(user: AuthUser): Promise<DashboardSummaryResponse> {
    const [
      unreadNotifications,
      openAccessRequests,
      completedRequests,
      pendingApprovals,
      latestNotifications,
      latestRequests,
    ] = await Promise.all([
      this.countUnreadNotifications(user.id),
      this.countOpenAccessRequestsForRequester(user.id),
      this.countCompletedRequestsForRequester(user.id),
      this.countPendingApprovalsForAssignee(user.id),
      this.listLatestNotifications(user.id),
      this.listLatestRequestsForRequester(user.id),
    ]);

    const base: DashboardSummaryResponse = {
      role: user.role,
      unreadNotifications,
      openAccessRequests,
      completedRequests,
      pendingApprovals,
      latestNotifications,
      latestRequests,
    };

    switch (user.role) {
      case UserRole.MANAGER:
        return {
          ...base,
          teamOpenRequests: await this.countTeamOpenRequests(user.id),
        };
      case UserRole.SECURITY_ADMIN:
        return {
          ...base,
          pendingSecurityApprovals: await this.countPendingApprovalsByStage(
            SECURITY_APPROVAL_STAGE,
          ),
          highRiskOpenRequests: await this.countHighRiskOpenRequests(),
          recentAuditEvents: await this.listRecentAuditEvents(),
        };
      case UserRole.SYSTEM_ADMIN:
        return {
          ...base,
          notificationStats: await this.getNotificationStats(),
          accessWorkflowStats: await this.getAccessWorkflowStats(),
          recentAuditEvents: await this.listRecentAuditEvents(),
        };
      default:
        return base;
    }
  }

  private countUnreadNotifications(userId: string): Promise<number> {
    return this.prisma.notificationRecipient.count({
      where: {
        userId,
        readAt: null,
        notification: {
          status: NotificationStatus.PUBLISHED,
        },
      },
    });
  }

  private countOpenAccessRequestsForRequester(userId: string): Promise<number> {
    return this.prisma.accessRequest.count({
      where: {
        requesterId: userId,
        status: { in: OPEN_ACCESS_REQUEST_STATUSES },
      },
    });
  }

  private countCompletedRequestsForRequester(userId: string): Promise<number> {
    return this.prisma.accessRequest.count({
      where: {
        requesterId: userId,
        status: AccessRequestStatus.COMPLETED,
      },
    });
  }

  private countPendingApprovalsForAssignee(userId: string): Promise<number> {
    return this.prisma.approvalTask.count({
      where: {
        assigneeId: userId,
        decision: PENDING_APPROVAL_DECISION,
      },
    });
  }

  private countTeamOpenRequests(managerId: string): Promise<number> {
    return this.prisma.accessRequest.count({
      where: {
        status: { in: OPEN_ACCESS_REQUEST_STATUSES },
        requester: { managerId },
      },
    });
  }

  private countPendingApprovalsByStage(stage: ApprovalStage): Promise<number> {
    return this.prisma.approvalTask.count({
      where: {
        stage,
        decision: PENDING_APPROVAL_DECISION,
      },
    });
  }

  private countHighRiskOpenRequests(): Promise<number> {
    return this.prisma.accessRequest.count({
      where: {
        status: { in: OPEN_ACCESS_REQUEST_STATUSES },
        securityRole: {
          riskLevel: { in: HIGH_RISK_LEVELS },
        },
      },
    });
  }

  private async listLatestNotifications(
    userId: string,
  ): Promise<DashboardNotificationItem[]> {
    const rows = await this.prisma.notificationRecipient.findMany({
      where: {
        userId,
        notification: {
          status: NotificationStatus.PUBLISHED,
        },
      },
      orderBy: { createdAt: 'desc' },
      take: LATEST_ITEMS_LIMIT,
      select: {
        readAt: true,
        notification: {
          select: {
            id: true,
            titleEn: true,
            titleAr: true,
            priority: true,
            status: true,
            createdAt: true,
          },
        },
      },
    });

    return rows.map((row) => ({
      id: row.notification.id,
      titleEn: row.notification.titleEn,
      titleAr: row.notification.titleAr,
      priority: row.notification.priority,
      status: row.notification.status,
      readAt: row.readAt?.toISOString() ?? null,
      createdAt: row.notification.createdAt.toISOString(),
    }));
  }

  private async listLatestRequestsForRequester(
    userId: string,
  ): Promise<DashboardRequestItem[]> {
    const rows = await this.prisma.accessRequest.findMany({
      where: { requesterId: userId },
      orderBy: { createdAt: 'desc' },
      take: LATEST_ITEMS_LIMIT,
      select: {
        id: true,
        requestNumber: true,
        status: true,
        urgency: true,
        submittedAt: true,
        createdAt: true,
        system: {
          select: {
            code: true,
            nameEn: true,
          },
        },
        securityRole: {
          select: {
            code: true,
            nameEn: true,
          },
        },
      },
    });

    return rows.map((row) => ({
      id: row.id,
      requestNumber: row.requestNumber,
      status: row.status,
      urgency: row.urgency,
      systemCode: row.system.code,
      systemNameEn: row.system.nameEn,
      securityRoleCode: row.securityRole.code,
      securityRoleNameEn: row.securityRole.nameEn,
      submittedAt: row.submittedAt?.toISOString() ?? null,
      createdAt: row.createdAt.toISOString(),
    }));
  }

  private async listRecentAuditEvents(): Promise<DashboardAuditItem[]> {
    const rows = await this.prisma.auditLog.findMany({
      orderBy: { createdAt: 'desc' },
      take: RECENT_AUDIT_LIMIT,
      select: {
        id: true,
        action: true,
        entityType: true,
        entityId: true,
        actorEmail: true,
        createdAt: true,
      },
    });

    return rows.map((row) => ({
      id: row.id,
      action: row.action,
      entityType: row.entityType,
      entityId: row.entityId,
      actorEmail: row.actorEmail,
      createdAt: row.createdAt.toISOString(),
    }));
  }

  private async getNotificationStats(): Promise<DashboardNotificationStats> {
    const [publishedCount, recipientCount, readCount] = await Promise.all([
      this.prisma.notification.count({
        where: { status: NotificationStatus.PUBLISHED },
      }),
      this.prisma.notificationRecipient.count(),
      this.prisma.notificationRecipient.count({
        where: { readAt: { not: null } },
      }),
    ]);

    const readPercentage =
      recipientCount === 0 ? 0 : Math.round((readCount / recipientCount) * 100);

    return {
      publishedCount,
      recipientCount,
      readCount,
      readPercentage,
    };
  }

  private async getAccessWorkflowStats(): Promise<DashboardAccessWorkflowStats> {
    const [
      openAccessRequests,
      pendingManagerApprovals,
      pendingSecurityApprovals,
      completedRequests,
    ] = await Promise.all([
      this.prisma.accessRequest.count({
        where: { status: { in: OPEN_ACCESS_REQUEST_STATUSES } },
      }),
      this.prisma.approvalTask.count({
        where: {
          stage: MANAGER_APPROVAL_STAGE,
          decision: PENDING_APPROVAL_DECISION,
        },
      }),
      this.countPendingApprovalsByStage(SECURITY_APPROVAL_STAGE),
      this.prisma.accessRequest.count({
        where: { status: AccessRequestStatus.COMPLETED },
      }),
    ]);

    return {
      openAccessRequests,
      pendingManagerApprovals,
      pendingSecurityApprovals,
      completedRequests,
    };
  }
}
