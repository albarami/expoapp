import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/access_reference_catalog.dart';
import '../data/access_requests_repository.dart';
import '../domain/access_request_models.dart';

final accessRequestsRepositoryProvider =
    Provider<AccessRequestsRepository>((ref) {
  return ApiAccessRequestsRepository(ref.watch(apiClientProvider));
});

final accessReferenceDataRepositoryProvider =
    Provider<AccessReferenceDataRepository>((ref) {
  return ApiAccessReferenceDataRepository(ref.watch(apiClientProvider));
});

/// Active list query. Employees are scoped by the API to their own requests.
final accessRequestListQueryProvider =
    StateProvider.autoDispose<AccessRequestListQuery>((ref) {
  return const AccessRequestListQuery();
});

/// Client-side status tab (All / Pending / Completed / Rejected).
final accessRequestListTabProvider =
    StateProvider.autoDispose<AccessRequestListTab>((ref) {
  return AccessRequestListTab.all;
});

final accessRequestsListProvider =
    FutureProvider.autoDispose<AccessRequestListResult>((ref) {
  ref.watch(sessionControllerProvider.select((s) => s.user?.id));
  final query = ref.watch(accessRequestListQueryProvider);
  return ref.watch(accessRequestsRepositoryProvider).list(query);
});

final accessRequestDetailProvider =
    FutureProvider.autoDispose.family<AccessRequestDetail, String>((ref, id) {
  ref.watch(sessionControllerProvider.select((s) => s.user?.id));
  return ref.watch(accessRequestsRepositoryProvider).getById(id);
});

final accessReferenceCatalogProvider =
    FutureProvider.autoDispose<AccessReferenceCatalog>((ref) {
  return ref.watch(accessReferenceDataRepositoryProvider).fetchCatalog();
});
