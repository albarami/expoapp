import '../../../core/api/api_client.dart';
import '../../../core/api/api_envelope.dart';
import '../../../core/api/api_error.dart';
import '../domain/access_request_models.dart';

/// Access-requests API surface.
abstract class AccessRequestsRepository {
  Future<AccessRequestListResult> list(AccessRequestListQuery query);

  Future<AccessRequestDetail> getById(String id);

  Future<SubmitAccessRequestResult> create(CreateAccessRequestPayload payload);

  Future<CancelAccessRequestResult> cancel(String id);
}

class ApiAccessRequestsRepository implements AccessRequestsRepository {
  ApiAccessRequestsRepository(this._api);

  final ApiClient _api;

  @override
  Future<AccessRequestListResult> list(AccessRequestListQuery query) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/access-requests',
      queryParameters: query.toQueryParameters(),
    );
    final body = response.data;
    if (body == null) {
      throw ApiError.unknown('Empty /access-requests response');
    }

    final items = unwrapDataList(body)
        .whereType<Map<String, dynamic>>()
        .map(AccessRequestListItem.fromJson)
        .toList(growable: false);

    final pagination = unwrapPagination(body);
    return AccessRequestListResult(
      items: items,
      page: (pagination?['page'] as num?)?.toInt() ?? query.page,
      pageSize: (pagination?['pageSize'] as num?)?.toInt() ?? query.pageSize,
      total: (pagination?['total'] as num?)?.toInt() ?? items.length,
    );
  }

  @override
  Future<AccessRequestDetail> getById(String id) async {
    final response =
        await _api.get<Map<String, dynamic>>('/access-requests/$id');
    return AccessRequestDetail.fromJson(unwrapDataMap(response.data));
  }

  @override
  Future<SubmitAccessRequestResult> create(
    CreateAccessRequestPayload payload,
  ) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/access-requests',
      data: payload.toJson(),
    );
    return SubmitAccessRequestResult.fromJson(unwrapDataMap(response.data));
  }

  @override
  Future<CancelAccessRequestResult> cancel(String id) async {
    final response = await _api.patch<Map<String, dynamic>>(
      '/access-requests/$id/cancel',
    );
    return CancelAccessRequestResult.fromJson(unwrapDataMap(response.data));
  }
}
