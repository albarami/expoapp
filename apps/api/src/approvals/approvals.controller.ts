import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Post,
  Query,
  Req,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import type { Request } from 'express';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import type { AuthUser } from '../auth/types/auth-user';
import { ApprovalsService } from './approvals.service';
import { DecideApprovalDto } from './dto/decide-approval.dto';
import { ListApprovalsQueryDto } from './dto/list-approvals-query.dto';

@ApiTags('approvals')
@ApiBearerAuth('bearer')
@Controller('approvals')
export class ApprovalsController {
  constructor(private readonly approvalsService: ApprovalsService) {}

  @Get()
  @Roles(UserRole.MANAGER, UserRole.SECURITY_ADMIN, UserRole.SYSTEM_ADMIN)
  @ApiOperation({ summary: 'List assigned approval tasks' })
  @ApiOkResponse({ description: 'Paginated approval task list' })
  @ApiUnauthorizedResponse({ description: 'Missing or invalid bearer token' })
  async list(
    @CurrentUser() user: AuthUser,
    @Query() query: ListApprovalsQueryDto,
  ) {
    const result = await this.approvalsService.listApprovals(user, query);
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

  @Post(':taskId/decision')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Approve or reject an approval task' })
  @ApiOkResponse({ description: 'Approval decision applied' })
  decide(
    @CurrentUser() user: AuthUser,
    @Param('taskId', ParseUUIDPipe) taskId: string,
    @Body() dto: DecideApprovalDto,
    @Req() request: Request,
  ) {
    return this.approvalsService.decide(user, taskId, dto, request);
  }
}
