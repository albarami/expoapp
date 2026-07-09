import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/notification_models.dart';

/// Inbox list card for a single notification.
class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    required this.isArabic,
    required this.onTap,
    this.showAudience = false,
  });

  final AppNotification notification;
  final bool isArabic;
  final VoidCallback onTap;
  final bool showAudience;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final dateLabel = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    ).format(notification.createdAt.toLocal());
    final priority = NotificationPriority.tryParse(notification.priority) ??
        NotificationPriority.normal;

    return ExpoCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Icon(
              notification.isUnread
                  ? Icons.circle
                  : Icons.circle_outlined,
              size: notification.isUnread ? 10 : 10,
              color: notification.isUnread
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
              semanticLabel:
                  notification.isUnread ? l10n.unread : l10n.readStatus,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.localizedTitle(arabic: isArabic),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: notification.isUnread
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    PriorityChip(priority: priority),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  notification.bodyPreview(arabic: isArabic),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      dateLabel,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (showAudience)
                      Text(
                        _audienceLabel(l10n, notification),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _audienceLabel(AppLocalizations l10n, AppNotification n) {
    switch (n.audienceTypeEnum) {
      case AppAudienceType.all:
        return l10n.audienceAll;
      case AppAudienceType.department:
        return l10n.audienceDepartment;
      case AppAudienceType.role:
        return l10n.audienceRole;
      case AppAudienceType.users:
        return l10n.audienceUsers;
    }
  }
}
