import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/audit_models.dart';

/// List card for a single audit log entry.
class AuditLogCard extends StatelessWidget {
  const AuditLogCard({
    super.key,
    required this.entry,
    required this.onViewMetadata,
  });

  final AuditLogEntry entry;
  final VoidCallback onViewMetadata;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final dateLabel = DateFormat.yMMMd(locale).add_jm().format(
          entry.createdAt.toLocal(),
        );
    final actor = (entry.actorEmail?.trim().isNotEmpty ?? false)
        ? entry.actorEmail!
        : l10n.auditActorUnknown;
    final summary = entry.summary;

    return ExpoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  entry.action,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                dateLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            actor,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.auditEntityLabel(entry.entityType),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (summary != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              onPressed: onViewMetadata,
              icon: const Icon(Icons.data_object_outlined, size: 18),
              label: Text(l10n.viewMetadata),
              style: TextButton.styleFrom(
                minimumSize: const Size(44, 44),
                tapTargetSize: MaterialTapTargetSize.padded,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
