import { OutboxStatus } from '@prisma/client';
import { OUTBOX_TYPE_ACCESS_PROVISIONING } from './fusion.constants';
import { IntegrationOutboxService } from './integration-outbox.service';

describe('IntegrationOutboxService', () => {
  it('enqueues ACCESS_PROVISIONING outbox rows as PENDING', async () => {
    const create = jest.fn().mockResolvedValue({ id: 'outbox-1' });
    const prisma = {
      integrationOutbox: { create, update: jest.fn() },
    };
    const service = new IntegrationOutboxService(prisma as never);

    const payload = {
      requestNumber: 'AR-2026-000001',
      requesterExternalRef: 'ext-e1001',
      systemCode: 'ORACLE_FUSION_ERP',
      roleCode: 'FUSION_AP_INQUIRY',
      justification: 'Need access',
      approvedByExternalRefs: ['ext-m2001'],
    };

    const result = await service.enqueueAccessProvisioning({ payload });

    expect(result).toEqual({ id: 'outbox-1' });
    expect(create).toHaveBeenCalledTimes(1);
    const [createArgs] = create.mock.calls as [
      [{ data: { type: string; status: OutboxStatus; payload: unknown } }],
    ];
    expect(createArgs[0].data.type).toBe(OUTBOX_TYPE_ACCESS_PROVISIONING);
    expect(createArgs[0].data.status).toBe(OutboxStatus.PENDING);
    expect(createArgs[0].data.payload).toEqual(payload);
  });
});
