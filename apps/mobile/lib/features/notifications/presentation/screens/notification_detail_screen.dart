import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme_tokens.dart';
import '../../../../core/api/api_error.dart';
import '../../../../core/auth/app_user.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/widgets.dart';
import '../notifications_providers.dart';

/// Notification detail with explicit mark-as-read and admin stats.
class NotificationDetailScreen extends ConsumerStatefulWidget {
  const NotificationDetailScreen({super.key, required this.notificationId});

  final String notificationId;

  @override
  ConsumerState<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState
    extends ConsumerState<NotificationDetailScreen> {
  bool _marking = false;

  Future<void> _markRead() async {
    if (_marking) return;
    setState(() => _marking = true);
    final l10n = AppLocalizations.of(context);
    try {
      await ref
          .read(notificationsRepositoryProvider)
          .markAsRead(widget.notificationId);
      ref.invalidate(notificationDetailProvider(widget.notificationId));
      ref.invalidate(notificationsListProvider);
      ref.invalidate(notificationStatsProvider(widget.notificationId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.markedAsRead)),
        );
      }
    } on ApiError catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizeApiError(l10n, e))),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorGeneric)),
        );
      }
    } finally {
      if (mounted) setState(() => _marking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final detailAsync =
        ref.watch(notificationDetailProvider(widget.notificationId));
    final user = ref.watch(sessionControllerProvider).user;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final canViewStats = user?.role == AppRole.systemAdmin ||
        user?.role == AppRole.securityAdmin;

    return ExpoAppScaffold(
      title: l10n.notificationDetail,
      padding: EdgeInsets.zero,
      actions: [
        IconButton(
          tooltip: l10n.notifications,
          onPressed: () => context.go('/notifications'),
          icon: const Icon(Icons.list_alt),
        ),
      ],
      body: detailAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorState(
          title: l10n.errorTitle,
          message: error is ApiError
              ? localizeApiError(l10n, error)
              : l10n.errorGeneric,
          onRetry: () => ref.invalidate(
            notificationDetailProvider(widget.notificationId),
          ),
        ),
        data: (notification) {
          final priority =
              NotificationPriority.tryParse(notification.priority) ??
                  NotificationPriority.normal;
          final dateLabel = DateFormat.yMMMd().add_jm().format(
                notification.createdAt.toLocal(),
              );

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Row(
                children: [
                  PriorityChip(priority: priority),
                  const SizedBox(width: AppSpacing.sm),
                  Chip(
                    label: Text(
                      notification.isUnread ? l10n.unread : l10n.readStatus,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                notification.localizedTitle(arabic: isArabic),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                dateLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                notification.localizedBody(arabic: isArabic),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.5,
                    ),
              ),
              if (notification.isUnread) ...[
                const SizedBox(height: AppSpacing.xl),
                ExpoPrimaryButton(
                  label: l10n.markAsRead,
                  loading: _marking,
                  onPressed: _markRead,
                  icon: Icons.done_all,
                ),
              ],
              if (canViewStats) ...[
                const SizedBox(height: AppSpacing.xl),
                Text(
                  l10n.notificationStats,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _StatsSection(notificationId: widget.notificationId),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _StatsSection extends ConsumerWidget {
  const _StatsSection({required this.notificationId});

  final String notificationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final statsAsync = ref.watch(notificationStatsProvider(notificationId));

    return statsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: LinearProgressIndicator(),
      ),
      error: (error, _) => Text(
        error is ApiError ? localizeApiError(l10n, error) : l10n.errorGeneric,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
      data: (stats) {
        return ExpoCard(
          child: Column(
            children: [
              _StatRow(
                label: l10n.totalRecipients,
                value: '${stats.recipientCount}',
              ),
              _StatRow(
                label: l10n.deliveredCount,
                value: '${stats.deliveredCount}',
              ),
              _StatRow(
                label: l10n.readCount,
                value: '${stats.readCount}',
              ),
              _StatRow(
                label: l10n.unreadCountLabel,
                value: '${stats.unreadCount}',
              ),
              _StatRow(
                label: l10n.readPercentage,
                value: '${stats.readPercentage}%',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
