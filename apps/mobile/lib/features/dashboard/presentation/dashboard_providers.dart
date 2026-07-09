import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/dashboard_repository.dart';
import '../domain/dashboard_summary.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return ApiDashboardRepository(ref.watch(apiClientProvider));
});

/// Role-aware dashboard summary. Invalidated on pull-to-refresh / retry.
final dashboardSummaryProvider =
    FutureProvider.autoDispose<DashboardSummary>((ref) {
  // Re-fetch when the authenticated user changes (role switch / re-login).
  ref.watch(sessionControllerProvider.select((s) => s.user?.id));
  return ref.watch(dashboardRepositoryProvider).fetchSummary();
});
