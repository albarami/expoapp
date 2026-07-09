import { HttpStatus, Inject, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  AccessRequestStage,
  AccessRequestStatus,
  ApprovalDecision,
  ApprovalStage,
  OutboxStatus,
  Prisma,
  UserRole,
} from '@prisma/client';
import { Request } from 'express';
import { AuditActions } from '../audit/audit-actions';
import { AuditService } from '../audit/audit.service';
import { AuthUser } from '../auth/types/auth-user';
import { ErrorCode } from '../common/constants/error-codes';
import { BusinessException } from '../common/exceptions/business.exception';
import {
  FUSION_ADAPTER,
  OUTBOX_TYPE_ACCESS_PROVISIONING,
} from '../fusion/fusion.constants';
import type {
  FusionAdapter,
  SubmitFusionProvisioningInput,
} from '../fusion/fusion-adapter.interface';
import { IntegrationOutboxService } from '../fusion/integration-outbox.service';
import { PrismaService } from '../prisma/prisma.service';
import {
  ApprovalDecisionInput,
  ApprovalEventType,
  ApprovalListItem,
  ApprovalListResult,
  DecideApprovalResult,
} from './approvals.types';
import { DecideApprovalDto } from './dto/decide-approval.dto';
import { ListApprovalsQueryDto } from './dto/list-approvals-query.dto';

type ApprovalTaskRow = Prisma.ApprovalTaskGetPayload<{
  include: {
    accessRequest: {
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
            riskLevel: true;
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
            externalRef: true;
          };
        };
      };
    };
    assignee: {
      select: {
        id: true;
        fullNameEn: true;
        fullNameAr: true;
        email: true;
        externalRef: true;
      };
    };
  };
}>;

type DecidedTaskSnapshot = {
  taskId: string;
  decision: ApprovalDecision;
  requestId: string;
  requestNumber: string;
  status: AccessRequestStatus;
  currentStage: AccessRequestStage;
  previousStatus: AccessRequestStatus;
  stage: ApprovalStage;
  comment: string | null;
  auditAction: string;
  provisioningPayload?: SubmitFusionProvisioningInput;
  outboxId?: string;
};

