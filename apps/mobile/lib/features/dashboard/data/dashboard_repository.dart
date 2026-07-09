import '../../../core/api/api_client.dart';
import '../../../core/api/api_error.dart';
import '../domain/dashboard_summary.dart';

/// Dashboard API surface.
abstract class DashboardRepository {
  Future<DashboardSummary> fetchSummary();
}

class ApiDashboardRepository implements DashboardRepository {
  ApiDashboardRepository(this._api);

  final ApiClient _api;

  @override
  Future<DashboardSummary> fetchSummary() async {
    final response = await _api.get<Map<String, dynamic>>('/dashboard/summary');
    final data = response.data;
    if (data == null) {
      throw ApiError.unknown('Empty /dashboard/summary response');
    }
    return DashboardSummary.fromJson(data);
  }
}
