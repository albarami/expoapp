import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme_tokens.dart';
import '../../../../core/api/api_error.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../data/access_reference_catalog.dart';
import '../../domain/access_request_models.dart';
import '../access_requests_providers.dart';

/// New access request form backed by reference-data + POST /access-requests.
class CreateAccessRequestScreen extends ConsumerStatefulWidget {
  const CreateAccessRequestScreen({super.key});

  @override
  ConsumerState<CreateAccessRequestScreen> createState() =>
      _CreateAccessRequestScreenState();
}

class _CreateAccessRequestScreenState
    extends ConsumerState<CreateAccessRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _justification = TextEditingController();

  String? _systemId;
  String? _securityRoleId;
  AccessDuration _duration = AccessDuration.temporary;
  AccessUrgency _urgency = AccessUrgency.normal;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _submitting = false;

  @override
  void dispose() {
    _justification.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool end}) async {
    final now = DateTime.now();
    final initial = end
        ? (_endDate ?? _startDate.add(const Duration(days: 30)))
        : _startDate;
    final first = end ? _startDate : now.subtract(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(first) ? first : initial,
      firstDate: first,
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (end) {
        _endDate = picked;
      } else {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate)) {
          _endDate = null;
        }
      }
    });
  }

  bool get _isValid {
    final justification = _justification.text.trim();
    if (_systemId == null || _securityRoleId == null) return false;
    if (justification.length < minJustificationLength) return false;
    if (justification.length > maxJustificationLength) return false;
    if (_duration == AccessDuration.temporary && _endDate == null) return false;
    if (_endDate != null && _endDate!.isBefore(_startDate)) return false;
    return true;
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorValidation)),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final result = await ref.read(accessRequestsRepositoryProvider).create(
            CreateAccessRequestPayload(
              systemId: _systemId!,
              securityRoleId: _securityRoleId!,
              businessJustification: _justification.text.trim(),
              accessDuration: _duration,
              startDate: DateTime(
                _startDate.year,
                _startDate.month,
                _startDate.day,
              ),
              endDate: _duration == AccessDuration.temporary && _endDate != null
                  ? DateTime(
                      _endDate!.year,
                      _endDate!.month,
                      _endDate!.day,
                    )
                  : null,
              urgency: _urgency,
            ),
          );
      ref.invalidate(accessRequestsListProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.requestSubmitted(result.requestNumber)),
        ),
      );
      context.go('/requests/${result.id}');
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
    final catalogAsync = ref.watch(accessReferenceCatalogProvider);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final locale = Localizations.localeOf(context).toString();
    final dateFmt = DateFormat.yMMMd(locale);

    return ExpoAppScaffold(
      title: l10n.newAccessRequest,
      padding: EdgeInsets.zero,
      actions: [
        IconButton(
          tooltip: l10n.requests,
          onPressed: () => context.go('/requests'),
          icon: const Icon(Icons.close),
        ),
      ],
      body: catalogAsync.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorState(
          title: l10n.errorTitle,
          message: error is ApiError
              ? localizeApiError(l10n, error)
              : l10n.errorGeneric,
          onRetry: () => ref.invalidate(accessReferenceCatalogProvider),
        ),
        data: (catalog) {
          final systems = catalog.activeSystems;
          final roles = _systemId == null
              ? const <AccessReferenceSecurityRole>[]
              : catalog.rolesForSystem(_systemId!);

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text(
                  l10n.newAccessRequestSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
                DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: _systemId,
                  decoration: InputDecoration(labelText: l10n.system),
                  items: [
                    for (final system in systems)
                      DropdownMenuItem(
                        value: system.id,
                        child: Text(system.localizedName(arabic: isArabic)),
                      ),
                  ],
                  onChanged: _submitting
                      ? null
                      : (value) {
                          setState(() {
                            _systemId = value;
                            _securityRoleId = null;
                          });
                        },
                  validator: (value) =>
                      value == null ? l10n.validationRequired : null,
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  // ignore: deprecated_member_use
                  value: _securityRoleId,
                  decoration: InputDecoration(labelText: l10n.securityRole),
                  items: [
                    for (final role in roles)
                      DropdownMenuItem(
                        value: role.id,
                        child: Text(
                          '${role.localizedName(arabic: isArabic)}'
                          '${role.riskLevel != null ? ' (${role.riskLevel})' : ''}',
                        ),
                      ),
                  ],
                  onChanged: _submitting || _systemId == null
                      ? null
                      : (value) => setState(() => _securityRoleId = value),
                  validator: (value) =>
                      value == null ? l10n.validationRequired : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _justification,
                  enabled: !_submitting,
                  maxLines: 4,
                  maxLength: maxJustificationLength,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: l10n.businessJustification,
                    alignLabelWithHint: true,
                    helperText: l10n.justificationHelper(minJustificationLength),
                  ),
                  validator: (value) {
                    final v = value?.trim() ?? '';
                    if (v.isEmpty) return l10n.validationRequired;
                    if (v.length < minJustificationLength) {
                      return l10n.validationMinLength(minJustificationLength);
                    }
                    if (v.length > maxJustificationLength) {
                      return l10n.validationMaxLength(maxJustificationLength);
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                Text(l10n.duration, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<AccessDuration>(
                  segments: [
                    ButtonSegment(
                      value: AccessDuration.temporary,
                      label: Text(l10n.durationTemporary),
                      icon: const Icon(Icons.schedule),
                    ),
                    ButtonSegment(
                      value: AccessDuration.permanent,
                      label: Text(l10n.durationPermanent),
                      icon: const Icon(Icons.all_inclusive),
                    ),
                  ],
                  selected: {_duration},
                  onSelectionChanged: _submitting
                      ? null
                      : (values) {
                          setState(() {
                            _duration = values.first;
                            if (_duration == AccessDuration.permanent) {
                              _endDate = null;
                            }
                          });
                        },
                ),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.startDate),
                  subtitle: Text(dateFmt.format(_startDate)),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: _submitting ? null : () => _pickDate(end: false),
                ),
                if (_duration == AccessDuration.temporary)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.endDate),
                    subtitle: Text(
                      _endDate == null
                          ? l10n.selectDate
                          : dateFmt.format(_endDate!),
                    ),
                    trailing: const Icon(Icons.event_outlined),
                    onTap: _submitting ? null : () => _pickDate(end: true),
                  ),
                const SizedBox(height: AppSpacing.md),
                Text(l10n.urgency, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    for (final urgency in AccessUrgency.values)
                      ChoiceChip(
                        label: Text(_urgencyLabel(l10n, urgency)),
                        selected: _urgency == urgency,
                        onSelected: _submitting
                            ? null
                            : (_) => setState(() => _urgency = urgency),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                ExpoPrimaryButton(
                  label: l10n.submit,
                  loading: _submitting,
                  onPressed: _submitting || !_isValid ? null : _submit,
                  icon: Icons.send,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          );
        },
      ),
    );
  }

  String _urgencyLabel(AppLocalizations l10n, AccessUrgency urgency) {
    switch (urgency) {
      case AccessUrgency.normal:
        return l10n.urgencyNormal;
      case AccessUrgency.urgent:
        return l10n.urgencyUrgent;
      case AccessUrgency.critical:
        return l10n.urgencyCritical;
    }
  }
}