@Injectable()
export class ApprovalsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly auditService: AuditService,
    private readonly configService: ConfigService,
    private readonly outboxService: IntegrationOutboxService,
    @Inject(FUSION_ADAPTER)
    private readonly fusionAdapter: FusionAdapter,
  ) {}

  async listApprovals(
    currentUser: AuthUser,
    query: ListApprovalsQueryDto,
  ): Promise<ApprovalListResult> {
    this.assertCanList(currentUser);

    const page = query.page;
    const pageSize = query.pageSize;
    const where = this.buildListWhere(currentUser, query);

    const [total, rows] = await this.prisma.$transaction([
      this.prisma.approvalTask.count({ where }),
      this.prisma.approvalTask.findMany({
        where,
        include: {
          accessRequest: {
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
                  riskLevel: true,
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
                  externalRef: true,
                },
              },
            },
          },
          assignee: {
            select: {
              id: true,
              fullNameEn: true,
              fullNameAr: true,
              email: true,
              externalRef: true,
            },
          },
        },
        orderBy: [{ createdAt: 'desc' }],
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

  async decide(
    currentUser: AuthUser,
    taskId: string,
    dto: DecideApprovalDto,
    request?: Request,
  ): Promise<DecideApprovalResult> {
    this.assertDecisionComment(dto);

    const task = await this.prisma.approvalTask.findUnique({
      where: { id: taskId },
      include: {
        accessRequest: {
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
                riskLevel: true,
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
                externalRef: true,
              },
            },
          },
        },
        assignee: {
          select: {
            id: true,
            fullNameEn: true,
            fullNameAr: true,
            email: true,
            externalRef: true,
          },
        },
      },
    });

    if (!task) {
      throw new BusinessException({
        code: ErrorCode.NOT_FOUND,
        message: 'Approval task not found',
        status: HttpStatus.NOT_FOUND,
      });
    }

    if (task.assigneeId !== currentUser.id) {
      throw new BusinessException({
        code: ErrorCode.NOT_TASK_ASSIGNEE,
        message: 'Only the assigned approver can decide this task',
        status: HttpStatus.FORBIDDEN,
      });
    }

    if (task.decision !== ApprovalDecision.PENDING) {
      throw new BusinessException({
        code: ErrorCode.APPROVAL_TASK_NOT_PENDING,
        message: 'Approval task has already been decided',
      });
    }

    const snapshot =
      dto.decision === ApprovalDecisionInput.APPROVED
        ? await this.applyApprove(currentUser, task)
        : await this.applyReject(currentUser, task, dto.comment!.trim());

    await this.writeDecisionAudits(currentUser, snapshot, request);

    if (snapshot.provisioningPayload) {
      await this.runProvisioning(currentUser, snapshot, request);
    }

    return {
      taskId: snapshot.taskId,
      decision: snapshot.decision,
      request: {
        id: snapshot.requestId,
        requestNumber: snapshot.requestNumber,
        status: snapshot.status,
        currentStage: snapshot.currentStage,
      },
    };
  }

  private assertCanList(user: AuthUser): void {
    if (
      user.role === UserRole.MANAGER ||
      user.role === UserRole.SECURITY_ADMIN ||
      user.role === UserRole.SYSTEM_ADMIN
    ) {
      return;
    }

    throw new BusinessException({
      code: ErrorCode.FORBIDDEN,
      message: 'You do not have access to the approvals queue',
      status: HttpStatus.FORBIDDEN,
    });
  }

  private assertDecisionComment(dto: DecideApprovalDto): void {
    if (dto.decision !== ApprovalDecisionInput.REJECTED) {
      return;
    }
    if (!dto.comment || dto.comment.trim().length === 0) {
      throw new BusinessException({
        code: ErrorCode.VALIDATION_ERROR,
        message: 'comment is required when rejecting an approval',
      });
    }
  }

  private buildListWhere(
    currentUser: AuthUser,
    query: ListApprovalsQueryDto,
  ): Prisma.ApprovalTaskWhereInput {
    const filters: Prisma.ApprovalTaskWhereInput = {
      ...(query.status ? { decision: query.status } : {}),
    };

    if (currentUser.role === UserRole.SYSTEM_ADMIN) {
      return filters;
    }

    return {
      ...filters,
      assigneeId: currentUser.id,
    };
  }

  private async applyApprove(
    actor: AuthUser,
    task: ApprovalTaskRow,
  ): Promise<DecidedTaskSnapshot> {
    if (task.stage === ApprovalStage.MANAGER) {
      return this.applyManagerApprove(actor, task);
    }
    if (task.stage === ApprovalStage.SECURITY) {
      return this.applySecurityApprove(actor, task);
    }

    throw new BusinessException({
      code: ErrorCode.INTERNAL_ERROR,
      message: `Unsupported approval stage ${task.stage as string}`,
      status: HttpStatus.INTERNAL_SERVER_ERROR,
    });
  }

  private async applyManagerApprove(
    actor: AuthUser,
    task: ApprovalTaskRow,
  ): Promise<DecidedTaskSnapshot> {
    const previousStatus = task.accessRequest.status;
    const requiresSecurity =
      task.accessRequest.securityRole.requiresSecurityApproval;
    const comment = null;
    const decidedAt = new Date();

    if (requiresSecurity) {
      const securityAssignee = await this.resolveSecurityAssignee();

      const updated = await this.prisma.$transaction(async (tx) => {
        await tx.approvalTask.update({
          where: { id: task.id },
          data: {
            decision: ApprovalDecision.APPROVED,
            comment,
            decidedAt,
          },
        });

        const accessRequest = await tx.accessRequest.update({
          where: { id: task.accessRequestId },
          data: {
            status: AccessRequestStatus.SECURITY_PENDING,
            currentStage: AccessRequestStage.SECURITY,
          },
        });

        await tx.accessRequestEvent.create({
          data: {
            accessRequestId: task.accessRequestId,
            actorId: actor.id,
            eventType: ApprovalEventType.ManagerApproved,
            messageEn: `Manager approved by ${actor.fullNameEn}`,
            messageAr: `تمت موافقة المدير بواسطة ${actor.fullNameAr ?? actor.fullNameEn}`,
            metadata: {
              taskId: task.id,
              previousStatus,
              newStatus: AccessRequestStatus.SECURITY_PENDING,
            },
          },
        });

        await tx.approvalTask.create({
          data: {
            accessRequestId: task.accessRequestId,
            stage: ApprovalStage.SECURITY,
            assigneeId: securityAssignee.id,
            decision: ApprovalDecision.PENDING,
          },
        });

        await tx.accessRequestEvent.create({
          data: {
            accessRequestId: task.accessRequestId,
            actorId: securityAssignee.id,
            eventType: ApprovalEventType.SecurityTaskAssigned,
            messageEn: `Security approval task assigned to ${securityAssignee.fullNameEn}`,
            messageAr: `تم تعيين مهمة موافقة الأمن إلى ${securityAssignee.fullNameAr ?? securityAssignee.fullNameEn}`,
            metadata: {
              stage: ApprovalStage.SECURITY,
              assigneeId: securityAssignee.id,
            },
          },
        });

        return accessRequest;
      });

      return {
        taskId: task.id,
        decision: ApprovalDecision.APPROVED,
        requestId: updated.id,
        requestNumber: updated.requestNumber,
        status: updated.status,
        currentStage: updated.currentStage,
        previousStatus,
        stage: ApprovalStage.MANAGER,
        comment,
        auditAction: AuditActions.ApprovalManagerApproved,
      };
    }

    const provisioningPayload = this.buildProvisioningPayload(task, [
      task.assignee.externalRef,
    ]);

    const updated = await this.prisma.$transaction(async (tx) => {
      await tx.approvalTask.update({
        where: { id: task.id },
        data: {
          decision: ApprovalDecision.APPROVED,
          comment,
          decidedAt,
        },
      });

      const accessRequest = await tx.accessRequest.update({
        where: { id: task.accessRequestId },
        data: {
          status: AccessRequestStatus.PROVISIONING,
          currentStage: AccessRequestStage.PROVISIONING,
        },
      });

      await tx.accessRequestEvent.create({
        data: {
          accessRequestId: task.accessRequestId,
          actorId: actor.id,
          eventType: ApprovalEventType.ManagerApproved,
          messageEn: `Manager approved by ${actor.fullNameEn}`,
          messageAr: `تمت موافقة المدير بواسطة ${actor.fullNameAr ?? actor.fullNameEn}`,
          metadata: {
            taskId: task.id,
            previousStatus,
            newStatus: AccessRequestStatus.PROVISIONING,
          },
        },
      });

      await tx.accessRequestEvent.create({
        data: {
          accessRequestId: task.accessRequestId,
          actorId: actor.id,
          eventType: ApprovalEventType.ProvisioningStarted,
          messageEn: 'Provisioning started',
          messageAr: 'بدأ تنفيذ الصلاحية',
          metadata: { requestNumber: accessRequest.requestNumber },
        },
      });

      const outbox = await tx.integrationOutbox.create({
        data: {
          type: OUTBOX_TYPE_ACCESS_PROVISIONING,
          payload: provisioningPayload as unknown as Prisma.InputJsonValue,
          status: OutboxStatus.PENDING,
          nextAttemptAt: new Date(),
        },
        select: { id: true },
      });

      return { accessRequest, outboxId: outbox.id };
    });

    return {
      taskId: task.id,
      decision: ApprovalDecision.APPROVED,
      requestId: updated.accessRequest.id,
      requestNumber: updated.accessRequest.requestNumber,
      status: updated.accessRequest.status,
      currentStage: updated.accessRequest.currentStage,
      previousStatus,
      stage: ApprovalStage.MANAGER,
      comment,
      auditAction: AuditActions.ApprovalManagerApproved,
      provisioningPayload,
      outboxId: updated.outboxId,
    };
  }

  private async applySecurityApprove(
    actor: AuthUser,
    task: ApprovalTaskRow,
  ): Promise<DecidedTaskSnapshot> {
    const previousStatus = task.accessRequest.status;
    const decidedAt = new Date();

    const priorApprovals = await this.prisma.approvalTask.findMany({
      where: {
        accessRequestId: task.accessRequestId,
        decision: ApprovalDecision.APPROVED,
      },
      include: {
        assignee: { select: { externalRef: true } },
      },
    });

    const approvedByExternalRefs = [
      ...priorApprovals.map((row) => row.assignee.externalRef),
      task.assignee.externalRef,
    ];

    const provisioningPayload = this.buildProvisioningPayload(
      task,
      approvedByExternalRefs,
    );

    const updated = await this.prisma.$transaction(async (tx) => {
      await tx.approvalTask.update({
        where: { id: task.id },
        data: {
          decision: ApprovalDecision.APPROVED,
          comment: null,
          decidedAt,
        },
      });

      const accessRequest = await tx.accessRequest.update({
        where: { id: task.accessRequestId },
        data: {
          status: AccessRequestStatus.PROVISIONING,
          currentStage: AccessRequestStage.PROVISIONING,
        },
      });

      await tx.accessRequestEvent.create({
        data: {
          accessRequestId: task.accessRequestId,
          actorId: actor.id,
          eventType: ApprovalEventType.SecurityApproved,
          messageEn: `Security approved by ${actor.fullNameEn}`,
          messageAr: `تمت موافقة الأمن بواسطة ${actor.fullNameAr ?? actor.fullNameEn}`,
          metadata: {
            taskId: task.id,
            previousStatus,
            newStatus: AccessRequestStatus.PROVISIONING,
          },
        },
      });

      await tx.accessRequestEvent.create({
        data: {
          accessRequestId: task.accessRequestId,
          actorId: actor.id,
          eventType: ApprovalEventType.ProvisioningStarted,
          messageEn: 'Provisioning started',
          messageAr: 'بدأ تنفيذ الصلاحية',
          metadata: { requestNumber: accessRequest.requestNumber },
        },
      });

      const outbox = await tx.integrationOutbox.create({
        data: {
          type: OUTBOX_TYPE_ACCESS_PROVISIONING,
          payload: provisioningPayload as unknown as Prisma.InputJsonValue,
          status: OutboxStatus.PENDING,
          nextAttemptAt: new Date(),
        },
        select: { id: true },
      });

      return { accessRequest, outboxId: outbox.id };
    });

    return {
      taskId: task.id,
      decision: ApprovalDecision.APPROVED,
      requestId: updated.accessRequest.id,
      requestNumber: updated.accessRequest.requestNumber,
      status: updated.accessRequest.status,
      currentStage: updated.accessRequest.currentStage,
      previousStatus,
      stage: ApprovalStage.SECURITY,
      comment: null,
      auditAction: AuditActions.ApprovalSecurityApproved,
      provisioningPayload,
      outboxId: updated.outboxId,
    };
  }

  private async applyReject(
    actor: AuthUser,
    task: ApprovalTaskRow,
    comment: string,
  ): Promise<DecidedTaskSnapshot> {
    const previousStatus = task.accessRequest.status;
    const decidedAt = new Date();

    const isManager = task.stage === ApprovalStage.MANAGER;
    const newStatus = isManager
      ? AccessRequestStatus.MANAGER_REJECTED
      : AccessRequestStatus.SECURITY_REJECTED;
    const eventType = isManager
      ? ApprovalEventType.ManagerRejected
      : ApprovalEventType.SecurityRejected;
    const auditAction = isManager
      ? AuditActions.ApprovalManagerRejected
      : AuditActions.ApprovalSecurityRejected;

    const updated = await this.prisma.$transaction(async (tx) => {
      await tx.approvalTask.update({
        where: { id: task.id },
        data: {
          decision: ApprovalDecision.REJECTED,
          comment,
          decidedAt,
        },
      });

      const accessRequest = await tx.accessRequest.update({
        where: { id: task.accessRequestId },
        data: {
          status: newStatus,
          currentStage: AccessRequestStage.COMPLETE,
        },
      });

      await tx.accessRequestEvent.create({
        data: {
          accessRequestId: task.accessRequestId,
          actorId: actor.id,
          eventType,
          messageEn: isManager
            ? `Manager rejected by ${actor.fullNameEn}`
            : `Security rejected by ${actor.fullNameEn}`,
          messageAr: isManager
            ? `تم الرفض من المدير بواسطة ${actor.fullNameAr ?? actor.fullNameEn}`
            : `تم الرفض من الأمن بواسطة ${actor.fullNameAr ?? actor.fullNameEn}`,
          metadata: {
            taskId: task.id,
            previousStatus,
            newStatus,
            comment,
          },
        },
      });

      return accessRequest;
    });

    return {
      taskId: task.id,
      decision: ApprovalDecision.REJECTED,
      requestId: updated.id,
      requestNumber: updated.requestNumber,
      status: updated.status,
      currentStage: updated.currentStage,
      previousStatus,
      stage: task.stage,
      comment,
      auditAction,
    };
  }

  private async runProvisioning(
    actor: AuthUser,
    snapshot: DecidedTaskSnapshot,
    request?: Request,
  ): Promise<void> {
    const payload = snapshot.provisioningPayload;
    const outboxId = snapshot.outboxId;
    if (!payload || !outboxId) {
      return;
    }

    const fusionMode = this.configService.get<string>('FUSION_MODE', 'mock');

    try {
      const result = await this.fusionAdapter.submitAccessProvisioning(payload);

      if (result.status === 'FAILED') {
        await this.markProvisioningFailed({
          actor,
          snapshot,
          outboxId,
          externalRequestId: result.externalRequestId,
          errorMessage: result.message ?? 'Fusion provisioning failed',
          request,
        });
        snapshot.status = AccessRequestStatus.FAILED;
        snapshot.currentStage = AccessRequestStage.COMPLETE;
        return;
      }

      const completedAt = new Date();
      const isMockImmediate =
        fusionMode === 'mock' || result.status === 'COMPLETED';

      if (isMockImmediate) {
        await this.prisma.$transaction(async (tx) => {
          await tx.accessRequest.update({
            where: { id: snapshot.requestId },
            data: {
              status: AccessRequestStatus.COMPLETED,
              currentStage: AccessRequestStage.COMPLETE,
              completedAt,
              externalFusionRequestId: result.externalRequestId,
            },
          });

          await tx.accessRequestEvent.create({
            data: {
              accessRequestId: snapshot.requestId,
              actorId: actor.id,
              eventType: ApprovalEventType.Completed,
              messageEn: 'Access provisioning completed',
              messageAr: 'اكتمل تنفيذ الصلاحية',
              metadata: {
                externalFusionRequestId: result.externalRequestId,
                fusionStatus: result.status,
              },
            },
          });
        });

        await this.outboxService.markCompleted(outboxId);

        await this.auditService.record({
          actorId: actor.id,
          actorEmail: actor.email,
          action: AuditActions.AccessRequestCompleted,
          entityType: 'AccessRequest',
          entityId: snapshot.requestId,
          ipAddress: this.extractIp(request),
          userAgent: request?.headers['user-agent'],
          metadata: {
            requestNumber: snapshot.requestNumber,
            previousStatus: AccessRequestStatus.PROVISIONING,
            newStatus: AccessRequestStatus.COMPLETED,
            externalFusionRequestId: result.externalRequestId,
            outboxId,
          },
        });

        snapshot.status = AccessRequestStatus.COMPLETED;
        snapshot.currentStage = AccessRequestStage.COMPLETE;
        return;
      }

      await this.prisma.accessRequest.update({
        where: { id: snapshot.requestId },
        data: {
          externalFusionRequestId: result.externalRequestId,
          status: AccessRequestStatus.PROVISIONING,
          currentStage: AccessRequestStage.PROVISIONING,
        },
      });

      snapshot.status = AccessRequestStatus.PROVISIONING;
      snapshot.currentStage = AccessRequestStage.PROVISIONING;
    } catch (error) {
      const message =
        error instanceof Error ? error.message : 'Fusion provisioning failed';
      await this.markProvisioningFailed({
        actor,
        snapshot,
        outboxId,
        externalRequestId: null,
        errorMessage: message,
        request,
      });
      snapshot.status = AccessRequestStatus.FAILED;
      snapshot.currentStage = AccessRequestStage.COMPLETE;
    }
  }

  private async markProvisioningFailed(params: {
    actor: AuthUser;
    snapshot: DecidedTaskSnapshot;
    outboxId: string;
    externalRequestId: string | null;
    errorMessage: string;
    request?: Request;
  }): Promise<void> {
    await this.prisma.$transaction(async (tx) => {
      await tx.accessRequest.update({
        where: { id: params.snapshot.requestId },
        data: {
          status: AccessRequestStatus.FAILED,
          currentStage: AccessRequestStage.COMPLETE,
          ...(params.externalRequestId
            ? { externalFusionRequestId: params.externalRequestId }
            : {}),
        },
      });

      await tx.accessRequestEvent.create({
        data: {
          accessRequestId: params.snapshot.requestId,
          actorId: params.actor.id,
          eventType: ApprovalEventType.Failed,
          messageEn: 'Access provisioning failed',
          messageAr: 'فشل تنفيذ الصلاحية',
          metadata: {
            error: params.errorMessage,
            externalFusionRequestId: params.externalRequestId,
          },
        },
      });
    });

    await this.outboxService.markFailed({
      id: params.outboxId,
      error: params.errorMessage,
      terminal: true,
    });

    await this.auditService.record({
      actorId: params.actor.id,
      actorEmail: params.actor.email,
      action: AuditActions.AccessRequestFailed,
      entityType: 'AccessRequest',
      entityId: params.snapshot.requestId,
      ipAddress: this.extractIp(params.request),
      userAgent: params.request?.headers['user-agent'],
      metadata: {
        requestNumber: params.snapshot.requestNumber,
        previousStatus: AccessRequestStatus.PROVISIONING,
        newStatus: AccessRequestStatus.FAILED,
        error: params.errorMessage,
        outboxId: params.outboxId,
      },
    });
  }

  private async writeDecisionAudits(
    actor: AuthUser,
    snapshot: DecidedTaskSnapshot,
    request?: Request,
  ): Promise<void> {
    await this.auditService.record({
      actorId: actor.id,
      actorEmail: actor.email,
      action: snapshot.auditAction,
      entityType: 'ApprovalTask',
      entityId: snapshot.taskId,
      ipAddress: this.extractIp(request),
      userAgent: request?.headers['user-agent'],
      metadata: {
        taskId: snapshot.taskId,
        requestId: snapshot.requestId,
        requestNumber: snapshot.requestNumber,
        previousStatus: snapshot.previousStatus,
        newStatus: snapshot.status,
        decision: snapshot.decision,
        comment: snapshot.comment,
        stage: snapshot.stage,
        actorId: actor.id,
        actorEmail: actor.email,
      },
    });

    if (snapshot.provisioningPayload) {
      await this.auditService.record({
        actorId: actor.id,
        actorEmail: actor.email,
        action: AuditActions.AccessRequestProvisioningStarted,
        entityType: 'AccessRequest',
        entityId: snapshot.requestId,
        ipAddress: this.extractIp(request),
        userAgent: request?.headers['user-agent'],
        metadata: {
          requestNumber: snapshot.requestNumber,
          previousStatus: snapshot.previousStatus,
          newStatus: AccessRequestStatus.PROVISIONING,
        },
      });
    }
  }

  private buildProvisioningPayload(
    task: ApprovalTaskRow,
    approvedByExternalRefs: string[],
  ): SubmitFusionProvisioningInput {
    return {
      requestNumber: task.accessRequest.requestNumber,
      requesterExternalRef: task.accessRequest.requester.externalRef,
      systemCode: task.accessRequest.system.code,
      roleCode: task.accessRequest.securityRole.code,
      justification: task.accessRequest.businessJustification,
      startDate: task.accessRequest.startDate?.toISOString(),
      endDate: task.accessRequest.endDate?.toISOString(),
      approvedByExternalRefs: [...new Set(approvedByExternalRefs)],
    };
  }

  private async resolveSecurityAssignee(): Promise<{
    id: string;
    fullNameEn: string;
    fullNameAr: string | null;
  }> {
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

  private toListItem(row: ApprovalTaskRow): ApprovalListItem {
    const accessRequest = row.accessRequest;
    return {
      id: row.id,
      stage: row.stage,
      decision: row.decision,
      comment: row.comment,
      decidedAt: row.decidedAt?.toISOString() ?? null,
      createdAt: row.createdAt.toISOString(),
      accessRequest: {
        id: accessRequest.id,
        requestNumber: accessRequest.requestNumber,
        status: accessRequest.status,
        currentStage: accessRequest.currentStage,
        urgency: accessRequest.urgency,
        accessDuration: accessRequest.accessDuration,
        submittedAt: accessRequest.submittedAt?.toISOString() ?? null,
        system: {
          id: accessRequest.system.id,
          code: accessRequest.system.code,
          nameEn: accessRequest.system.nameEn,
          nameAr: accessRequest.system.nameAr,
        },
        securityRole: {
          id: accessRequest.securityRole.id,
          code: accessRequest.securityRole.code,
          nameEn: accessRequest.securityRole.nameEn,
          nameAr: accessRequest.securityRole.nameAr,
          riskLevel: accessRequest.securityRole.riskLevel,
        },
        requester: {
          id: accessRequest.requester.id,
          fullNameEn: accessRequest.requester.fullNameEn,
          fullNameAr: accessRequest.requester.fullNameAr,
          email: accessRequest.requester.email,
        },
      },
    };
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
