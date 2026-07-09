import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../l10n/app_localizations.dart';
import '../shared/widgets/widgets.dart';

/// Profile/settings stub with language switcher (foundation).
class ProfilePlaceholderScreen extends ConsumerWidget {
  const ProfilePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ExpoAppScaffold(
      title: l10n.profile,
      body: ListView(
        children: [
          Text(
            l10n.language,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          const LanguageSwitcher(),
          const SizedBox(height: 24),
          ExpoSecondaryButton(
            label: l10n.logout,
            onPressed: () =>
                ref.read(sessionControllerProvider.notifier).signOut(),
          ),
        ],
      ),
    );
  }
}
