import {
  CallHandler,
  ExecutionContext,
  Injectable,
  NestInterceptor,
} from '@nestjs/common';
import { Request } from 'express';
import { Observable, map } from 'rxjs';
import { TRACE_ID_HEADER, TRACE_ID_REQUEST_KEY } from '../constants/trace';
import { ApiSuccessResponse } from '../types/api-response';
import { createMeta } from '../utils/create-meta';
import { generateTraceId } from '../utils/generate-trace-id';

function isAlreadyEnveloped(payload: unknown): boolean {
  if (
    payload === null ||
    typeof payload !== 'object' ||
    Array.isArray(payload)
  ) {
    return false;
  }
  return 'data' in payload || 'error' in payload;
}

@Injectable()
export class ResponseEnvelopeInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const http = context.switchToHttp();
    const request = http.getRequest<
      Request & { [TRACE_ID_REQUEST_KEY]?: string }
    >();
    const response = http.getResponse<{
      setHeader: (name: string, value: string) => void;
    }>();

    const traceId =
      request[TRACE_ID_REQUEST_KEY] ??
      request.header(TRACE_ID_HEADER) ??
      generateTraceId();

    response.setHeader(TRACE_ID_HEADER, traceId);

    return next.handle().pipe(
      map((payload: unknown) => {
        if (isAlreadyEnveloped(payload)) {
          const body = payload as Record<string, unknown>;
          const existingMeta = body.meta as Record<string, unknown> | undefined;
          return {
            ...body,
            meta: {
              ...createMeta(traceId),
              ...(existingMeta ?? {}),
              traceId,
            },
          };
        }

        const enveloped: ApiSuccessResponse<unknown> = {
          data: payload,
          meta: createMeta(traceId),
        };
        return enveloped;
      }),
    );
  }
}
