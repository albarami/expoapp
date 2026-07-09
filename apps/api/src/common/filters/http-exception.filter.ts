import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Request, Response } from 'express';
import { ErrorCode } from '../constants/error-codes';
import { TRACE_ID_HEADER, TRACE_ID_REQUEST_KEY } from '../constants/trace';
import { BusinessException } from '../exceptions/business.exception';
import { ApiErrorDetail, ApiErrorResponse } from '../types/api-response';
import { createMeta } from '../utils/create-meta';
import { generateTraceId } from '../utils/generate-trace-id';

@Catch()
export class GlobalExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(GlobalExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<
      Request & { [TRACE_ID_REQUEST_KEY]?: string }
    >();

    const traceId =
      request[TRACE_ID_REQUEST_KEY] ??
      request.header(TRACE_ID_HEADER) ??
      generateTraceId();

    response.setHeader(TRACE_ID_HEADER, traceId);

    const { status, code, message, details } = this.mapException(exception);

    if (status >= 500) {
      this.logger.error(
        {
          traceId,
          path: request.url,
          method: request.method,
          code,
          message,
        },
        exception instanceof Error ? exception.stack : undefined,
      );
    } else {
      this.logger.warn({
        traceId,
        path: request.url,
        method: request.method,
        code,
        message,
      });
    }

    const body: ApiErrorResponse = {
      error: {
        code,
        message,
        ...(details && details.length > 0 ? { details } : {}),
      },
      meta: createMeta(traceId),
    };

    response.status(status).json(body);
  }

  private mapException(exception: unknown): {
    status: number;
    code: string;
    message: string;
    details?: ApiErrorDetail[];
  } {
    if (exception instanceof BusinessException) {
      const payload = exception.getResponse() as {
        code?: string;
        message?: string;
        details?: ApiErrorDetail[];
      };
      return {
        status: exception.getStatus(),
        code: payload.code ?? exception.code,
        message: payload.message ?? exception.message,
        details: payload.details ?? exception.details,
      };
    }

    if (exception instanceof HttpException) {
      const status = exception.getStatus();
      const exceptionResponse = exception.getResponse();

      if (typeof exceptionResponse === 'string') {
        return {
          status,
          code: this.codeForStatus(status),
          message: exceptionResponse,
        };
      }

      const payload = exceptionResponse as Record<string, unknown>;

      if (Array.isArray(payload.message)) {
        const details = this.mapValidationDetails(payload.message);
        return {
          status: HttpStatus.BAD_REQUEST,
          code: ErrorCode.VALIDATION_ERROR,
          message: 'Request validation failed.',
          details,
        };
      }

      if (
        typeof payload.code === 'string' &&
        typeof payload.message === 'string'
      ) {
        return {
          status,
          code: payload.code,
          message: payload.message,
          details: Array.isArray(payload.details)
            ? (payload.details as ApiErrorDetail[])
            : undefined,
        };
      }

      const message =
        typeof payload.message === 'string'
          ? payload.message
          : exception.message;

      return {
        status,
        code: this.codeForStatus(status),
        message,
      };
    }

    return {
      status: HttpStatus.INTERNAL_SERVER_ERROR,
      code: ErrorCode.INTERNAL_ERROR,
      message: 'An unexpected error occurred.',
    };
  }

  private mapValidationDetails(messages: unknown[]): ApiErrorDetail[] {
    return messages.map((entry) => {
      if (typeof entry === 'string') {
        const separatorIndex = entry.indexOf(' ');
        if (separatorIndex > 0) {
          return {
            field: entry.slice(0, separatorIndex),
            message: entry.slice(separatorIndex + 1),
          };
        }
        return { message: entry };
      }
      return { message: String(entry) };
    });
  }

  private codeForStatus(status: number): string {
    if (status === 400) {
      return ErrorCode.VALIDATION_ERROR;
    }
    if (status === 401) {
      return ErrorCode.UNAUTHORIZED;
    }
    if (status === 403) {
      return ErrorCode.FORBIDDEN;
    }
    if (status === 404) {
      return ErrorCode.NOT_FOUND;
    }
    return ErrorCode.INTERNAL_ERROR;
  }
}
