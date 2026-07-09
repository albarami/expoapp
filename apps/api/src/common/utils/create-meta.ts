import { ApiMeta } from '../types/api-response';

export function createMeta(traceId: string): ApiMeta {
  return {
    traceId,
    timestamp: new Date().toISOString(),
  };
}
