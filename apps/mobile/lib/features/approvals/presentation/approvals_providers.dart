import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../access_requests/domain/access_request_models.dart';
import '../../access_requests/presentation/access_requests_providers.dart';
import '../data/approvals_repository.dart';
import '../domain/approval_models.dart';

final approvalsRepositoryProvider = Provider<ApprovalsRepository>((ref) {
  return ApiApprovalsRepository(ref.watch(apiClientProvider));
});

/// Queue tab: Pending (API status=PENDING) or Completed (no status; client filter).
final approvalQueueTabProvider =
    StateProvider.autoDispose<ApprovalQueueTab>((ref) {
  return ApprovalQueueTab.pending;
});

final approvalListQueryProvider =
    StateProvider.autoDispose<ApprovalListQuery>((ref) {
  final tab = ref.watch(approvalQueueTabProvider);
  switch (tab) {
    case ApprovalQueueTab.pending:
      return const ApprovalListQuery(status: 'PENDING');
    case ApprovalQueueTab.completed:
      // Fetch a broader page; filter to decided tasks client-side.
      return const ApprovalListQuery(pageSize: 50);
  }
});

final approvalsListProvider =
    FutureProvider.autoDispose<ApprovalListResult>((ref) {
  ref.watch(sessionControllerProvider.select((s) => s.user?.id));
  final query = ref.watch(approvalListQueryProvider);
  return ref.watch(approvalsRepositoryProvider).list(query);
});

/// Resolve a single task from the current list (or a dedicated fetch via list).
final approvalTaskProvider =
    FutureProvider.autoDispose.family<ApprovalTask, String>((ref, taskId) async {
  ref.watch(sessionControllerProvider.select((s) => s.user?.id));
  final list = await ref.watch(approvalsListProvider.future);
  final match = list.items.where((t) => t.id == taskId).toList();
  if (match.isNotEmpty) return match.first;

  // Task may be on another page / other status tab — search both queues.
  final repo = ref.watch(approvalsRepositoryProvider);
  final pending = await repo.list(
    const ApprovalListQuery(status: 'PENDING', pageSize: 100),
  );
  final fromPending = pending.items.where((t) => t.id == taskId);
  if (fromPending.isNotEmpty) return fromPending.first;

  final all = await repo.list(const ApprovalListQuery(pageSize: 100));
  final fromAll = all.items.where((t) => t.id == taskId);
  if (fromAll.isNotEmpty) return fromAll.first;

  throw StateError('Approval task not found: $taskId');
});

/// Access-request detail for the approval decision screen (timeline, etc.).
final approvalRequestDetailProvider = FutureProvider.autoDispose
    .family<AccessRequestDetail, String>((ref, requestId) {
  return ref.watch(accessRequestDetailProvider(requestId).future);
});
