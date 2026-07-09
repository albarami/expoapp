import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../app/theme_tokens.dart';
import '../../l10n/app_localizations.dart';

/// Workflow / request status values used by chips.
enum RequestStatus {
  managerPending,
  securityPending,
  provisioning,
  completed,
  managerRejected,
  securityRejected,
  cancelled,
  failed;

  static RequestStatus? tryParse(String? value) {
    switch (value) {
      case 'MANAGER_PENDING':
        return RequestStatus.managerPending;
      case 'SECURITY_PENDING':
        return RequestStatus.securityPending;
      case 'PROVISIONING':
        return RequestStatus.provisioning;
      case 'COMPLETED':
        return RequestStatus.completed;
      case 'MANAGER_REJECTED':
        return RequestStatus.managerRejected;
      case 'SECURITY_REJECTED':
        return RequestStatus.securityRejected;
      case 'CANCELLED':
        return RequestStatus.cancelled;
      case 'FAILED':
        return RequestStatus.failed;
      default:
        return null;
    }
  }

  String label(AppLocalizations l10n) {
    switch (this) {
      case RequestStatus.managerPending:
        return l10n.statusManagerPending;
      case RequestStatus.securityPending:
        return l10n.statusSecurityPending;
      case RequestStatus.provisioning:
        return l10n.statusProvisioning;
      case RequestStatus.completed:
        return l10n.statusCompleted;
      case RequestStatus.managerRejected:
        return l10n.statusManagerRejected;
      case RequestStatus.securityRejected:
        return l10n.statusSecurityRejected;
      case RequestStatus.cancelled:
        return l10n.statusCancelled;
      case RequestStatus.failed:
        return l10n.statusFailed;
    }
  }

  Color backgroundColor(ColorScheme scheme) {
    switch (this) {
      case RequestStatus.managerPending:
      case RequestStatus.securityPending:
        return AppStatusColors.warning.withValues(alpha: 0.15);
      case RequestStatus.provisioning:
        return AppStatusColors.info.withValues(alpha: 0.15);
      case RequestStatus.completed:
        return AppStatusColors.success.withValues(alpha: 0.15);
      case RequestStatus.managerRejected:
      case RequestStatus.securityRejected:
      case RequestStatus.failed:
        return AppStatusColors.danger.withValues(alpha: 0.15);
      case RequestStatus.cancelled:
        return scheme.surfaceContainerHighest;
    }
  }

  Color foregroundColor(ColorScheme scheme) {
    switch (this) {
      case RequestStatus.managerPending:
      case RequestStatus.securityPending:
        return AppStatusColors.warning;
      case RequestStatus.provisioning:
        return AppStatusColors.info;
      case RequestStatus.completed:
        return AppStatusColors.success;
      case RequestStatus.managerRejected:
      case RequestStatus.securityRejected:
      case RequestStatus.failed:
        return AppStatusColors.danger;
      case RequestStatus.cancelled:
        return scheme.onSurfaceVariant;
    }
  }
}

enum NotificationPriority {
  low,
  normal,
  high,
  urgent;

  static NotificationPriority? tryParse(String? value) {
    switch (value?.toUpperCase()) {
      case 'LOW':
        return NotificationPriority.low;
      case 'NORMAL':
        return NotificationPriority.normal;
      case 'HIGH':
        return NotificationPriority.high;
      case 'URGENT':
        return NotificationPriority.urgent;
      default:
        return null;
    }
  }

  String label(AppLocalizations l10n) {
    switch (this) {
      case NotificationPriority.low:
        return l10n.priorityLow;
      case NotificationPriority.normal:
        return l10n.priorityNormal;
      case NotificationPriority.high:
        return l10n.priorityHigh;
      case NotificationPriority.urgent:
        return l10n.priorityUrgent;
    }
  }

  Color foregroundColor() {
    switch (this) {
      case NotificationPriority.low:
        return AppStatusColors.info;
      case NotificationPriority.normal:
        return AppStatusColors.success;
      case NotificationPriority.high:
        return AppStatusColors.warning;
      case NotificationPriority.urgent:
        return AppStatusColors.danger;
    }
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final RequestStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      label: Text(status.label(l10n)),
      backgroundColor: status.backgroundColor(scheme),
      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: status.foregroundColor(scheme),
            fontWeight: FontWeight.w600,
          ),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
    );
  }
}

class PriorityChip extends StatelessWidget {
  const PriorityChip({super.key, required this.priority});

  final NotificationPriority priority;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = priority.foregroundColor();
    return Chip(
      label: Text(priority.label(l10n)),
      backgroundColor: color.withValues(alpha: 0.12),
      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
    );
  }
}
