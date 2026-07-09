import { Controller, Get, Query } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiForbiddenResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { Roles } from '../auth/decorators/roles.decorator';
import { AuditService } from './audit.service';
import { ListAuditLogsQueryDto } from './dto/list-audit-logs-query.dto';

@ApiTags('audit-logs')
@ApiBearerAuth('bearer')
@Controller('audit-logs')
export class AuditController {
  constructor(private readonly auditService: AuditService) {}

  @Get()
  @Roles(UserRole.SECURITY_ADMIN, UserRole.SYSTEM_ADMIN)
  @ApiOperation({ summary: 'List audit logs with filters (admin only)' })
  @ApiOkResponse({ description: 'Paginated audit log list' })
  @ApiUnauthorizedResponse({ description: 'Missing or invalid bearer token' })
  @ApiForbiddenResponse({ description: 'Caller role is not allowed' })
  async list(@Query() query: ListAuditLogsQueryDto) {
    const result = await this.auditService.list(query);
    const totalPages =
      result.total === 0 ? 0 : Math.ceil(result.total / result.pageSize);

    return {
      data: result.items,
      pagination: {
        page: result.page,
        pageSize: result.pageSize,
        total: result.total,
        totalPages,
      },
    };
  }
}
