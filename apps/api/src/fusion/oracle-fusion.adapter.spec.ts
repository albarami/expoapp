import { ConfigService } from '@nestjs/config';
import { ErrorCode } from '../common/constants/error-codes';
import { BusinessException } from '../common/exceptions/business.exception';
import { OracleFusionAdapter } from './oracle-fusion.adapter';

describe('OracleFusionAdapter (FUS-02)', () => {
  it('throws FUSION_CONFIGURATION_MISSING when env is incomplete', async () => {
    const configService = {
      get: jest.fn().mockReturnValue(''),
    } as unknown as ConfigService;

    const adapter = new OracleFusionAdapter(configService);

    await expect(adapter.getEmployeeProfile('ext-e1001')).rejects.toMatchObject(
      {
        code: ErrorCode.FUSION_CONFIGURATION_MISSING,
      },
    );

    try {
      await adapter.getEmployeeProfile('ext-e1001');
    } catch (error) {
      expect(error).toBeInstanceOf(BusinessException);
      expect((error as BusinessException).getStatus()).toBe(503);
      expect((error as BusinessException).message).toContain('FUSION_BASE_URL');
    }
  });

  it('throws not-implemented after config is present', async () => {
    const values: Record<string, string> = {
      FUSION_BASE_URL: 'https://fusion.example.com',
      FUSION_CLIENT_ID: 'client',
      FUSION_CLIENT_SECRET: 'secret',
      FUSION_TOKEN_URL: 'https://fusion.example.com/oauth/token',
      FUSION_SCOPE: 'urn:opc:resource:consumer::all',
    };
    const configService = {
      get: jest.fn((key: string) => values[key]),
    } as unknown as ConfigService;

    const adapter = new OracleFusionAdapter(configService);

    await expect(adapter.getEmployeeProfile('ext-e1001')).rejects.toMatchObject(
      {
        code: ErrorCode.FUSION_PROVISIONING_FAILED,
      },
    );
  });
});
