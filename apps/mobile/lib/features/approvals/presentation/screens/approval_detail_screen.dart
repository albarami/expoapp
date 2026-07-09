import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme_tokens.dart';
import '../../../../core/api/api_error.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../access_requests/domain/access_request_models.dart';
import '../../domain/approval_models.dart';
import '../approvals_providers.dart';

/// Approval detail / decision: request summary, timeline, approve/reject.
class ApprovalDetailScreen extends ConsumerStatefulWidget {
  const ApprovalDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  ConsumerState<ApprovalDetailScreen> createState() =>
      _ApprovalDetailScreenState();
}

class _ApprovalDetailScreenState extends ConsumerState<ApprovalDetailScreen> {
  bool _submitting = false;

  Future<void> _openDecisionSheet({
    required ApprovalTask task,
    required ApprovalDecisionInput decision,
  }) async {
    final result = await showModalBottomSheet<_DecisionSheetResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return _DecisionBottomSheet(
          decision: decision,
          requestNumber: task.accessRequest.requestNumber,
        );
      },
    );
    if (result == null || !mounted) return;
    await _submitDecision(task, result);
  }

  Future<void> _submitDecision(
    ApprovalTask task,
    _DecisionSheetResult result,
  ) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _submitting = true);
    try {
      final decided = await ref.read(approvalsRepositoryProvider).decide(
            widget.taskId,
            DecideApprovalPayload(
              decision: result.decision,
              comment: result.comment,
            ),
          );
      ref.invalidate(approvalsListProvider);
      ref.invalidate(approvalTaskProvider(widget.taskId));
      ref.invalidate(
        approvalRequestDetailProvider(task.accessRequest.id),
      );
      if (!mounted) return;
      final message = result.decision == ApprovalDecisionInput.approved
          ? l10n.approvalApprovedSuccess(decided.requestNumber)
          : l10n.approvalRejectedSuccess(decided.requestNumber);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      context.go('/approvals');
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
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final taskAsync = ref.watch(approvalTaskProvider(widget.taskId));
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final locale = Localizations.localeOf(context).toString();

    return ExpoAppScaffold(
      title: l10n.approvalDetail,
      padding: EdgeInsets.zero,
      actions: [
        IconButton(
          tooltip: l10n.approvals,
          onPressed: () => context.go('/approvals'),
          icon: const Icon(Icons.list_alt),
        ),
      ],
      body: taskAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorState(
          title: l10n.errorTitle,
          message: error is ApiError
              ? localizeApiError(l10n, error)
              : (error is StateError
                  ? l10n.errorApprovalNotFound
                  : l10n.errorGeneric),
          onRetry: () => ref.invalidate(approvalTaskProvider(widget.taskId)),
        ),
        data: (task) {
          final detailAsync = ref.watch(
            approvalRequestDetailProvider(task.accessRequest.id),
          );
          return detailAsync.when(
            loading: () => const LoadingView(),
            error: (error, _) => _TaskOnlyBody(
              task: task,
              isArabic: isArabic,
              locale: locale,
              submitting: _submitting,
              onApprove: () => _openDecisionSheet(
                task: task,
                decision: ApprovalDecisionInput.approved,
              ),
              onReject: () => _openDecisionSheet(
                task: task,
                decision: ApprovalDecisionInput.rejected,
              ),
              detailError: error is ApiError
                  ? localizeApiError(l10n, error)
                  : l10n.errorGeneric,
              onRetryDetail: () => ref.invalidate(
                approvalRequestDetailProvider(task.accessRequest.id),
              ),
            ),
            data: (detail) => _DecisionBody(
              task: task,
              detail: detail,
              isArabic: isArabic,
              locale: locale,
              submitting: _submitting,
              onApprove: () => _openDecisionSheet(
                task: task,
                decision: ApprovalDecisionInput.approved,
              ),
              onReject: () => _openDecisionSheet(
                task: task,
                decision: ApprovalDecisionInput.rejected,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DecisionBody extends StatelessWidget {
  const _DecisionBody({
    required this.task,
    required this.detail,
    required this.isArabic,
    required this.locale,
    required this.submitting,
    required this.onApprove,
    required this.onReject,
  });

  final ApprovalTask task;
  final AccessRequestDetail detail;
  final bool isArabic;
  final String locale;
  final bool submitting;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final status = RequestStatus.tryParse(detail.status);
    final dateFmt = DateFormat.yMMMd(locale);
    final dateTimeFmt = DateFormat.yMMMd(locale).add_jm();
    final canDecide = task.isPending && !submitting;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      detail.requestNumber,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (status != null) StatusChip(status: status),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.approvalStageLabel(_stageLabel(l10n, task.stage)),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _DetailRow(
                label: l10n.requester,
                value: detail.requester.localizedName(arabic: isArabic),
              ),
              if (detail.requester.email != null &&
                  detail.requester.email!.isNotEmpty)
                _DetailRow(
                  label: l10n.email,
                  value: detail.requester.email!,
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
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.businessJustification,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                detail.businessJustification,
                style: theme.textTheme.bodyMedium,
              ),
              if (task.comment != null && task.comment!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.decisionComment,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(task.comment!, style: theme.textTheme.bodyMedium),
              ],
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.timeline,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (detail.timeline.isEmpty)
                Text(
                  l10n.noTimelineEvents,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              else
                for (final event in detail.timeline)
                  _TimelineTile(
                    message: event.localizedMessage(arabic: isArabic),
                    timestamp: dateTimeFmt.format(event.createdAt.toLocal()),
                    actor: event.actor?.localizedName(arabic: isArabic),
                  ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
        if (canDecide)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ExpoSecondaryButton(
                      label: l10n.reject,
                      onPressed: submitting ? null : onReject,
                      loading: false,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ExpoPrimaryButton(
                      label: l10n.approve,
                      onPressed: submitting ? null : onApprove,
                      loading: submitting,
                      icon: Icons.check_circle_outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _stageLabel(AppLocalizations l10n, String stage) {
    switch (stage.toUpperCase()) {
      case 'MANAGER':
        return l10n.approvalStageManager;
      case 'SECURITY':
        return l10n.approvalStageSecurity;
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

/// Fallback when request detail fails but the task itself loaded.
class _TaskOnlyBody extends StatelessWidget {
  const _TaskOnlyBody({
    required this.task,
    required this.isArabic,
    required this.locale,
    required this.submitting,
    required this.onApprove,
    required this.onReject,
    required this.detailError,
    required this.onRetryDetail,
  });

  final ApprovalTask task;
  final bool isArabic;
  final String locale;
  final bool submitting;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final String detailError;
  final VoidCallback onRetryDetail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ar = task.accessRequest;
    final status = RequestStatus.tryParse(ar.status);
    final canDecide = task.isPending && !submitting;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ar.requestNumber,
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
                value: ar.requester.localizedName(arabic: isArabic),
              ),
              _DetailRow(
                label: l10n.system,
                value: ar.system.localizedName(arabic: isArabic),
              ),
              _DetailRow(
                label: l10n.securityRole,
                value: ar.securityRole.localizedName(arabic: isArabic),
              ),
              const SizedBox(height: AppSpacing.md),
              ErrorState(
                title: l10n.errorTitle,
                message: detailError,
                onRetry: onRetryDetail,
              ),
            ],
          ),
        ),
        if (canDecide)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: ExpoSecondaryButton(
                      label: l10n.reject,
                      onPressed: onReject,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ExpoPrimaryButton(
                      label: l10n.approve,
                      onPressed: onApprove,
                      icon: Icons.check_circle_outline,
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

class _DecisionSheetResult {
  const _DecisionSheetResult({
    required this.decision,
    this.comment,
  });

  final ApprovalDecisionInput decision;
  final String? comment;
}

class _DecisionBottomSheet extends StatefulWidget {
  const _DecisionBottomSheet({
    required this.decision,
    required this.requestNumber,
  });

  final ApprovalDecisionInput decision;
  final String requestNumber;

  @override
  State<_DecisionBottomSheet> createState() => _DecisionBottomSheetState();
}

class _DecisionBottomSheetState extends State<_DecisionBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _commentController;
  String? _commentError;

  bool get _isReject => widget.decision == ApprovalDecisionInput.rejected;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    final comment = _commentController.text.trim();
    if (_isReject && comment.isEmpty) {
      setState(() => _commentError = l10n.rejectionCommentRequired);
      return;
    }
    if (comment.length > maxApprovalCommentLength) {
      setState(
        () => _commentError = l10n.validationMaxLength(maxApprovalCommentLength),
      );
      return;
    }
    setState(() => _commentError = null);
    Navigator.of(context).pop(
      _DecisionSheetResult(
        decision: widget.decision,
        comment: comment.isEmpty ? null : comment,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final title = _isReject
        ? l10n.rejectConfirmTitle
        : l10n.approveConfirmTitle;
    final message = _isReject
        ? l10n.rejectConfirmMessage
        : l10n.approveConfirmMessage(widget.requestNumber);

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: AppSpacing.md,
        end: AppSpacing.md,
        top: AppSpacing.sm,
        bottom: bottomInset + AppSpacing.md,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(message, style: theme.textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.md),
            Text(
              _isReject ? l10n.rejectionReason : l10n.optionalComment,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _commentController,
              maxLines: 4,
              maxLength: maxApprovalCommentLength,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: _isReject
                    ? l10n.rejectionReasonHint
                    : l10n.optionalCommentHint,
                errorText: _commentError,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) {
                if (_commentError != null) {
                  setState(() => _commentError = null);
                }
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: ExpoSecondaryButton(
                    label: l10n.cancel,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ExpoPrimaryButton(
                    label: _isReject ? l10n.confirmReject : l10n.confirmApprove,
                    onPressed: _submit,
                    icon: _isReject
                        ? Icons.cancel_outlined
                        : Icons.check_circle_outline,
                  ),
                ),
              ],
            ),
          ],
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
