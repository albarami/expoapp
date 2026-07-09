import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import 'app_scaffold.dart';

/// EN/AR language switcher for settings/profile.
class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current = Localizations.localeOf(context);

    return SegmentedButton<String>(
      segments: [
        ButtonSegment(value: 'en', label: Text(l10n.english)),
        ButtonSegment(value: 'ar', label: Text(l10n.arabic)),
      ],
      selected: {current.languageCode},
      onSelectionChanged: (selection) {
        final code = selection.first;
        ref.read(localeControllerProvider.notifier).setLocale(Locale(code));
      },
    );
  }
}

/// Bottom sheet for approve/reject confirmations.
Future<bool?> showConfirmDecisionSheet({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  bool isDestructive = false,
}) {
  final l10n = AppLocalizations.of(context);
  return showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 24),
              ExpoPrimaryButton(
                label: confirmLabel,
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: 8),
              ExpoSecondaryButton(
                label: l10n.cancel,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      );
    },
  );
}
