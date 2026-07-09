import { Controller, Get } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { ReferenceDataService } from './reference-data.service';
import { ReferenceDataResponse } from './reference-data.types';

@ApiTags('reference-data')
@ApiBearerAuth('bearer')
@Controller('reference-data')
export class ReferenceDataController {
  constructor(private readonly referenceDataService: ReferenceDataService) {}

  @Get()
  @ApiOperation({
    summary: 'Catalog of departments, systems, security roles, and enum values',
  })
  @ApiOkResponse({ description: 'Reference data payload' })
  @ApiUnauthorizedResponse({ description: 'Missing or invalid bearer token' })
  getReferenceData(): Promise<ReferenceDataResponse> {
    return this.referenceDataService.getReferenceData();
  }
}
