import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme_tokens.dart';
import '../../../../core/api/api_error.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/notification_models.dart';
import '../notifications_providers.dart';

/// Admin create-notification form (SYSTEM_ADMIN / SECURITY_ADMIN).
class CreateNotificationScreen extends ConsumerStatefulWidget {
  const CreateNotificationScreen({super.key});

  @override
  ConsumerState<CreateNotificationScreen> createState() =>
      _CreateNotificationScreenState();
}

class _CreateNotificationScreenState
    extends ConsumerState<CreateNotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleEn = TextEditingController();
  final _titleAr = TextEditingController();
  final _bodyEn = TextEditingController();
  final _bodyAr = TextEditingController();

  AppNotificationPriority _priority = AppNotificationPriority.normal;
  AppAudienceType _audienceType = AppAudienceType.all;
  final Set<String> _departmentCodes = {};
  final Set<String> _roles = {};
  final Set<String> _userIds = {};
  bool _publishNow = true;
  DateTime? _publishAt;
  DateTime? _expiresAt;
  bool _submitting = false;

  @override
  void dispose() {
    _titleEn.dispose();
    _titleAr.dispose();
    _bodyEn.dispose();
    _bodyAr.dispose();
    super.dispose();
  }

  Map<String, dynamic> _audienceFilter() {
    switch (_audienceType) {
      case AppAudienceType.all:
        return {'all': true};
      case AppAudienceType.department:
        return {'departmentCodes': _departmentCodes.toList()..sort()};
      case AppAudienceType.role:
        return {'roles': _roles.toList()..sort()};
      case AppAudienceType.users:
        return {'userIds': _userIds.toList()..sort()};
    }
  }

  String? _validateRequired(String? value, {int min = 3, int max = 120}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return AppLocalizations.of(context).validationRequired;
    if (v.length < min) {
      return AppLocalizations.of(context).validationMinLength(min);
    }
    if (v.length > max) {
      return AppLocalizations.of(context).validationMaxLength(max);
    }
    return null;
  }

  Future<void> _pickDate({required bool publish}) async {
    final now = DateTime.now();
    final initial = publish
        ? (_publishAt ?? now.add(const Duration(hours: 1)))
        : (_expiresAt ?? now.add(const Duration(days: 7)));
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted) return;
    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      if (publish) {
        _publishAt = selected;
      } else {
        _expiresAt = selected;
      }
    });
  }

  Future<bool> _confirmCriticalIfNeeded() async {
    if (_priority != AppNotificationPriority.critical) return true;
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.criticalConfirmTitle),
        content: Text(l10n.criticalConfirmMessage),
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
    return result == true;
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;

    if (_audienceType == AppAudienceType.department &&
        _departmentCodes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.validationAudienceRequired)),
      );
      return;
    }
    if (_audienceType == AppAudienceType.role && _roles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.validationAudienceRequired)),
      );
      return;
    }
    if (_audienceType == AppAudienceType.users && _userIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.validationAudienceRequired)),
      );
      return;
    }
    if (!_publishNow && _publishAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.validationPublishAtRequired)),
      );
      return;
    }

    final confirmed = await _confirmCriticalIfNeeded();
    if (!confirmed || !mounted) return;

    setState(() => _submitting = true);
    try {
      final request = CreateNotificationRequest(
        titleEn: _titleEn.text.trim(),
        titleAr: _titleAr.text.trim().isEmpty ? null : _titleAr.text.trim(),
        bodyEn: _bodyEn.text.trim(),
        bodyAr: _bodyAr.text.trim().isEmpty ? null : _bodyAr.text.trim(),
        priority: _priority,
        audienceType: _audienceType,
        audienceFilter: _audienceFilter(),
        publishNow: _publishNow,
        publishAt: _publishNow ? null : _publishAt,
        expiresAt: _expiresAt,
      );
      final result =
          await ref.read(notificationsRepositoryProvider).create(request);
      ref.invalidate(notificationsListProvider);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.notificationCreatedTitle),
          content: Text(
            l10n.notificationCreatedMessage(result.recipientCount),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.confirm),
            ),
          ],
        ),
      );
      if (!mounted) return;
      context.go('/notifications/${result.id}');
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
    final catalogAsync = ref.watch(referenceCatalogProvider);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return ExpoAppScaffold(
      title: l10n.createNotification,
      padding: EdgeInsets.zero,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Text(
              l10n.createNotificationSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _titleEn,
              decoration: InputDecoration(labelText: l10n.titleEn),
              validator: (v) => _validateRequired(v, min: 3, max: 120),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _titleAr,
              decoration: InputDecoration(labelText: l10n.titleArOptional),
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty) return null;
                return _validateRequired(t, min: 3, max: 120);
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _bodyEn,
              decoration: InputDecoration(labelText: l10n.bodyEn),
              minLines: 3,
              maxLines: 6,
              validator: (v) => _validateRequired(v, min: 3, max: 2000),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _bodyAr,
              decoration: InputDecoration(labelText: l10n.bodyArOptional),
              minLines: 3,
              maxLines: 6,
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty) return null;
                return _validateRequired(t, min: 3, max: 2000);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.priority, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              children: [
                for (final p in AppNotificationPriority.values)
                  ChoiceChip(
                    label: Text(_priorityLabel(l10n, p)),
                    selected: _priority == p,
                    onSelected: (_) => setState(() => _priority = p),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.audienceType, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<AppAudienceType>(
              key: ValueKey(_audienceType),
              initialValue: _audienceType,
              decoration: InputDecoration(labelText: l10n.audienceType),
              items: [
                for (final type in AppAudienceType.values)
                  DropdownMenuItem(
                    value: type,
                    child: Text(_audienceLabel(l10n, type)),
                  ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _audienceType = value);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            if (_audienceType == AppAudienceType.users)
              _buildUserPicker(context, l10n, isArabic)
            else
              catalogAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              error: (error, _) => Text(
                error is ApiError
                    ? localizeApiError(l10n, error)
                    : l10n.errorGeneric,
              ),
              data: (catalog) {
                if (_audienceType == AppAudienceType.department) {
                  return Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final dept in catalog.departments)
                        FilterChip(
                          label: Text(dept.localizedName(arabic: isArabic)),
                          selected: _departmentCodes.contains(dept.code),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _departmentCodes.add(dept.code);
                              } else {
                                _departmentCodes.remove(dept.code);
                              }
                            });
                          },
                        ),
                    ],
                  );
                }
                if (_audienceType == AppAudienceType.role) {
                  return Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final role in catalog.roles)
                        FilterChip(
                          label: Text(role),
                          selected: _roles.contains(role),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _roles.add(role);
                              } else {
                                _roles.remove(role);
                              }
                            });
                          },
                        ),
                    ],
                  );
                }
                return Text(
                  l10n.audienceAllHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.publishNow),
              subtitle: Text(
                _publishNow ? l10n.publishNowHint : l10n.schedulePublishHint,
              ),
              value: _publishNow,
              onChanged: (value) => setState(() => _publishNow = value),
            ),
            if (!_publishNow) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.publishAt),
                subtitle: Text(
                  _publishAt?.toLocal().toString() ?? l10n.selectDateTime,
                ),
                trailing: const Icon(Icons.schedule),
                onTap: () => _pickDate(publish: true),
              ),
            ],
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.expiresAtOptional),
              subtitle: Text(
                _expiresAt?.toLocal().toString() ?? l10n.selectDateTime,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_expiresAt != null)
                    IconButton(
                      tooltip: l10n.cancel,
                      onPressed: () => setState(() => _expiresAt = null),
                      icon: const Icon(Icons.clear),
                    ),
                  const Icon(Icons.event),
                ],
              ),
              onTap: () => _pickDate(publish: false),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.preview, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            ExpoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _titleEn.text.trim().isEmpty
                              ? l10n.titleEn
                              : _titleEn.text.trim(),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      PriorityChip(
                        priority: NotificationPriority.tryParse(
                              _priority.apiValue,
                            ) ??
                            NotificationPriority.normal,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _bodyEn.text.trim().isEmpty
                        ? l10n.bodyEn
                        : _bodyEn.text.trim(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: ExpoSecondaryButton(
                    label: l10n.cancel,
                    onPressed: _submitting
                        ? null
                        : () => context.go('/notifications'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: KeyedSubtree(
                    key: const Key('publishNotificationButton'),
                    child: ExpoPrimaryButton(
                      label: l10n.publish,
                      loading: _submitting,
                      onPressed: _submit,
                      icon: Icons.send,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
          ),
        ),
      ),
    );
  }

  /// Searchable active-user picker for the USERS audience (doc 19).
  Widget _buildUserPicker(
    BuildContext context,
    AppLocalizations l10n,
    bool isArabic,
  ) {
    final usersAsync = ref.watch(audienceUsersProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const Key('audienceUserSearchField'),
          decoration: InputDecoration(
            labelText: l10n.searchUsers,
            prefixIcon: const Icon(Icons.search),
          ),
          onChanged: (value) =>
              ref.read(audienceUserSearchProvider.notifier).state = value,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.selectedUsersCount(_userIds.length),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        usersAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (error, _) => Text(
            error is ApiError ? localizeApiError(l10n, error) : l10n.errorGeneric,
          ),
          data: (result) {
            if (result.items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Text(
                  l10n.noUsersFound,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }
            return Column(
              children: [
                for (final user in result.items)
                  CheckboxListTile(
                    key: Key('audienceUser-${user.id}'),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(user.localizedName(arabic: isArabic)),
                    subtitle: Text(user.email),
                    value: _userIds.contains(user.id),
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          _userIds.add(user.id);
                        } else {
                          _userIds.remove(user.id);
                        }
                      });
                    },
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  String _priorityLabel(AppLocalizations l10n, AppNotificationPriority p) {
    switch (p) {
      case AppNotificationPriority.low:
        return l10n.priorityLow;
      case AppNotificationPriority.normal:
        return l10n.priorityNormal;
      case AppNotificationPriority.high:
        return l10n.priorityHigh;
      case AppNotificationPriority.critical:
        return l10n.priorityCritical;
    }
  }

  String _audienceLabel(AppLocalizations l10n, AppAudienceType type) {
    switch (type) {
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
