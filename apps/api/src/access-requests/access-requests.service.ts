import { HttpStatus, Inject, Injectable } from '@nestjs/common';
import {
  AccessDuration,
  AccessRequest,
  AccessRequestStage,
  AccessRequestStatus,
  ApprovalDecision,
  ApprovalStage,
  Prisma,
  UserRole,
} from '@prisma/client';
import { Request } from 'express';
import { AuditActions } from '../audit/audit-actions';
import { AuditService } from '../audit/audit.service';
import { AuthUser } from '../auth/types/auth-user';
import { ErrorCode } from '../common/constants/error-codes';
import { BusinessException } from '../common/exceptions/business.exception';
import { FUSION_ADAPTER } from '../fusion/fusion.constants';
import type { FusionAdapter } from '../fusion/fusion-adapter.interface';
import { PrismaService } from '../prisma/prisma.service';
import {
  AccessRequestDetail,
  AccessRequestEventType,
  AccessRequestListItem,
  AccessRequestListResult,
  AccessRequestNextApprover,
  AccessRequestTimelineEvent,
  CANCELABLE_STATUSES,
  CancelAccessRequestResult,
  DUPLICATE_ACTIVE_STATUSES,
  SubmitAccessRequestResult,
} from './access-requests.types';
import { CreateAccessRequestDto } from './dto/create-access-request.dto';
import { ListAccessRequestsQueryDto } from './dto/list-access-requests-query.dto';

type RequestListRow = Prisma.AccessRequestGetPayload<{
  include: {
    system: {
      select: { id: true; code: true; nameEn: true; nameAr: true };
    };
    securityRole: {
      select: { id: true; code: true; nameEn: true; nameAr: true };
    };
    requester: {
      select: {
        id: true;
        fullNameEn: true;
        fullNameAr: true;
        email: true;
      };
    };
  };
}>;

type RequestDetailRow = Prisma.AccessRequestGetPayload<{
  include: {
    system: {
      select: { id: true; code: true; nameEn: true; nameAr: true };
    };
    securityRole: {
      select: {
        id: true;
        code: true;
        nameEn: true;
        nameAr: true;
        requiresManagerApproval: true;
        requiresSecurityApproval: true;
      };
    };
    requester: {
      select: {
        id: true;
        fullNameEn: true;
        fullNameAr: true;
        email: true;
      };
    };
    events: {
      include: {
        actor: {
          select: { id: true; fullNameEn: true; fullNameAr: true };
        };
      };
    };
    approvals: {
      include: {
        assignee: {
          select: { id: true; fullNameEn: true; fullNameAr: true };
        };
      };
    };
  };
}>;

