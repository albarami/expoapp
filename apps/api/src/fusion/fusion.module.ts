import { Global, Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { FUSION_ADAPTER } from './fusion.constants';
import { IntegrationOutboxService } from './integration-outbox.service';
import { MockFusionAdapter } from './mock-fusion.adapter';
import { OracleFusionAdapter } from './oracle-fusion.adapter';

@Global()
@Module({
  providers: [
    MockFusionAdapter,
    OracleFusionAdapter,
    IntegrationOutboxService,
    {
      provide: FUSION_ADAPTER,
      inject: [ConfigService, MockFusionAdapter, OracleFusionAdapter],
      useFactory: (
        configService: ConfigService,
        mockAdapter: MockFusionAdapter,
        oracleAdapter: OracleFusionAdapter,
      ) => {
        const mode = configService.get<string>('FUSION_MODE', 'mock');
        return mode === 'fusion' ? oracleAdapter : mockAdapter;
      },
    },
  ],
  exports: [FUSION_ADAPTER, IntegrationOutboxService],
})
export class FusionModule {}
