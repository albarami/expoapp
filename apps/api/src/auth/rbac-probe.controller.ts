import { Controller, Get } from '@nestjs/common';
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
 * POST /notifications was replaced by NotificationsModule (T-API-06).
 * GET /audit-logs remains until the Audit list module (T-API-10).
 */
@ApiTags('rbac-probe')
@ApiBearerAuth('bearer')
@Controller()
export class RbacProbeController {
  @Get('audit-logs')
  @Roles(UserRole.SECURITY_ADMIN, UserRole.SYSTEM_ADMIN)
  @ApiOperation({ summary: 'RBAC probe: list audit logs (admin roles only)' })
  @ApiOkResponse({ description: 'Authorized' })
  listAuditLogsProbe(): { ok: true } {
    return { ok: true };
  }
}
