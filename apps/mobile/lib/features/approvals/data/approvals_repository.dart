import '../../../core/api/api_client.dart';
import '../../../core/api/api_envelope.dart';
import '../../../core/api/api_error.dart';
import '../domain/approval_models.dart';

/// Approvals API surface.
abstract class ApprovalsRepository {
  Future<ApprovalListResult> list(ApprovalListQuery query);

  Future<DecideApprovalResult> decide(
    String taskId,
    DecideApprovalPayload payload,
  );
}

class ApiApprovalsRepository implements ApprovalsRepository {
  ApiApprovalsRepository(this._api);

  final ApiClient _api;

  @override
  Future<ApprovalListResult> list(ApprovalListQuery query) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/approvals',
      queryParameters: query.toQueryParameters(),
    );
    final body = response.data;
    if (body == null) {
      throw ApiError.unknown('Empty /approvals response');
    }

    final items = unwrapDataList(body)
        .whereType<Map<String, dynamic>>()
        .map(ApprovalTask.fromJson)
        .toList(growable: false);

    final pagination = unwrapPagination(body);
    return ApprovalListResult(
      items: items,
      page: (pagination?['page'] as num?)?.toInt() ?? query.page,
      pageSize: (pagination?['pageSize'] as num?)?.toInt() ?? query.pageSize,
      total: (pagination?['total'] as num?)?.toInt() ?? items.length,
    );
  }

  @override
  Future<DecideApprovalResult> decide(
    String taskId,
    DecideApprovalPayload payload,
  ) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/approvals/$taskId/decision',
      data: payload.toJson(),
    );
    return DecideApprovalResult.fromJson(unwrapDataMap(response.data));
  }
}
