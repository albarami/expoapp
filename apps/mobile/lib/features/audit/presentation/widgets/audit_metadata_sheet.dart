import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/audit_models.dart';

/// Modal bottom sheet with full audit metadata and technical fields.
Future<void> showAuditMetadataSheet(
  BuildContext context, {
  required AuditLogEntry entry,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => AuditMetadataSheet(entry: entry),
  );
}

class AuditMetadataSheet extends StatelessWidget {
  const AuditMetadataSheet({super.key, required this.entry});

  final AuditLogEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final dateLabel = DateFormat.yMMMEd(locale).add_jms().format(
          entry.createdAt.toLocal(),
        );
    final metadataJson = entry.metadata == null || entry.metadata!.isEmpty
        ? l10n.auditNoMetadata
        : const JsonEncoder.withIndent('  ').convert(entry.metadata);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.auditMetadataTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailRow(label: l10n.auditFieldAction, value: entry.action),
                      _DetailRow(
                        label: l10n.auditFieldActor,
                        value: entry.actorEmail?.trim().isNotEmpty == true
                            ? entry.actorEmail!
                            : l10n.auditActorUnknown,
                      ),
                      _DetailRow(
                        label: l10n.auditFieldEntity,
                        value: entry.entityType,
                      ),
                      if (entry.entityId != null && entry.entityId!.isNotEmpty)
                        _DetailRow(
                          label: l10n.auditFieldEntityId,
                          value: entry.entityId!,
                        ),
                      _DetailRow(label: l10n.auditFieldWhen, value: dateLabel),
                      if (entry.ipAddress != null &&
                          entry.ipAddress!.isNotEmpty)
                        _DetailRow(
                          label: l10n.auditFieldIp,
                          value: entry.ipAddress!,
                        ),
                      if (entry.userAgent != null &&
                          entry.userAgent!.isNotEmpty)
                        _DetailRow(
                          label: l10n.auditFieldUserAgent,
                          value: entry.userAgent!,
                        ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        l10n.auditFieldMetadata,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: SelectableText(
                            metadataJson,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(l10n.close),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          SelectableText(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
