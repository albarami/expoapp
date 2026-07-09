import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/access_request_models.dart';

/// List card for a single access request.
class AccessRequestCard extends StatelessWidget {
  const AccessRequestCard({
    super.key,
    required this.item,
    required this.isArabic,
    required this.onTap,
  });

  final AccessRequestListItem item;
  final bool isArabic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final status = RequestStatus.tryParse(item.status);
    final date = item.submittedAt ?? item.createdAt;
    final dateLabel = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    ).format(date.toLocal());
    final stageLabel = _stageLabel(l10n, item.currentStage);

    return ExpoCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.requestNumber,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (status != null) StatusChip(status: status),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            item.system.localizedName(arabic: isArabic),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            item.securityRole.localizedName(arabic: isArabic),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Chip(
                label: Text(stageLabel),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              ),
              Text(
                dateLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _stageLabel(AppLocalizations l10n, String stage) {
    switch (stage.toUpperCase()) {
      case 'REQUESTER':
        return l10n.stageRequester;
      case 'MANAGER':
        return l10n.stageManager;
      case 'SECURITY':
        return l10n.stageSecurity;
      case 'PROVISIONING':
        return l10n.stageProvisioning;
      case 'COMPLETE':
        return l10n.stageComplete;
      default:
        return stage;
    }
  }
}
