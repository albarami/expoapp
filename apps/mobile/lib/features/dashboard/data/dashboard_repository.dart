import '../../../core/api/api_client.dart';
import '../../../core/api/api_envelope.dart';
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
    return DashboardSummary.fromJson(unwrapDataMap(response.data));
  }
}
