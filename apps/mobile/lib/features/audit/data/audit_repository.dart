import '../../../core/api/api_client.dart';
import '../../../core/api/api_envelope.dart';
import '../../../core/api/api_error.dart';
import '../domain/audit_models.dart';

/// Audit logs API surface (admin-only).
abstract class AuditRepository {
  Future<AuditListResult> list(AuditListQuery query);
}

class ApiAuditRepository implements AuditRepository {
  ApiAuditRepository(this._api);

  final ApiClient _api;

  @override
  Future<AuditListResult> list(AuditListQuery query) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/audit-logs',
      queryParameters: query.toQueryParameters(),
    );
    final body = response.data;
    if (body == null) {
      throw ApiError.unknown('Empty /audit-logs response');
    }

    final items = unwrapDataList(body)
        .whereType<Map<String, dynamic>>()
        .map(AuditLogEntry.fromJson)
        .toList(growable: false);

    final pagination = unwrapPagination(body);
    final page = (pagination?['page'] as num?)?.toInt() ?? query.page;
    final pageSize =
        (pagination?['pageSize'] as num?)?.toInt() ?? query.pageSize;
    final total = (pagination?['total'] as num?)?.toInt() ?? items.length;
    final totalPages = (pagination?['totalPages'] as num?)?.toInt() ??
        (total == 0 ? 0 : (total / pageSize).ceil());

    return AuditListResult(
      items: items,
      page: page,
      pageSize: pageSize,
      total: total,
      totalPages: totalPages,
    );
  }
}
