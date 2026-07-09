/// Typed API error mapped from the NestJS error envelope.
class ApiError implements Exception {
  const ApiError({
    required this.code,
    required this.message,
    this.details,
    this.statusCode,
    this.traceId,
  });

  final String code;
  final String message;
  final Object? details;
  final int? statusCode;
  final String? traceId;

  bool get isUnauthorized => statusCode == 401 || code == 'UNAUTHORIZED';
  bool get isForbidden => statusCode == 403 || code == 'FORBIDDEN';
  bool get isNetwork => code == 'NETWORK_ERROR';
  bool get isValidation => code == 'VALIDATION_ERROR';

  factory ApiError.network([String? message]) {
    return ApiError(
      code: 'NETWORK_ERROR',
      message: message ?? 'Network error',
    );
  }

  factory ApiError.unknown([String? message]) {
    return ApiError(
      code: 'UNKNOWN',
      message: message ?? 'Unexpected error',
    );
  }

  factory ApiError.fromJson(Map<String, dynamic> json, {int? statusCode}) {
    final error = json['error'];
    final meta = json['meta'];
    if (error is Map<String, dynamic>) {
      return ApiError(
        code: error['code']?.toString() ?? 'UNKNOWN',
        message: error['message']?.toString() ?? 'Unexpected error',
        details: error['details'],
        statusCode: statusCode,
        traceId: meta is Map<String, dynamic>
            ? meta['traceId']?.toString()
            : null,
      );
    }
    return ApiError(
      code: 'UNKNOWN',
      message: json['message']?.toString() ?? 'Unexpected error',
      statusCode: statusCode,
    );
  }

  @override
  String toString() => 'ApiError($code, $message, status=$statusCode)';
}
