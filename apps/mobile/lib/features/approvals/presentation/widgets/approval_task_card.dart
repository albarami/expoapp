import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/approval_models.dart';

/// List card for a pending/completed approval task.
class ApprovalTaskCard extends StatelessWidget {
  const ApprovalTaskCard({
    super.key,
    required this.task,
    required this.isArabic,
    required this.onTap,
  });

  final ApprovalTask task;
  final bool isArabic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final ar = task.accessRequest;
    final status = RequestStatus.tryParse(ar.status);
    final date = ar.submittedAt ?? task.createdAt;
    final dateLabel = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    ).format(date.toLocal());
    final risk = ar.securityRole.riskLevel;
    final urgencyLabel = _urgencyLabel(l10n, ar.urgency);
    final stageLabel = _approvalStageLabel(l10n, task.stage);
    final ctaLabel = task.isPending ? l10n.review : l10n.viewDetails;

    return ExpoCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ar.requestNumber,
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
            ar.requester.localizedName(arabic: isArabic),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${ar.system.localizedName(arabic: isArabic)} · '
            '${ar.securityRole.localizedName(arabic: isArabic)}',
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
                avatar: const Icon(Icons.account_tree_outlined, size: 16),
                label: Text(stageLabel),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              ),
              Chip(
                avatar: const Icon(Icons.bolt_outlined, size: 16),
                label: Text(urgencyLabel),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              ),
              if (risk != null && risk.isNotEmpty)
                Chip(
                  avatar: Icon(
                    Icons.shield_outlined,
                    size: 16,
                    color: _riskColor(theme, risk),
                  ),
                  label: Text(_riskLabel(l10n, risk)),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                ),
              Text(
                dateLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              ctaLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _approvalStageLabel(AppLocalizations l10n, String stage) {
    switch (stage.toUpperCase()) {
      case 'MANAGER':
        return l10n.approvalStageManager;
      case 'SECURITY':
        return l10n.approvalStageSecurity;
      default:
        return stage;
    }
  }

  String _urgencyLabel(AppLocalizations l10n, String value) {
    switch (value.toUpperCase()) {
      case 'NORMAL':
        return l10n.urgencyNormal;
      case 'URGENT':
        return l10n.urgencyUrgent;
      case 'CRITICAL':
        return l10n.urgencyCritical;
      default:
        return value;
    }
  }

  String _riskLabel(AppLocalizations l10n, String value) {
    switch (value.toUpperCase()) {
      case 'LOW':
        return l10n.riskLow;
      case 'MEDIUM':
        return l10n.riskMedium;
      case 'HIGH':
        return l10n.riskHigh;
      case 'CRITICAL':
        return l10n.riskCritical;
      default:
        return value;
    }
  }

  Color _riskColor(ThemeData theme, String risk) {
    switch (risk.toUpperCase()) {
      case 'LOW':
        return theme.colorScheme.primary;
      case 'MEDIUM':
        return theme.colorScheme.tertiary;
      case 'HIGH':
      case 'CRITICAL':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }
}
