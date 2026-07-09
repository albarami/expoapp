import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/audit_repository.dart';
import '../domain/audit_models.dart';

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  return ApiAuditRepository(ref.watch(apiClientProvider));
});

final auditListQueryProvider =
    StateProvider.autoDispose<AuditListQuery>((ref) {
  return const AuditListQuery();
});

final auditLogsListProvider =
    FutureProvider.autoDispose<AuditListResult>((ref) {
  ref.watch(sessionControllerProvider.select((s) => s.user?.id));
  final query = ref.watch(auditListQueryProvider);
  return ref.watch(auditRepositoryProvider).list(query);
});
