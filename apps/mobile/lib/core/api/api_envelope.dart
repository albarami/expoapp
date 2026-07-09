import 'api_error.dart';

/// Unwraps NestJS `{ data, meta, pagination? }` success envelopes.
Map<String, dynamic> unwrapDataMap(Map<String, dynamic>? body) {
  if (body == null) {
    throw ApiError.unknown('Empty API response');
  }
  final data = body['data'];
  if (data is Map<String, dynamic>) {
    return data;
  }
  // Some endpoints may already be unwrapped in tests/fakes.
  if (body.containsKey('id') ||
      body.containsKey('accessToken') ||
      body.containsKey('role') ||
      body.containsKey('unreadNotifications')) {
    return body;
  }
  throw ApiError.unknown('API response missing data object');
}

/// Returns the `data` field when it is a list, otherwise an empty list.
List<dynamic> unwrapDataList(Map<String, dynamic>? body) {
  if (body == null) {
    throw ApiError.unknown('Empty API response');
  }
  final data = body['data'];
  if (data is List) {
    return data;
  }
  return const [];
}

/// Pagination block from list endpoints (`pagination` sibling of `data`).
Map<String, dynamic>? unwrapPagination(Map<String, dynamic>? body) {
  if (body == null) return null;
  final pagination = body['pagination'];
  if (pagination is Map<String, dynamic>) {
    return pagination;
  }
  return null;
}
