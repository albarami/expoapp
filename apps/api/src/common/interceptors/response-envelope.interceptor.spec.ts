import { CallHandler, ExecutionContext } from '@nestjs/common';
import { of, firstValueFrom } from 'rxjs';
import { ApiSuccessResponse } from '../types/api-response';
import { ResponseEnvelopeInterceptor } from './response-envelope.interceptor';

describe('ResponseEnvelopeInterceptor', () => {
  const interceptor = new ResponseEnvelopeInterceptor();

  function createContext(): ExecutionContext {
    return {
      switchToHttp: () => ({
        getRequest: () => ({
          traceId: 'trace-abc',
          header: () => undefined,
        }),
        getResponse: () => ({
          setHeader: jest.fn(),
        }),
      }),
    } as unknown as ExecutionContext;
  }

  it('wraps plain payloads in data/meta envelope', async () => {
    const handler: CallHandler = {
      handle: () => of({ status: 'ok' }),
    };

    const result = (await firstValueFrom(
      interceptor.intercept(createContext(), handler),
    )) as ApiSuccessResponse<{ status: string }>;

    expect(result.data).toEqual({ status: 'ok' });
    expect(result.meta.traceId).toBe('trace-abc');
    expect(result.meta.timestamp).toEqual(expect.any(String));
  });

  it('does not double-wrap already enveloped payloads', async () => {
    const handler: CallHandler = {
      handle: () =>
        of({
          data: { status: 'ok' },
          meta: { traceId: 'old', timestamp: 'old' },
        }),
    };

    const result = (await firstValueFrom(
      interceptor.intercept(createContext(), handler),
    )) as ApiSuccessResponse<{ status: string }>;

    expect(result.data).toEqual({ status: 'ok' });
    expect(result.meta.traceId).toBe('trace-abc');
    expect(result.meta.timestamp).toEqual(expect.any(String));
  });
});
