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
import '../../domain/dashboard_summary.dart';
import '../dashboard_providers.dart';
import '../widgets/dashboard_section.dart';
import '../widgets/metric_card.dart';

/// Role-aware home dashboard consuming `GET /dashboard/summary`.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final user = ref.watch(sessionControllerProvider).user;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return ExpoAppScaffold(
      title: l10n.dashboard,
      padding: EdgeInsets.zero,
      body: summaryAsync.when(
        loading: () => const _DashboardLoadingBody(),
        error: (error, _) => ErrorState(
          title: l10n.errorTitle,
          message: error is ApiError
              ? localizeApiError(l10n, error)
              : l10n.errorGeneric,
          onRetry: () => ref.invalidate(dashboardSummaryProvider),
        ),
        data: (summary) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardSummaryProvider);
            await ref.read(dashboardSummaryProvider.future);
          },
          child: _DashboardBody(
            summary: summary,
            user: user,
            isArabic: isArabic,
          ),
        ),
      ),
    );
  }
}

class _DashboardLoadingBody extends StatelessWidget {
  const _DashboardLoadingBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 720 ? 4 : 2;
            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: columns == 4 ? 1.35 : 1.2,
              children: const [
                MetricCardSkeleton(),
                MetricCardSkeleton(),
                MetricCardSkeleton(),
                MetricCardSkeleton(),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        const LoadingView(),
      ],
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.summary,
    required this.user,
    required this.isArabic,
  });

  final DashboardSummary summary;
  final AppUser? user;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final greetingName = user?.localizedName(arabic: isArabic) ?? '';

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        if (greetingName.isNotEmpty) ...[
          Text(
            l10n.dashboardGreeting(greetingName),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.dashboardSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        _MetricsGrid(summary: summary),
        const SizedBox(height: AppSpacing.lg),
        _QuickActions(role: summary.role),
        const SizedBox(height: AppSpacing.lg),
        if (summary.role == AppRole.employee ||
            summary.role == AppRole.manager) ...[
          DashboardSection(
            title: l10n.latestNotifications,
            actionLabel: l10n.viewAll,
            onAction: () => context.go('/notifications'),
            child: _NotificationsList(
              items: summary.latestNotifications,
              isArabic: isArabic,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (summary.role == AppRole.employee) ...[
          DashboardSection(
            title: l10n.latestRequests,
            actionLabel: l10n.viewAll,
            onAction: () => context.go('/requests'),
            child: _RequestsList(items: summary.latestRequests),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (summary.role == AppRole.systemAdmin &&
            summary.notificationStats != null) ...[
          DashboardSection(
            title: l10n.notificationStats,
            child: _NotificationStatsCard(stats: summary.notificationStats!),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (summary.role == AppRole.systemAdmin &&
            summary.accessWorkflowStats != null) ...[
          DashboardSection(
            title: l10n.accessWorkflowStats,
            child: _WorkflowStatsCard(stats: summary.accessWorkflowStats!),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (summary.role == AppRole.securityAdmin ||
            summary.role == AppRole.systemAdmin) ...[
          DashboardSection(
            title: l10n.recentAuditEvents,
            actionLabel: l10n.viewAll,
            onAction: () => context.go('/audit'),
            child: _AuditList(items: summary.recentAuditEvents ?? const []),
          ),
        ],
      ],
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final metrics = _metricsForRole(summary, l10n, context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 4 : 2;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: columns == 4 ? 1.35 : 1.15,
          children: metrics,
        );
      },
    );
  }

  List<Widget> _metricsForRole(
    DashboardSummary summary,
    AppLocalizations l10n,
    BuildContext context,
  ) {
    switch (summary.role) {
      case AppRole.manager:
        return [
          MetricCard(
            label: l10n.pendingApprovals,
            value: '${summary.pendingApprovals}',
            icon: Icons.fact_check_outlined,
            emphasis: summary.pendingApprovals > 0,
            onTap: () => context.go('/approvals'),
          ),
          MetricCard(
            label: l10n.teamOpenRequests,
            value: '${summary.teamOpenRequests ?? 0}',
            icon: Icons.groups_outlined,
            onTap: () => context.go('/approvals'),
          ),
          MetricCard(
            label: l10n.unreadNotifications,
            value: '${summary.unreadNotifications}',
            icon: Icons.notifications_outlined,
            onTap: () => context.go('/notifications'),
          ),
          MetricCard(
            label: l10n.openAccessRequests,
            value: '${summary.openAccessRequests}',
            icon: Icons.assignment_outlined,
            onTap: () => context.go('/requests'),
          ),
        ];
      case AppRole.securityAdmin:
        return [
          MetricCard(
            label: l10n.pendingSecurityApprovals,
            value: '${summary.pendingSecurityApprovals ?? 0}',
            icon: Icons.security_outlined,
            emphasis: (summary.pendingSecurityApprovals ?? 0) > 0,
            onTap: () => context.go('/approvals'),
          ),
          MetricCard(
            label: l10n.highRiskOpenRequests,
            value: '${summary.highRiskOpenRequests ?? 0}',
            icon: Icons.warning_amber_outlined,
            emphasis: (summary.highRiskOpenRequests ?? 0) > 0,
            onTap: () => context.go('/approvals'),
          ),
          MetricCard(
            label: l10n.pendingApprovals,
            value: '${summary.pendingApprovals}',
            icon: Icons.fact_check_outlined,
            onTap: () => context.go('/approvals'),
          ),
          MetricCard(
            label: l10n.unreadNotifications,
            value: '${summary.unreadNotifications}',
            icon: Icons.notifications_outlined,
            onTap: () => context.go('/notifications'),
          ),
        ];
      case AppRole.systemAdmin:
        final notif = summary.notificationStats;
        final workflow = summary.accessWorkflowStats;
        return [
          MetricCard(
            label: l10n.publishedNotifications,
            value: '${notif?.publishedCount ?? 0}',
            icon: Icons.campaign_outlined,
            onTap: () => context.go('/notifications'),
          ),
          MetricCard(
            label: l10n.readPercentage,
            value: '${notif?.readPercentage ?? 0}%',
            icon: Icons.mark_email_read_outlined,
          ),
          MetricCard(
            label: l10n.openAccessRequests,
            value: '${workflow?.openAccessRequests ?? summary.openAccessRequests}',
            icon: Icons.assignment_outlined,
            onTap: () => context.go('/requests'),
          ),
          MetricCard(
            label: l10n.pendingSecurityApprovals,
            value: '${workflow?.pendingSecurityApprovals ?? 0}',
            icon: Icons.security_outlined,
            onTap: () => context.go('/approvals'),
          ),
        ];
      case AppRole.employee:
        return [
          MetricCard(
            label: l10n.unreadNotifications,
            value: '${summary.unreadNotifications}',
            icon: Icons.notifications_outlined,
            emphasis: summary.unreadNotifications > 0,
            onTap: () => context.go('/notifications'),
          ),
          MetricCard(
            label: l10n.openAccessRequests,
            value: '${summary.openAccessRequests}',
            icon: Icons.assignment_outlined,
            onTap: () => context.go('/requests'),
          ),
          MetricCard(
            label: l10n.completedRequests,
            value: '${summary.completedRequests}',
            icon: Icons.check_circle_outline,
            onTap: () => context.go('/requests'),
          ),
          MetricCard(
            label: l10n.pendingApprovals,
            value: '${summary.pendingApprovals}',
            icon: Icons.hourglass_empty,
          ),
        ];
    }
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.role});

  final AppRole role;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final actions = <Widget>[];

    if (role == AppRole.employee || role == AppRole.manager) {
      actions.add(
        ExpoPrimaryButton(
          label: l10n.newAccessRequest,
          icon: Icons.add,
          onPressed: () => context.go('/requests/new'),
        ),
      );
    }
    // Screen spec: Create Notification quick action is System Admin home.
    if (role == AppRole.systemAdmin) {
      if (actions.isNotEmpty) {
        actions.add(const SizedBox(width: AppSpacing.sm));
      }
      actions.add(
        ExpoPrimaryButton(
          label: l10n.createNotification,
          icon: Icons.campaign_outlined,
          onPressed: () => context.go('/admin/notifications/create'),
        ),
      );
    }
    if (role == AppRole.manager ||
        role == AppRole.securityAdmin ||
        role == AppRole.systemAdmin) {
      if (actions.isNotEmpty) {
        actions.add(const SizedBox(width: AppSpacing.sm));
      }
      actions.add(
        ExpoSecondaryButton(
          label: l10n.approvals,
          onPressed: () => context.go('/approvals'),
        ),
      );
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: actions,
    );
  }
}

class _NotificationsList extends StatelessWidget {
  const _NotificationsList({
    required this.items,
    required this.isArabic,
  });

  final List<DashboardNotificationItem> items;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (items.isEmpty) {
      return _InlineEmpty(
        title: l10n.noNotifications,
        message: l10n.noNotificationsMessage,
      );
    }

    final dateFormat = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    );

    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ExpoCard(
              onTap: () => context.go('/notifications/${item.id}'),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    item.isUnread
                        ? Icons.mark_email_unread_outlined
                        : Icons.mark_email_read_outlined,
                    color: item.isUnread
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.localizedTitle(arabic: isArabic),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: item.isUnread
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          dateFormat.format(item.createdAt.toLocal()),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  PriorityChip(
                    priority: NotificationPriority.tryParse(item.priority) ??
                        NotificationPriority.normal,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _RequestsList extends StatelessWidget {
  const _RequestsList({required this.items});

  final List<DashboardRequestItem> items;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (items.isEmpty) {
      return _InlineEmpty(
        title: l10n.noRequests,
        message: l10n.noData,
        actionLabel: l10n.newAccessRequest,
        onAction: () => context.go('/requests/new'),
      );
    }

    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ExpoCard(
              onTap: () => context.go('/requests/${item.id}'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.requestNumber,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      if (RequestStatus.tryParse(item.status) != null)
                        StatusChip(
                          status: RequestStatus.tryParse(item.status)!,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${item.systemNameEn} · ${item.securityRoleNameEn}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _AuditList extends StatelessWidget {
  const _AuditList({required this.items});

  final List<DashboardAuditItem> items;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (items.isEmpty) {
      return _InlineEmpty(
        title: l10n.noAuditEvents,
        message: l10n.noData,
      );
    }

    final dateFormat = DateFormat.yMMMd().add_jm();

    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ExpoCard(
              onTap: () => context.go('/audit'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.action,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${item.entityType}${item.entityId != null ? ' · ${item.entityId}' : ''}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    [
                      if (item.actorEmail != null) item.actorEmail!,
                      dateFormat.format(item.createdAt.toLocal()),
                    ].join(' · '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _NotificationStatsCard extends StatelessWidget {
  const _NotificationStatsCard({required this.stats});

  final DashboardNotificationStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ExpoCard(
      child: Column(
        children: [
          _StatRow(
            label: l10n.publishedNotifications,
            value: '${stats.publishedCount}',
          ),
          _StatRow(
            label: l10n.totalRecipients,
            value: '${stats.recipientCount}',
          ),
          _StatRow(
            label: l10n.readCount,
            value: '${stats.readCount}',
          ),
          _StatRow(
            label: l10n.readPercentage,
            value: '${stats.readPercentage}%',
          ),
        ],
      ),
    );
  }
}

class _WorkflowStatsCard extends StatelessWidget {
  const _WorkflowStatsCard({required this.stats});

  final DashboardAccessWorkflowStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ExpoCard(
      child: Column(
        children: [
          _StatRow(
            label: l10n.openAccessRequests,
            value: '${stats.openAccessRequests}',
          ),
          _StatRow(
            label: l10n.pendingManagerApprovals,
            value: '${stats.pendingManagerApprovals}',
          ),
          _StatRow(
            label: l10n.pendingSecurityApprovals,
            value: '${stats.pendingSecurityApprovals}',
          ),
          _StatRow(
            label: l10n.completedRequests,
            value: '${stats.completedRequests}',
          ),
        ],
      ),
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
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
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

/// Compact empty placeholder for dashboard list sections (avoids full-screen EmptyState).
class _InlineEmpty extends StatelessWidget {
  const _InlineEmpty({
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ExpoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleSmall),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              message!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.sm),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
