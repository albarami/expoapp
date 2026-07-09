import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme_tokens.dart';
import '../../../../core/api/api_error.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/access_request_models.dart';
import '../access_requests_providers.dart';

/// Request detail with timeline and cancel when allowed.
class AccessRequestDetailScreen extends ConsumerStatefulWidget {
  const AccessRequestDetailScreen({super.key, required this.requestId});

  final String requestId;

  @override
  ConsumerState<AccessRequestDetailScreen> createState() =>
      _AccessRequestDetailScreenState();
}

class _AccessRequestDetailScreenState
    extends ConsumerState<AccessRequestDetailScreen> {
  bool _cancelling = false;

  Future<void> _cancelRequest(AccessRequestDetail detail) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cancelRequestTitle),
        content: Text(l10n.cancelRequestMessage(detail.requestNumber)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _cancelling = true);
    try {
      await ref
          .read(accessRequestsRepositoryProvider)
          .cancel(widget.requestId);
      ref.invalidate(accessRequestDetailProvider(widget.requestId));
      ref.invalidate(accessRequestsListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.requestCancelled)),
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
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final detailAsync =
        ref.watch(accessRequestDetailProvider(widget.requestId));
    final user = ref.watch(sessionControllerProvider).user;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final locale = Localizations.localeOf(context).toString();

    return ExpoAppScaffold(
      title: l10n.requestDetail,
      padding: EdgeInsets.zero,
      actions: [
        IconButton(
          tooltip: l10n.requests,
          onPressed: () => context.go('/requests'),
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
          onRetry: () =>
              ref.invalidate(accessRequestDetailProvider(widget.requestId)),
        ),
        data: (detail) {
          final status = RequestStatus.tryParse(detail.status);
          final canCancel = detail.isCancelable &&
              user != null &&
              user.id == detail.requester.id;
          final dateFmt = DateFormat.yMMMd(locale);
          final dateTimeFmt = DateFormat.yMMMd(locale).add_jm();

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      detail.requestNumber,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  if (status != null) StatusChip(status: status),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _DetailRow(
                label: l10n.requester,
                value: detail.requester.localizedName(arabic: isArabic),
              ),
              _DetailRow(
                label: l10n.system,
                value: detail.system.localizedName(arabic: isArabic),
              ),
              _DetailRow(
                label: l10n.securityRole,
                value: detail.securityRole.localizedName(arabic: isArabic),
              ),
              if (detail.securityRole.riskLevel != null)
                _DetailRow(
                  label: l10n.riskLevel,
                  value: _riskLabel(l10n, detail.securityRole.riskLevel!),
                ),
              _DetailRow(
                label: l10n.currentStage,
                value: _stageLabel(l10n, detail.currentStage),
              ),
              _DetailRow(
                label: l10n.duration,
                value: _durationLabel(l10n, detail.accessDuration),
              ),
              _DetailRow(
                label: l10n.urgency,
                value: _urgencyLabel(l10n, detail.urgency),
              ),
              if (detail.startDate != null)
                _DetailRow(
                  label: l10n.startDate,
                  value: dateFmt.format(detail.startDate!.toLocal()),
                ),
              if (detail.endDate != null)
                _DetailRow(
                  label: l10n.endDate,
                  value: dateFmt.format(detail.endDate!.toLocal()),
                ),
              if (detail.nextApprover != null)
                _DetailRow(
                  label: l10n.nextApprover,
                  value:
                      detail.nextApprover!.localizedName(arabic: isArabic),
                ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.businessJustification,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                detail.businessJustification,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.timeline,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (detail.timeline.isEmpty)
                Text(
                  l10n.noTimelineEvents,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                )
              else
                for (final event in detail.timeline)
                  _TimelineTile(
                    message: event.localizedMessage(arabic: isArabic),
                    timestamp: dateTimeFmt.format(event.createdAt.toLocal()),
                    actor: event.actor?.localizedName(arabic: isArabic),
                  ),
              if (canCancel) ...[
                const SizedBox(height: AppSpacing.xl),
                ExpoSecondaryButton(
                  label: l10n.cancelRequest,
                  onPressed: _cancelling ? null : () => _cancelRequest(detail),
                  loading: _cancelling,
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
            ],
          );
        },
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

  String _durationLabel(AppLocalizations l10n, String value) {
    switch (value.toUpperCase()) {
      case 'TEMPORARY':
        return l10n.durationTemporary;
      case 'PERMANENT':
        return l10n.durationPermanent;
      default:
        return value;
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.message,
    required this.timestamp,
    this.actor,
  });

  final String message;
  final String timestamp;
  final String? actor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(
              Icons.circle,
              size: 10,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: theme.textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  actor == null ? timestamp : '$timestamp · $actor',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
