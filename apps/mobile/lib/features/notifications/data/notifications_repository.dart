import '../../../core/api/api_client.dart';
import '../../../core/api/api_envelope.dart';
import '../../../core/api/api_error.dart';
import '../domain/notification_models.dart';

/// Notifications API surface.
abstract class NotificationsRepository {
  Future<NotificationListResult> list(NotificationListQuery query);

  Future<AppNotification> getById(String id);

  Future<AppNotification> markAsRead(String id);

  Future<CreateNotificationResult> create(CreateNotificationRequest request);

  Future<NotificationStats> getStats(String id);
}

class ApiNotificationsRepository implements NotificationsRepository {
  ApiNotificationsRepository(this._api);

  final ApiClient _api;

  @override
  Future<NotificationListResult> list(NotificationListQuery query) async {
    final response = await _api.get<Map<String, dynamic>>(
      '/notifications',
      queryParameters: query.toQueryParameters(),
    );
    final body = response.data;
    if (body == null) {
      throw ApiError.unknown('Empty /notifications response');
    }

    final items = unwrapDataList(body)
        .whereType<Map<String, dynamic>>()
        .map(AppNotification.fromJson)
        .toList(growable: false);

    final pagination = unwrapPagination(body);
    return NotificationListResult(
      items: items,
      page: (pagination?['page'] as num?)?.toInt() ?? query.page,
      pageSize: (pagination?['pageSize'] as num?)?.toInt() ?? query.pageSize,
      total: (pagination?['total'] as num?)?.toInt() ?? items.length,
    );
  }

  @override
  Future<AppNotification> getById(String id) async {
    final response = await _api.get<Map<String, dynamic>>('/notifications/$id');
    return AppNotification.fromJson(unwrapDataMap(response.data));
  }

  @override
  Future<AppNotification> markAsRead(String id) async {
    final response =
        await _api.patch<Map<String, dynamic>>('/notifications/$id/read');
    return AppNotification.fromJson(unwrapDataMap(response.data));
  }

  @override
  Future<CreateNotificationResult> create(
    CreateNotificationRequest request,
  ) async {
    final response = await _api.post<Map<String, dynamic>>(
      '/notifications',
      data: request.toJson(),
    );
    return CreateNotificationResult.fromJson(unwrapDataMap(response.data));
  }

  @override
  Future<NotificationStats> getStats(String id) async {
    final response =
        await _api.get<Map<String, dynamic>>('/notifications/$id/stats');
    return NotificationStats.fromJson(unwrapDataMap(response.data));
  }
}
