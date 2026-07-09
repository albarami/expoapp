import { Injectable, NestMiddleware } from '@nestjs/common';
import { NextFunction, Request, Response } from 'express';
import { TRACE_ID_HEADER, TRACE_ID_REQUEST_KEY } from '../constants/trace';
import { generateTraceId } from '../utils/generate-trace-id';

@Injectable()
export class TraceIdMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction): void {
    const incoming = req.header(TRACE_ID_HEADER)?.trim();
    const traceId =
      incoming && incoming.length > 0 ? incoming : generateTraceId();

    (req as Request & { [TRACE_ID_REQUEST_KEY]?: string })[
      TRACE_ID_REQUEST_KEY
    ] = traceId;
    res.setHeader(TRACE_ID_HEADER, traceId);
    next();
  }
}
