import { Body, Controller, HttpCode, HttpStatus, Post } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiCreatedResponse,
  ApiOperation,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import type { AuthUser } from '../auth/types/auth-user';
import { DeviceTokensService } from './device-tokens.service';
import { RegisterDeviceTokenDto } from './dto/register-device-token.dto';

@ApiTags('device-tokens')
@ApiBearerAuth('bearer')
@Controller('device-tokens')
export class DeviceTokensController {
  constructor(private readonly deviceTokensService: DeviceTokensService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: 'Register or refresh a device push token for the current user',
  })
  @ApiCreatedResponse({ description: 'Device token stored' })
  @ApiUnauthorizedResponse({ description: 'Missing or invalid bearer token' })
  register(@CurrentUser() user: AuthUser, @Body() dto: RegisterDeviceTokenDto) {
    return this.deviceTokensService.register(user, dto);
  }
}
