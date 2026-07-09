import { Controller, Get } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import type { AuthUser } from '../auth/types/auth-user';
import { DashboardService } from './dashboard.service';
import { DashboardSummaryResponse } from './dashboard.types';

@ApiTags('dashboard')
@ApiBearerAuth('bearer')
@Controller('dashboard')
export class DashboardController {
  constructor(private readonly dashboardService: DashboardService) {}

  @Get('summary')
  @ApiOperation({ summary: 'Role-aware dashboard summary for current user' })
  @ApiOkResponse({ description: 'Dashboard summary payload' })
  @ApiUnauthorizedResponse({ description: 'Missing or invalid bearer token' })
  getSummary(@CurrentUser() user: AuthUser): Promise<DashboardSummaryResponse> {
    return this.dashboardService.getSummary(user);
  }
}
