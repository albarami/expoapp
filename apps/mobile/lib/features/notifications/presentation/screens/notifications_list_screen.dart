import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme_tokens.dart';
import '../../../../core/api/api_error.dart';
import '../../../../core/auth/app_user.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/notification_models.dart';
import '../notifications_providers.dart';
import '../widgets/notification_card.dart';

enum _InboxFilter { all, unread, high, critical }

/// Notifications inbox: search, filter chips, pull-to-refresh.
class NotificationsListScreen extends ConsumerStatefulWidget {
  const NotificationsListScreen({super.key});

  @override
  ConsumerState<NotificationsListScreen> createState() =>
      _NotificationsListScreenState();
}

class _NotificationsListScreenState
    extends ConsumerState<NotificationsListScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  _InboxFilter _filter = _InboxFilter.all;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      final current = ref.read(notificationListQueryProvider);
      ref.read(notificationListQueryProvider.notifier).state = current.copyWith(
        page: 1,
        search: value,
        clearSearch: value.trim().isEmpty,
      );
    });
  }

  void _applyFilter(_InboxFilter filter) {
    setState(() => _filter = filter);
    final current = ref.read(notificationListQueryProvider);
    switch (filter) {
      case _InboxFilter.all:
        ref.read(notificationListQueryProvider.notifier).state =
            current.copyWith(
          page: 1,
          clearUnreadOnly: true,
          clearPriority: true,
        );
      case _InboxFilter.unread:
        ref.read(notificationListQueryProvider.notifier).state =
            current.copyWith(
          page: 1,
          unreadOnly: true,
          clearPriority: true,
        );
      case _InboxFilter.high:
        ref.read(notificationListQueryProvider.notifier).state =
            current.copyWith(
          page: 1,
          priority: AppNotificationPriority.high,
          clearUnreadOnly: true,
        );
      case _InboxFilter.critical:
        ref.read(notificationListQueryProvider.notifier).state =
            current.copyWith(
          page: 1,
          priority: AppNotificationPriority.critical,
          clearUnreadOnly: true,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final listAsync = ref.watch(notificationsListProvider);
    final user = ref.watch(sessionControllerProvider).user;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final canCreate = user?.canCreateNotification ?? false;

    return ExpoAppScaffold(
      title: l10n.notifications,
      padding: EdgeInsets.zero,
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () => context.go('/admin/notifications/create'),
              icon: const Icon(Icons.add),
              label: Text(l10n.createNotification),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.searchNotifications,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: l10n.cancel,
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear),
                      ),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                _FilterChip(
                  label: l10n.filterAll,
                  selected: _filter == _InboxFilter.all,
                  onSelected: () => _applyFilter(_InboxFilter.all),
                ),
                const SizedBox(width: AppSpacing.sm),
                _FilterChip(
                  label: l10n.filterUnread,
                  selected: _filter == _InboxFilter.unread,
                  onSelected: () => _applyFilter(_InboxFilter.unread),
                ),
                const SizedBox(width: AppSpacing.sm),
                _FilterChip(
                  label: l10n.priorityHigh,
                  selected: _filter == _InboxFilter.high,
                  onSelected: () => _applyFilter(_InboxFilter.high),
                ),
                const SizedBox(width: AppSpacing.sm),
                _FilterChip(
                  label: l10n.priorityCritical,
                  selected: _filter == _InboxFilter.critical,
                  onSelected: () => _applyFilter(_InboxFilter.critical),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: listAsync.when(
              loading: () => const LoadingView(),
              error: (error, _) => ErrorState(
                title: l10n.errorTitle,
                message: error is ApiError
                    ? localizeApiError(l10n, error)
                    : l10n.errorGeneric,
                onRetry: () => ref.invalidate(notificationsListProvider),
              ),
              data: (result) {
                if (result.items.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(notificationsListProvider);
                      await ref.read(notificationsListProvider.future);
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.5,
                          child: EmptyState(
                            title: l10n.noNotifications,
                            message: l10n.noNotificationsMessage,
                            icon: Icons.notifications_none,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final unreadCount =
                    result.items.where((n) => n.isUnread).length;

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(notificationsListProvider);
                    await ref.read(notificationsListProvider.future);
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: result.items.length + 1,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Text(
                          l10n.notificationsUnreadCount(unreadCount),
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        );
                      }
                      final item = result.items[index - 1];
                      return NotificationCard(
                        notification: item,
                        isArabic: isArabic,
                        showAudience: user?.role == AppRole.systemAdmin ||
                            user?.role == AppRole.securityAdmin,
                        onTap: () => context.go('/notifications/${item.id}'),
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }
}