@Injectable()
export class AccessRequestsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly auditService: AuditService,
    @Inject(FUSION_ADAPTER)
    private readonly fusionAdapter: FusionAdapter,
  ) {}

  async createRequest(
    requester: AuthUser,
    dto: CreateAccessRequestDto,
    request?: Request,
  ): Promise<SubmitAccessRequestResult> {
    this.assertCanCreate(requester);

    const dbRequester = await this.prisma.user.findUnique({
      where: { id: requester.id },
      select: {
        id: true,
        email: true,
        fullNameEn: true,
        fullNameAr: true,
        externalRef: true,
        isActive: true,
        managerId: true,
        manager: {
          select: {
            id: true,
            fullNameEn: true,
            fullNameAr: true,
            isActive: true,
            role: true,
          },
        },
      },
    });

    if (!dbRequester || !dbRequester.isActive) {
      throw new BusinessException({
        code: ErrorCode.USER_INACTIVE,
        message: 'Requester account is inactive',
        status: HttpStatus.FORBIDDEN,
      });
    }

    const { startDate, endDate } = this.resolveAccessDates(dto);

    const securityRole = await this.prisma.securityRoleCatalog.findFirst({
      where: {
        id: dto.securityRoleId,
        systemId: dto.systemId,
      },
      include: {
        system: {
          select: { id: true, code: true, isActive: true },
        },
      },
    });

    if (
      !securityRole ||
      !securityRole.isActive ||
      !securityRole.system.isActive
    ) {
      throw new BusinessException({
        code: ErrorCode.ROLE_NOT_REQUESTABLE,
        message: 'Security role is inactive or not requestable for this system',
      });
    }

    const fusionValidation = await this.fusionAdapter.validateAccessRequest({
      requesterExternalRef: dbRequester.externalRef,
      systemCode: securityRole.system.code,
      roleCode: securityRole.code,
    });

    if (!fusionValidation.valid) {
      throw new BusinessException({
        code: fusionValidation.code ?? ErrorCode.ROLE_NOT_REQUESTABLE,
        message:
          fusionValidation.message ?? 'Access request failed Fusion validation',
      });
    }

    const requiresManager = securityRole.requiresManagerApproval;
    const requiresSecurity = securityRole.requiresSecurityApproval;

    if (!requiresManager && !requiresSecurity) {
      throw new BusinessException({
        code: ErrorCode.ROLE_NOT_REQUESTABLE,
        message: 'Security role has no approval path configured',
      });
    }

    let managerAssignee: AccessRequestNextApprover | null = null;
    if (requiresManager) {
      if (!dbRequester.manager || !dbRequester.manager.isActive) {
        throw new BusinessException({
          code: ErrorCode.MANAGER_NOT_FOUND,
          message:
            'Requester has no active manager required for this security role',
        });
      }
      managerAssignee = {
        id: dbRequester.manager.id,
        fullNameEn: dbRequester.manager.fullNameEn,
        fullNameAr: dbRequester.manager.fullNameAr,
      };
    }

    const duplicate = await this.prisma.accessRequest.findFirst({
      where: {
        requesterId: requester.id,
        systemId: dto.systemId,
        securityRoleId: dto.securityRoleId,
        status: { in: DUPLICATE_ACTIVE_STATUSES },
      },
      select: { id: true, requestNumber: true },
    });

    if (duplicate) {
      throw new BusinessException({
        code: ErrorCode.DUPLICATE_ACTIVE_REQUEST,
        message: `An active request already exists for this role (${duplicate.requestNumber})`,
      });
    }

    let securityAssignee: AccessRequestNextApprover | null = null;
    if (!requiresManager && requiresSecurity) {
      securityAssignee = await this.resolveSecurityAssignee();
    }

    const initialStatus = requiresManager
      ? AccessRequestStatus.MANAGER_PENDING
      : AccessRequestStatus.SECURITY_PENDING;
    const initialStage = requiresManager
      ? AccessRequestStage.MANAGER
      : AccessRequestStage.SECURITY;

    const nextApprover = requiresManager ? managerAssignee : securityAssignee;
    if (!nextApprover) {
      throw new BusinessException({
        code: ErrorCode.INTERNAL_ERROR,
        message: 'Unable to resolve next approver for access request',
        status: HttpStatus.INTERNAL_SERVER_ERROR,
      });
    }

    const justification = dto.businessJustification.trim();
    const submittedAt = new Date();

    const created = await this.prisma.$transaction(async (tx) => {
      const requestNumber = await this.generateRequestNumber(tx, submittedAt);

      const accessRequest = await tx.accessRequest.create({
        data: {
          requestNumber,
          requesterId: requester.id,
          systemId: dto.systemId,
          securityRoleId: dto.securityRoleId,
          businessJustification: justification,
          accessDuration: dto.accessDuration,
          startDate,
          endDate,
          urgency: dto.urgency,
          status: initialStatus,
          currentStage: initialStage,
          submittedAt,
        },
      });

      await tx.accessRequestEvent.create({
        data: {
          accessRequestId: accessRequest.id,
          actorId: requester.id,
          eventType: AccessRequestEventType.Submitted,
          messageEn: `Request submitted by ${dbRequester.fullNameEn}`,
          messageAr: `تم تقديم الطلب بواسطة ${dbRequester.fullNameAr ?? dbRequester.fullNameEn}`,
          metadata: {
            requestNumber,
            status: initialStatus,
            currentStage: initialStage,
          },
        },
      });

      if (requiresManager && managerAssignee) {
        await tx.approvalTask.create({
          data: {
            accessRequestId: accessRequest.id,
            stage: ApprovalStage.MANAGER,
            assigneeId: managerAssignee.id,
            decision: ApprovalDecision.PENDING,
          },
        });

        await tx.accessRequestEvent.create({
          data: {
            accessRequestId: accessRequest.id,
            actorId: managerAssignee.id,
            eventType: AccessRequestEventType.ManagerTaskAssigned,
            messageEn: `Manager approval task assigned to ${managerAssignee.fullNameEn}`,
            messageAr: `تم تعيين مهمة موافقة المدير إلى ${managerAssignee.fullNameAr ?? managerAssignee.fullNameEn}`,
            metadata: {
              stage: ApprovalStage.MANAGER,
              assigneeId: managerAssignee.id,
            },
          },
        });
      } else if (securityAssignee) {
        await tx.approvalTask.create({
          data: {
            accessRequestId: accessRequest.id,
            stage: ApprovalStage.SECURITY,
            assigneeId: securityAssignee.id,
            decision: ApprovalDecision.PENDING,
          },
        });

        await tx.accessRequestEvent.create({
          data: {
            accessRequestId: accessRequest.id,
            actorId: securityAssignee.id,
            eventType: AccessRequestEventType.SecurityTaskAssigned,
            messageEn: `Security approval task assigned to ${securityAssignee.fullNameEn}`,
            messageAr: `تم تعيين مهمة موافقة الأمن إلى ${securityAssignee.fullNameAr ?? securityAssignee.fullNameEn}`,
            metadata: {
              stage: ApprovalStage.SECURITY,
              assigneeId: securityAssignee.id,
            },
          },
        });
      }

      return accessRequest;
    });

    await this.auditService.record({
      actorId: requester.id,
      actorEmail: requester.email,
      action: AuditActions.AccessRequestSubmitted,
      entityType: 'AccessRequest',
      entityId: created.id,
      ipAddress: this.extractIp(request),
      userAgent: request?.headers['user-agent'],
      metadata: {
        requestNumber: created.requestNumber,
        status: created.status,
        currentStage: created.currentStage,
        systemId: created.systemId,
        securityRoleId: created.securityRoleId,
      },
    });

    return {
      id: created.id,
      requestNumber: created.requestNumber,
      status: created.status,
      currentStage: created.currentStage,
      nextApprover,
    };
  }

  async listRequests(
    currentUser: AuthUser,
    query: ListAccessRequestsQueryDto,
  ): Promise<AccessRequestListResult> {
    const page = query.page;
    const pageSize = query.pageSize;
    const where = this.buildListWhere(currentUser, query);

    const [total, rows] = await this.prisma.$transaction([
      this.prisma.accessRequest.count({ where }),
      this.prisma.accessRequest.findMany({
        where,
        include: {
          system: {
            select: { id: true, code: true, nameEn: true, nameAr: true },
          },
          securityRole: {
            select: { id: true, code: true, nameEn: true, nameAr: true },
          },
          requester: {
            select: {
              id: true,
              fullNameEn: true,
              fullNameAr: true,
              email: true,
            },
          },
        },
        orderBy: [{ submittedAt: 'desc' }, { createdAt: 'desc' }],
        skip: (page - 1) * pageSize,
        take: pageSize,
      }),
    ]);

    return {
      items: rows.map((row) => this.toListItem(row)),
      page,
      pageSize,
      total,
    };
  }

  async getRequest(
    currentUser: AuthUser,
    id: string,
  ): Promise<AccessRequestDetail> {
    const row = await this.prisma.accessRequest.findUnique({
      where: { id },
      include: {
        system: {
          select: { id: true, code: true, nameEn: true, nameAr: true },
        },
        securityRole: {
          select: {
            id: true,
            code: true,
            nameEn: true,
            nameAr: true,
            requiresManagerApproval: true,
            requiresSecurityApproval: true,
          },
        },
        requester: {
          select: {
            id: true,
            fullNameEn: true,
            fullNameAr: true,
            email: true,
          },
        },
        events: {
          include: {
            actor: {
              select: { id: true, fullNameEn: true, fullNameAr: true },
            },
          },
          orderBy: { createdAt: 'asc' },
        },
        approvals: {
          include: {
            assignee: {
              select: { id: true, fullNameEn: true, fullNameAr: true },
            },
          },
          orderBy: { createdAt: 'asc' },
        },
      },
    });

    if (!row) {
      throw new BusinessException({
        code: ErrorCode.ACCESS_REQUEST_NOT_FOUND,
        message: 'Access request not found',
        status: HttpStatus.NOT_FOUND,
      });
    }

    await this.assertCanRead(currentUser, row);

    return this.toDetail(row);
  }

  async cancelRequest(
    currentUser: AuthUser,
    id: string,
    request?: Request,
  ): Promise<CancelAccessRequestResult> {
    const existing = await this.prisma.accessRequest.findUnique({
      where: { id },
      select: {
        id: true,
        requestNumber: true,
        requesterId: true,
        status: true,
        currentStage: true,
      },
    });

    if (!existing) {
      throw new BusinessException({
        code: ErrorCode.ACCESS_REQUEST_NOT_FOUND,
        message: 'Access request not found',
        status: HttpStatus.NOT_FOUND,
      });
    }

    if (existing.requesterId !== currentUser.id) {
      throw new BusinessException({
        code: ErrorCode.FORBIDDEN,
        message: 'Only the requester can cancel this access request',
        status: HttpStatus.FORBIDDEN,
      });
    }

    if (!CANCELABLE_STATUSES.includes(existing.status)) {
      throw new BusinessException({
        code: ErrorCode.REQUEST_NOT_CANCELABLE,
        message: `Access request cannot be cancelled in status ${existing.status}`,
      });
    }

    const updated = await this.prisma.$transaction(async (tx) => {
      const accessRequest = await tx.accessRequest.update({
        where: { id },
        data: {
          status: AccessRequestStatus.CANCELLED,
          currentStage: AccessRequestStage.REQUESTER,
        },
      });

      await tx.approvalTask.updateMany({
        where: {
          accessRequestId: id,
          decision: ApprovalDecision.PENDING,
        },
        data: {
          decision: ApprovalDecision.RETURNED,
          comment: 'Cancelled by requester',
          decidedAt: new Date(),
        },
      });

      await tx.accessRequestEvent.create({
        data: {
          accessRequestId: id,
          actorId: currentUser.id,
          eventType: AccessRequestEventType.Cancelled,
          messageEn: `Request cancelled by ${currentUser.fullNameEn}`,
          messageAr: `تم إلغاء الطلب بواسطة ${currentUser.fullNameAr ?? currentUser.fullNameEn}`,
          metadata: {
            previousStatus: existing.status,
            previousStage: existing.currentStage,
          },
        },
      });

      return accessRequest;
    });

    await this.auditService.record({
      actorId: currentUser.id,
      actorEmail: currentUser.email,
      action: AuditActions.AccessRequestCancelled,
      entityType: 'AccessRequest',
      entityId: updated.id,
      ipAddress: this.extractIp(request),
      userAgent: request?.headers['user-agent'],
      metadata: {
        requestNumber: updated.requestNumber,
        previousStatus: existing.status,
      },
    });

    return {
      id: updated.id,
      requestNumber: updated.requestNumber,
      status: updated.status,
      currentStage: updated.currentStage,
    };
  }

  private assertCanCreate(user: AuthUser): void {
    if (user.role === UserRole.SYSTEM_ADMIN) {
      throw new BusinessException({
        code: ErrorCode.FORBIDDEN,
        message: 'System admin cannot submit access requests',
        status: HttpStatus.FORBIDDEN,
      });
    }
  }

  private async assertCanRead(
    currentUser: AuthUser,
    row: Pick<AccessRequest, 'id' | 'requesterId'> & {
      approvals?: Array<{
        assigneeId: string;
        decision: ApprovalDecision;
      }>;
    },
  ): Promise<void> {
    if (currentUser.role === UserRole.SYSTEM_ADMIN) {
      return;
    }

    if (row.requesterId === currentUser.id) {
      return;
    }

    if (currentUser.role === UserRole.MANAGER) {
      const isDirectReport = await this.prisma.user.findFirst({
        where: {
          id: row.requesterId,
          managerId: currentUser.id,
        },
        select: { id: true },
      });
      if (isDirectReport) {
        return;
      }
    }

    if (currentUser.role === UserRole.SECURITY_ADMIN) {
      return;
    }

    const assigned = (row.approvals ?? []).some(
      (task) => task.assigneeId === currentUser.id,
    );
    if (assigned) {
      return;
    }

    throw new BusinessException({
      code: ErrorCode.FORBIDDEN,
      message: 'You do not have access to this access request',
      status: HttpStatus.FORBIDDEN,
    });
  }

  private buildListWhere(
    currentUser: AuthUser,
    query: ListAccessRequestsQueryDto,
  ): Prisma.AccessRequestWhereInput {
    const filters: Prisma.AccessRequestWhereInput = {
      ...(query.status ? { status: query.status } : {}),
      ...(query.urgency ? { urgency: query.urgency } : {}),
      ...(query.systemId ? { systemId: query.systemId } : {}),
    };

    if (currentUser.role === UserRole.SYSTEM_ADMIN) {
      return {
        ...filters,
        ...(query.requesterId ? { requesterId: query.requesterId } : {}),
      };
    }

    if (currentUser.role === UserRole.SECURITY_ADMIN) {
      return {
        ...filters,
        ...(query.requesterId ? { requesterId: query.requesterId } : {}),
      };
    }

    if (currentUser.role === UserRole.MANAGER) {
      return {
        ...filters,
        OR: [
          { requesterId: currentUser.id },
          { requester: { managerId: currentUser.id } },
        ],
        ...(query.requesterId ? { requesterId: query.requesterId } : {}),
      };
    }

    return {
      ...filters,
      requesterId: currentUser.id,
    };
  }

  private resolveAccessDates(dto: CreateAccessRequestDto): {
    startDate: Date;
    endDate: Date | null;
  } {
    const startDate = new Date(dto.startDate);
    if (Number.isNaN(startDate.getTime())) {
      throw new BusinessException({
        code: ErrorCode.INVALID_ACCESS_DATES,
        message: 'startDate is invalid',
      });
    }

    if (dto.accessDuration === AccessDuration.TEMPORARY) {
      if (!dto.endDate) {
        throw new BusinessException({
          code: ErrorCode.INVALID_ACCESS_DATES,
          message: 'Temporary access requires endDate',
        });
      }

      const endDate = new Date(dto.endDate);
      if (
        Number.isNaN(endDate.getTime()) ||
        endDate.getTime() <= startDate.getTime()
      ) {
        throw new BusinessException({
          code: ErrorCode.INVALID_ACCESS_DATES,
          message: 'endDate must be after startDate',
        });
      }

      return { startDate, endDate };
    }

    if (dto.endDate) {
      const endDate = new Date(dto.endDate);
      if (Number.isNaN(endDate.getTime())) {
        throw new BusinessException({
          code: ErrorCode.INVALID_ACCESS_DATES,
          message: 'endDate is invalid',
        });
      }
      if (endDate.getTime() <= startDate.getTime()) {
        throw new BusinessException({
          code: ErrorCode.INVALID_ACCESS_DATES,
          message: 'endDate must be after startDate',
        });
      }
      return { startDate, endDate };
    }

    return { startDate, endDate: null };
  }

  private async generateRequestNumber(
    tx: Prisma.TransactionClient,
    submittedAt: Date,
  ): Promise<string> {
    const year = submittedAt.getUTCFullYear();
    const prefix = `AR-${year}-`;

    const latest = await tx.accessRequest.findFirst({
      where: {
        requestNumber: { startsWith: prefix },
      },
      orderBy: { requestNumber: 'desc' },
      select: { requestNumber: true },
    });

    let nextSequence = 1;
    if (latest) {
      const suffix = latest.requestNumber.slice(prefix.length);
      const parsed = Number.parseInt(suffix, 10);
      if (Number.isFinite(parsed) && parsed >= nextSequence) {
        nextSequence = parsed + 1;
      }
    }

    return `${prefix}${String(nextSequence).padStart(6, '0')}`;
  }

  private async resolveSecurityAssignee(): Promise<AccessRequestNextApprover> {
    const securityAdmin = await this.prisma.user.findFirst({
      where: {
        role: UserRole.SECURITY_ADMIN,
        isActive: true,
      },
      orderBy: { createdAt: 'asc' },
      select: {
        id: true,
        fullNameEn: true,
        fullNameAr: true,
      },
    });

    if (!securityAdmin) {
      throw new BusinessException({
        code: ErrorCode.INTERNAL_ERROR,
        message: 'No active security admin available for approval routing',
        status: HttpStatus.INTERNAL_SERVER_ERROR,
      });
    }

    return securityAdmin;
  }

  private toListItem(row: RequestListRow): AccessRequestListItem {
    return {
      id: row.id,
      requestNumber: row.requestNumber,
      status: row.status,
      currentStage: row.currentStage,
      urgency: row.urgency,
      accessDuration: row.accessDuration,
      system: {
        id: row.system.id,
        code: row.system.code,
        nameEn: row.system.nameEn,
        nameAr: row.system.nameAr,
      },
      securityRole: {
        id: row.securityRole.id,
        code: row.securityRole.code,
        nameEn: row.securityRole.nameEn,
        nameAr: row.securityRole.nameAr,
      },
      requester: {
        id: row.requester.id,
        fullNameEn: row.requester.fullNameEn,
        fullNameAr: row.requester.fullNameAr,
        email: row.requester.email,
      },
      submittedAt: row.submittedAt?.toISOString() ?? null,
      createdAt: row.createdAt.toISOString(),
    };
  }

  private toDetail(row: RequestDetailRow): AccessRequestDetail {
    const pendingTask = row.approvals.find(
      (task) => task.decision === ApprovalDecision.PENDING,
    );

    return {
      id: row.id,
      requestNumber: row.requestNumber,
      status: row.status,
      currentStage: row.currentStage,
      businessJustification: row.businessJustification,
      accessDuration: row.accessDuration,
      urgency: row.urgency,
      startDate: row.startDate?.toISOString() ?? null,
      endDate: row.endDate?.toISOString() ?? null,
      submittedAt: row.submittedAt?.toISOString() ?? null,
      completedAt: row.completedAt?.toISOString() ?? null,
      externalFusionRequestId: row.externalFusionRequestId,
      system: {
        id: row.system.id,
        code: row.system.code,
        nameEn: row.system.nameEn,
        nameAr: row.system.nameAr,
      },
      securityRole: {
        id: row.securityRole.id,
        code: row.securityRole.code,
        nameEn: row.securityRole.nameEn,
        nameAr: row.securityRole.nameAr,
        requiresManagerApproval: row.securityRole.requiresManagerApproval,
        requiresSecurityApproval: row.securityRole.requiresSecurityApproval,
      },
      requester: {
        id: row.requester.id,
        fullNameEn: row.requester.fullNameEn,
        fullNameAr: row.requester.fullNameAr,
        email: row.requester.email,
      },
      nextApprover: pendingTask
        ? {
            id: pendingTask.assignee.id,
            fullNameEn: pendingTask.assignee.fullNameEn,
            fullNameAr: pendingTask.assignee.fullNameAr,
          }
        : null,
      timeline: row.events.map((event) => this.toTimelineEvent(event)),
      createdAt: row.createdAt.toISOString(),
      updatedAt: row.updatedAt.toISOString(),
    };
  }

  private toTimelineEvent(event: {
    id: string;
    eventType: string;
    messageEn: string;
    messageAr: string | null;
    createdAt: Date;
    metadata: Prisma.JsonValue | null;
    actor: {
      id: string;
      fullNameEn: string;
      fullNameAr: string | null;
    } | null;
  }): AccessRequestTimelineEvent {
    return {
      id: event.id,
      eventType: event.eventType,
      messageEn: event.messageEn,
      messageAr: event.messageAr,
      actor: event.actor
        ? {
            id: event.actor.id,
            fullNameEn: event.actor.fullNameEn,
            fullNameAr: event.actor.fullNameAr,
          }
        : null,
      createdAt: event.createdAt.toISOString(),
      metadata: this.toMetadataRecord(event.metadata),
    };
  }

  private toMetadataRecord(
    metadata: Prisma.JsonValue | null,
  ): Record<string, unknown> | null {
    if (metadata === null) {
      return null;
    }
    if (typeof metadata === 'object' && !Array.isArray(metadata)) {
      return Object.fromEntries(Object.entries(metadata));
    }
    return { value: metadata };
  }

  private extractIp(request?: Request): string | undefined {
    if (!request) {
      return undefined;
    }
    const forwarded = request.headers['x-forwarded-for'];
    if (typeof forwarded === 'string' && forwarded.length > 0) {
      return forwarded.split(',')[0]?.trim();
    }
    return request.ip;
  }
}
