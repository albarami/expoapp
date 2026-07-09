import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/notifications_repository.dart';
import '../data/reference_data_repository.dart';
import '../data/users_repository.dart';
import '../domain/notification_models.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return ApiNotificationsRepository(ref.watch(apiClientProvider));
});

final referenceDataRepositoryProvider = Provider<ReferenceDataRepository>((ref) {
  return ApiReferenceDataRepository(ref.watch(apiClientProvider));
});

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return ApiUsersRepository(ref.watch(apiClientProvider));
});

/// Search text for the USERS audience picker.
final audienceUserSearchProvider = StateProvider.autoDispose<String>((ref) {
  return '';
});

/// Active users matching the picker search (doc 19: simple list from /users).
final audienceUsersProvider =
    FutureProvider.autoDispose<UserListResult>((ref) {
  final query = ref.watch(audienceUserSearchProvider);
  return ref.watch(usersRepositoryProvider).search(query: query);
});

/// Active list filters (search + chips). Page resets to 1 when filters change.
final notificationListQueryProvider =
    StateProvider.autoDispose<NotificationListQuery>((ref) {
  return const NotificationListQuery();
});

final notificationsListProvider =
    FutureProvider.autoDispose<NotificationListResult>((ref) {
  ref.watch(sessionControllerProvider.select((s) => s.user?.id));
  final query = ref.watch(notificationListQueryProvider);
  return ref.watch(notificationsRepositoryProvider).list(query);
});

final notificationDetailProvider =
    FutureProvider.autoDispose.family<AppNotification, String>((ref, id) {
  ref.watch(sessionControllerProvider.select((s) => s.user?.id));
  return ref.watch(notificationsRepositoryProvider).getById(id);
});

final notificationStatsProvider =
    FutureProvider.autoDispose.family<NotificationStats, String>((ref, id) {
  return ref.watch(notificationsRepositoryProvider).getStats(id);
});

final referenceCatalogProvider =
    FutureProvider.autoDispose<ReferenceCatalog>((ref) {
  return ref.watch(referenceDataRepositoryProvider).fetchCatalog();
});
