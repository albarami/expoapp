import { ArgumentsHost, HttpException, HttpStatus } from '@nestjs/common';
import { ErrorCode } from '../constants/error-codes';
import { BusinessException } from '../exceptions/business.exception';
import { ApiErrorResponse } from '../types/api-response';
import { GlobalExceptionFilter } from './http-exception.filter';

describe('GlobalExceptionFilter', () => {
  const filter = new GlobalExceptionFilter();

  function createHost(): {
    host: ArgumentsHost;
    status: jest.Mock;
    json: jest.Mock;
    setHeader: jest.Mock;
  } {
    const json = jest.fn();
    const status = jest.fn().mockReturnValue({ json });
    const setHeader = jest.fn();

    const host = {
      switchToHttp: () => ({
        getResponse: () => ({ status, setHeader }),
        getRequest: () => ({
          url: '/api/v1/test',
          method: 'GET',
          header: () => undefined,
          traceId: 'trace-test-1',
        }),
      }),
    } as unknown as ArgumentsHost;

    return { host, status, json, setHeader };
  }

  it('maps BusinessException to error envelope', () => {
    const { host, status, json, setHeader } = createHost();

    filter.catch(
      new BusinessException({
        code: ErrorCode.MANAGER_NOT_FOUND,
        message: 'Manager is required.',
      }),
      host,
    );

    expect(setHeader).toHaveBeenCalledWith('x-trace-id', 'trace-test-1');
    expect(status).toHaveBeenCalledWith(HttpStatus.BAD_REQUEST);

    const body = firstJsonCall(json);
    expect(body.error).toEqual({
      code: ErrorCode.MANAGER_NOT_FOUND,
      message: 'Manager is required.',
    });
    expect(body.meta.traceId).toBe('trace-test-1');
    expect(body.meta.timestamp).toEqual(expect.any(String));
  });

  it('maps validation HttpException messages to VALIDATION_ERROR', () => {
    const { host, status, json } = createHost();

    filter.catch(
      new HttpException(
        {
          message: ['email must be an email', 'password should not be empty'],
          error: 'Bad Request',
          statusCode: 400,
        },
        HttpStatus.BAD_REQUEST,
      ),
      host,
    );

    expect(status).toHaveBeenCalledWith(HttpStatus.BAD_REQUEST);

    const body = firstJsonCall(json);
    expect(body.error.code).toBe(ErrorCode.VALIDATION_ERROR);
    expect(body.error.message).toBe('Request validation failed.');
    expect(body.error.details).toEqual(
      expect.arrayContaining([
        expect.objectContaining({ field: 'email' }),
        expect.objectContaining({ field: 'password' }),
      ]),
    );
  });

  it('maps unknown errors to INTERNAL_ERROR', () => {
    const { host, status, json } = createHost();

    filter.catch(new Error('boom'), host);

    expect(status).toHaveBeenCalledWith(HttpStatus.INTERNAL_SERVER_ERROR);

    const body = firstJsonCall(json);
    expect(body.error).toEqual({
      code: ErrorCode.INTERNAL_ERROR,
      message: 'An unexpected error occurred.',
    });
  });
});

function firstJsonCall(json: jest.Mock): ApiErrorResponse {
  const calls = json.mock.calls as unknown[][];
  const firstArg = calls[0]?.[0];
  return firstArg as ApiErrorResponse;
}
