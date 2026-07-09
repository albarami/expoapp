import { ConfigModule } from '@nestjs/config';
import { Test } from '@nestjs/testing';
import { PrismaModule } from '../prisma/prisma.module';
import { PrismaService } from '../prisma/prisma.service';
import { FusionAdapter } from './fusion-adapter.interface';
import { FUSION_ADAPTER } from './fusion.constants';
import { FusionModule } from './fusion.module';
import { MockFusionAdapter } from './mock-fusion.adapter';
import { OracleFusionAdapter } from './oracle-fusion.adapter';

describe('FusionModule provider wiring (FUS-03)', () => {
  const previousMode = process.env.FUSION_MODE;

  afterEach(() => {
    if (previousMode === undefined) {
      delete process.env.FUSION_MODE;
    } else {
      process.env.FUSION_MODE = previousMode;
    }
  });

  async function createModule(fusionMode: 'mock' | 'fusion') {
    process.env.FUSION_MODE = fusionMode;

    return Test.createTestingModule({
      imports: [
        ConfigModule.forRoot({
          isGlobal: true,
          ignoreEnvFile: true,
        }),
        PrismaModule,
        FusionModule,
      ],
    })
      .overrideProvider(PrismaService)
      .useValue({
        onModuleInit: jest.fn(),
        onModuleDestroy: jest.fn(),
        $connect: jest.fn(),
        $disconnect: jest.fn(),
      })
      .compile();
  }

  it('binds FUSION_ADAPTER token to MockFusionAdapter when FUSION_MODE=mock', async () => {
    const moduleRef = await createModule('mock');
    const adapter = moduleRef.get<FusionAdapter>(FUSION_ADAPTER);

    expect(adapter).toBeInstanceOf(MockFusionAdapter);
    expect(adapter).not.toBeInstanceOf(OracleFusionAdapter);

    await moduleRef.close();
  });

  it('binds FUSION_ADAPTER token to OracleFusionAdapter when FUSION_MODE=fusion', async () => {
    const moduleRef = await createModule('fusion');
    const adapter = moduleRef.get<FusionAdapter>(FUSION_ADAPTER);

    expect(adapter).toBeInstanceOf(OracleFusionAdapter);
    expect(adapter).not.toBeInstanceOf(MockFusionAdapter);

    await moduleRef.close();
  });
});
