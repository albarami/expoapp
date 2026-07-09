import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme_tokens.dart';
import '../../../../core/api/api_error.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/approval_models.dart';
import '../approvals_providers.dart';
import '../widgets/approval_task_card.dart';

/// Approval queue: Pending / Completed toggle, cards, pull-to-refresh.
class ApprovalsListScreen extends ConsumerWidget {
  const ApprovalsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final listAsync = ref.watch(approvalsListProvider);
    final tab = ref.watch(approvalQueueTabProvider);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return ExpoAppScaffold(
      title: l10n.approvals,
      padding: EdgeInsets.zero,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: SegmentedButton<ApprovalQueueTab>(
              segments: [
                ButtonSegment(
                  value: ApprovalQueueTab.pending,
                  label: Text(l10n.filterPending),
                  icon: const Icon(Icons.pending_actions_outlined),
                ),
                ButtonSegment(
                  value: ApprovalQueueTab.completed,
                  label: Text(l10n.filterCompleted),
                  icon: const Icon(Icons.task_alt_outlined),
                ),
              ],
              selected: {tab},
              onSelectionChanged: (next) {
                if (next.isEmpty) return;
                ref.read(approvalQueueTabProvider.notifier).state = next.first;
              },
            ),
          ),
          Expanded(
            child: listAsync.when(
              loading: () => const LoadingView(),
              error: (error, _) => ErrorState(
                title: l10n.errorTitle,
                message: error is ApiError
                    ? localizeApiError(l10n, error)
                    : l10n.errorGeneric,
                onRetry: () => ref.invalidate(approvalsListProvider),
              ),
              data: (result) {
                final items = _filterForTab(result.items, tab);

                if (items.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(approvalsListProvider);
                      await ref.read(approvalsListProvider.future);
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.5,
                          child: EmptyState(
                            title: tab == ApprovalQueueTab.pending
                                ? l10n.noApprovals
                                : l10n.noCompletedApprovals,
                            message: tab == ApprovalQueueTab.pending
                                ? l10n.noApprovalsMessage
                                : l10n.noCompletedApprovalsMessage,
                            icon: Icons.fact_check_outlined,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(approvalsListProvider);
                    await ref.read(approvalsListProvider.future);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      AppSpacing.xl,
                    ),
                    itemCount: items.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final task = items[index];
                      return ApprovalTaskCard(
                        key: ValueKey(task.id),
                        task: task,
                        isArabic: isArabic,
                        onTap: () => context.go('/approvals/${task.id}'),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<ApprovalTask> _filterForTab(
    List<ApprovalTask> items,
    ApprovalQueueTab tab,
  ) {
    switch (tab) {
      case ApprovalQueueTab.pending:
        return items
            .where((t) => t.decision.toUpperCase() == 'PENDING')
            .toList(growable: false);
      case ApprovalQueueTab.completed:
        return items
            .where((t) {
              final d = t.decision.toUpperCase();
              return d == 'APPROVED' || d == 'REJECTED';
            })
            .toList(growable: false);
    }
  }
}
