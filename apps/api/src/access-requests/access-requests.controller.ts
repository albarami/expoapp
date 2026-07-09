import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
  Req,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiCreatedResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import type { Request } from 'express';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import type { AuthUser } from '../auth/types/auth-user';
import { AccessRequestsService } from './access-requests.service';
import { CreateAccessRequestDto } from './dto/create-access-request.dto';
import { ListAccessRequestsQueryDto } from './dto/list-access-requests-query.dto';

@ApiTags('access-requests')
@ApiBearerAuth('bearer')
@Controller('access-requests')
export class AccessRequestsController {
  constructor(private readonly accessRequestsService: AccessRequestsService) {}

  @Get()
  @ApiOperation({ summary: 'List access requests (role-scoped)' })
  @ApiOkResponse({ description: 'Paginated access request list' })
  @ApiUnauthorizedResponse({ description: 'Missing or invalid bearer token' })
  async list(
    @CurrentUser() user: AuthUser,
    @Query() query: ListAccessRequestsQueryDto,
  ) {
    const result = await this.accessRequestsService.listRequests(user, query);
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

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({ summary: 'Submit an access request' })
  @ApiCreatedResponse({ description: 'Access request submitted' })
  create(
    @CurrentUser() user: AuthUser,
    @Body() dto: CreateAccessRequestDto,
    @Req() request: Request,
  ) {
    return this.accessRequestsService.createRequest(user, dto, request);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get access request detail with timeline' })
  @ApiOkResponse({ description: 'Access request detail' })
  getOne(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.accessRequestsService.getRequest(user, id);
  }

  @Patch(':id/cancel')
  @ApiOperation({ summary: 'Cancel an access request (requester only)' })
  @ApiOkResponse({ description: 'Access request cancelled' })
  cancel(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Req() request: Request,
  ) {
    return this.accessRequestsService.cancelRequest(user, id, request);
  }
}
