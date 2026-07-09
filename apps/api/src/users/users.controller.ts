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
import { ListUsersQueryDto } from './dto/list-users-query.dto';
import { UsersService } from './users.service';

@ApiTags('users')
@ApiBearerAuth('bearer')
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  @Roles(UserRole.SYSTEM_ADMIN, UserRole.SECURITY_ADMIN)
  @ApiOperation({
    summary: 'Admin user lookup for the USERS notification audience',
  })
  @ApiOkResponse({ description: 'Paginated active user list' })
  @ApiUnauthorizedResponse({ description: 'Missing or invalid bearer token' })
  @ApiForbiddenResponse({ description: 'Caller role is not allowed' })
  async list(@Query() query: ListUsersQueryDto) {
    const result = await this.usersService.list(query);
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
