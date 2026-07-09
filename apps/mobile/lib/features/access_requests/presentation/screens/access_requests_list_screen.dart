import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme_tokens.dart';
import '../../../../core/api/api_error.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/access_request_models.dart';
import '../access_requests_providers.dart';
import '../widgets/access_request_card.dart';

/// My Requests: status tabs, cards, FAB to create.
class AccessRequestsListScreen extends ConsumerWidget {
  const AccessRequestsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final listAsync = ref.watch(accessRequestsListProvider);
    final tab = ref.watch(accessRequestListTabProvider);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return ExpoAppScaffold(
      title: l10n.requests,
      padding: EdgeInsets.zero,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/requests/new'),
        icon: const Icon(Icons.add),
        label: Text(l10n.newAccessRequest),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final value in AccessRequestListTab.values) ...[
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        end: AppSpacing.sm,
                      ),
                      child: FilterChip(
                        label: Text(_tabLabel(l10n, value)),
                        selected: tab == value,
                        onSelected: (_) {
                          ref.read(accessRequestListTabProvider.notifier).state =
                              value;
                        },
                      ),
                    ),
                  ],
                ],
              ),
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
                onRetry: () => ref.invalidate(accessRequestsListProvider),
              ),
              data: (result) {
                final filtered = result.items
                    .where((item) => tab.matches(item.status))
                    .toList(growable: false);

                if (filtered.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(accessRequestsListProvider);
                      await ref.read(accessRequestsListProvider.future);
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.5,
                          child: EmptyState(
                            title: l10n.noRequests,
                            message: l10n.noRequestsMessage,
                            icon: Icons.assignment_outlined,
                            actionLabel: l10n.newAccessRequest,
                            onAction: () => context.go('/requests/new'),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(accessRequestsListProvider);
                    await ref.read(accessRequestsListProvider.future);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      88,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return AccessRequestCard(
                        item: item,
                        isArabic: isArabic,
                        onTap: () => context.go('/requests/${item.id}'),
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

  String _tabLabel(AppLocalizations l10n, AccessRequestListTab tab) {
    switch (tab) {
      case AccessRequestListTab.all:
        return l10n.filterAll;
      case AccessRequestListTab.pending:
        return l10n.filterPending;
      case AccessRequestListTab.completed:
        return l10n.filterCompleted;
      case AccessRequestListTab.rejected:
        return l10n.filterRejected;
    }
  }
}
