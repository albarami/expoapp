import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme_tokens.dart';
import '../../../../core/api/api_error.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/audit_models.dart';
import '../audit_providers.dart';
import '../widgets/audit_log_card.dart';
import '../widgets/audit_metadata_sheet.dart';

/// Admin audit logs viewer: filters, pagination, metadata modal.
class AuditLogsScreen extends ConsumerStatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  ConsumerState<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends ConsumerState<AuditLogsScreen> {
  final _actorController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(auditListQueryProvider).actorEmail;
    if (initial != null) {
      _actorController.text = initial;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _actorController.dispose();
    super.dispose();
  }

  void _onActorChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final current = ref.read(auditListQueryProvider);
      final trimmed = value.trim();
      ref.read(auditListQueryProvider.notifier).state = current.copyWith(
        page: 1,
        actorEmail: trimmed,
        clearActorEmail: trimmed.isEmpty,
      );
    });
  }

  Future<void> _pickFromDate() async {
    final current = ref.read(auditListQueryProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: current.from?.toLocal() ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked == null || !mounted) return;
    ref.read(auditListQueryProvider.notifier).state = current.copyWith(
      page: 1,
      from: DateTime(picked.year, picked.month, picked.day),
    );
  }

  Future<void> _pickToDate() async {
    final current = ref.read(auditListQueryProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: current.to?.toLocal() ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked == null || !mounted) return;
    ref.read(auditListQueryProvider.notifier).state = current.copyWith(
      page: 1,
      to: DateTime(picked.year, picked.month, picked.day, 23, 59, 59, 999),
    );
  }

  void _clearFilters() {
    _actorController.clear();
    ref.read(auditListQueryProvider.notifier).state = const AuditListQuery();
  }

  void _goToPage(int page) {
    final current = ref.read(auditListQueryProvider);
    if (page < 1 || page == current.page) return;
    ref.read(auditListQueryProvider.notifier).state =
        current.copyWith(page: page);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final listAsync = ref.watch(auditLogsListProvider);
    final query = ref.watch(auditListQueryProvider);
    final locale = Localizations.localeOf(context).toString();
    final dateFmt = DateFormat.yMMMd(locale);

    return ExpoAppScaffold(
      title: l10n.auditLogs,
      padding: EdgeInsets.zero,
      actions: [
        if (query.hasActiveFilters)
          IconButton(
            tooltip: l10n.clearFilters,
            onPressed: _clearFilters,
            icon: const Icon(Icons.filter_alt_off_outlined),
          ),
      ],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _actorController,
                  onChanged: _onActorChanged,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: l10n.searchActorEmail,
                    prefixIcon: const Icon(Icons.person_search_outlined),
                    suffixIcon: _actorController.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: l10n.clearFilters,
                            onPressed: () {
                              _actorController.clear();
                              _onActorChanged('');
                              setState(() {});
                            },
                            icon: const Icon(Icons.clear),
                          ),
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        key: ValueKey('audit-action-${query.action}'),
                        initialValue: query.action,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l10n.filterAction,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text(l10n.filterAll),
                          ),
                          ...AuditActionCodes.all.map(
                            (code) => DropdownMenuItem<String?>(
                              value: code,
                              child: Text(
                                code,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          ref.read(auditListQueryProvider.notifier).state =
                              query.copyWith(
                            page: 1,
                            action: value,
                            clearAction: value == null,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        key: ValueKey('audit-entity-${query.entityType}'),
                        initialValue: query.entityType,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l10n.filterEntityType,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text(l10n.filterAll),
                          ),
                          ...AuditEntityTypes.all.map(
                            (type) => DropdownMenuItem<String?>(
                              value: type,
                              child: Text(type),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          ref.read(auditListQueryProvider.notifier).state =
                              query.copyWith(
                            page: 1,
                            entityType: value,
                            clearEntityType: value == null,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickFromDate,
                        icon: const Icon(Icons.calendar_today_outlined, size: 18),
                        label: Text(
                          query.from == null
                              ? l10n.filterFromDate
                              : dateFmt.format(query.from!.toLocal()),
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(44, 44),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickToDate,
                        icon: const Icon(Icons.event_outlined, size: 18),
                        label: Text(
                          query.to == null
                              ? l10n.filterToDate
                              : dateFmt.format(query.to!.toLocal()),
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(44, 44),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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
                onRetry: () => ref.invalidate(auditLogsListProvider),
              ),
              data: (result) {
                if (result.items.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(auditLogsListProvider);
                      await ref.read(auditLogsListProvider.future);
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.45,
                          child: EmptyState(
                            title: l10n.noAuditLogs,
                            message: query.hasActiveFilters
                                ? l10n.noAuditLogsFilteredMessage
                                : l10n.noAuditLogsMessage,
                            icon: Icons.policy_outlined,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(auditLogsListProvider);
                    await ref.read(auditLogsListProvider.future);
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      AppSpacing.xl,
                    ),
                    itemCount: result.items.length + 1,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      if (index == result.items.length) {
                        return _PaginationBar(
                          page: result.page,
                          totalPages: result.totalPages > 0
                              ? result.totalPages
                              : (result.total == 0
                                  ? 0
                                  : (result.total / result.pageSize).ceil()),
                          total: result.total,
                          onPrevious: result.page > 1
                              ? () => _goToPage(result.page - 1)
                              : null,
                          onNext: result.hasMore
                              ? () => _goToPage(result.page + 1)
                              : null,
                        );
                      }
                      final entry = result.items[index];
                      return AuditLogCard(
                        key: ValueKey(entry.id),
                        entry: entry,
                        onViewMetadata: () => showAuditMetadataSheet(
                          context,
                          entry: entry,
                        ),
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
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.page,
    required this.totalPages,
    required this.total,
    required this.onPrevious,
    required this.onNext,
  });

  final int page;
  final int totalPages;
  final int total;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          IconButton(
            tooltip: l10n.previousPage,
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
            style: IconButton.styleFrom(
              minimumSize: const Size(44, 44),
            ),
          ),
          Expanded(
            child: Text(
              l10n.auditPageStatus(page, totalPages, total),
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          IconButton(
            tooltip: l10n.nextPage,
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
            style: IconButton.styleFrom(
              minimumSize: const Size(44, 44),
            ),
          ),
        ],
      ),
    );
  }
}
