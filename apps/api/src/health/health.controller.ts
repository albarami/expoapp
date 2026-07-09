import { Controller, Get } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { HealthService } from './health.service';
import { HealthCheckResult } from './health.types';

@ApiTags('health')
@Controller('health')
export class HealthController {
  constructor(private readonly healthService: HealthService) {}

  @Get()
  @ApiOperation({ summary: 'API, database, and Redis health check' })
  @ApiOkResponse({
    description:
      'Service health status wrapped in the standard response envelope',
  })
  getHealth(): Promise<HealthCheckResult> {
    return this.healthService.check();
  }
}
