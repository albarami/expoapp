import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../auth/token_storage.dart';
import '../config/app_config.dart';
import 'api_error.dart';

typedef UnauthorizedHandler = Future<void> Function();

/// Dio-backed HTTP client with bearer auth and typed [ApiError] mapping.
class ApiClient {
  ApiClient({
    required AppConfig config,
    required this.tokenStorage,
    this.onUnauthorized,
    Dio? dio,
  })  : _config = config,
        _dio = dio ?? _createDio(config) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenStorage.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (kDebugMode && _config.isLocal) {
            debugPrint('→ ${options.method} ${options.uri}');
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final status = error.response?.statusCode;
          final path = error.requestOptions.path;
          // Invalid credentials on login are not a session expiry.
          final isLoginAttempt = path.endsWith('/auth/login');
          if (status == 401 && !isLoginAttempt) {
            await tokenStorage.clear();
            final callback = onUnauthorized;
            if (callback != null) {
              await callback();
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  static Dio _createDio(AppConfig config) {
    return Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  final AppConfig _config;
  final Dio _dio;
  final TokenStorage tokenStorage;

  /// Invoked after a 401 clears stored tokens (wired by session provider).
  UnauthorizedHandler? onUnauthorized;

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _guard(
      () => _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _guard(
      () => _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _guard(
      () => _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _guard(
      () => _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
    );
  }

  Future<Response<T>> _guard<T>(Future<Response<T>> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  /// Converts Dio failures into [ApiError] for UI / repositories.
  static ApiError mapDioException(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError) {
      return ApiError.network(error.message);
    }

    final response = error.response;
    final data = response?.data;
    if (data is Map<String, dynamic>) {
      return ApiError.fromJson(data, statusCode: response?.statusCode);
    }

    return ApiError(
      code: 'HTTP_ERROR',
      message: error.message ?? 'Request failed',
      statusCode: response?.statusCode,
    );
  }
}
