import { HttpException, HttpStatus } from '@nestjs/common';
import { ErrorCode } from '../constants/error-codes';
import { ApiErrorDetail } from '../types/api-response';

export class BusinessException extends HttpException {
  readonly code: ErrorCode | string;
  readonly details?: ApiErrorDetail[];

  constructor(params: {
    code: ErrorCode | string;
    message: string;
    status?: HttpStatus;
    details?: ApiErrorDetail[];
  }) {
    super(
      {
        code: params.code,
        message: params.message,
        details: params.details,
      },
      params.status ?? HttpStatus.BAD_REQUEST,
    );
    this.code = params.code;
    this.details = params.details;
  }
}
