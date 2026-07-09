import { Controller, Get, Post } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { Roles } from './decorators/roles.decorator';

/**
 * Temporary RBAC probe endpoints for T-API-03 authorization tests (BI-03).
 * Replaced by real notifications/audit modules in later tasks.
 */
@ApiTags('rbac-probe')
@ApiBearerAuth('bearer')
@Controller()
export class RbacProbeController {
  @Post('notifications')
  @Roles(UserRole.SYSTEM_ADMIN, UserRole.SECURITY_ADMIN)
  @ApiOperation({
    summary: 'RBAC probe: create notification (admin roles only)',
  })
  @ApiOkResponse({ description: 'Authorized' })
  createNotificationProbe(): { ok: true } {
    return { ok: true };
  }

  @Get('audit-logs')
  @Roles(UserRole.SECURITY_ADMIN, UserRole.SYSTEM_ADMIN)
  @ApiOperation({ summary: 'RBAC probe: list audit logs (admin roles only)' })
  @ApiOkResponse({ description: 'Authorized' })
  listAuditLogsProbe(): { ok: true } {
    return { ok: true };
  }
}
