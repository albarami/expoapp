import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../l10n/app_localizations.dart';
import '../shared/widgets/widgets.dart';

/// Profile screen with language switcher and logout.
class ProfilePlaceholderScreen extends ConsumerWidget {
  const ProfilePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionControllerProvider);
    final user = session.user;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final displayName = user?.localizedName(arabic: isArabic) ?? '';

    return ExpoAppScaffold(
      title: l10n.profile,
      body: ListView(
        children: [
          if (user != null) ...[
            Text(
              l10n.signedInAs(displayName),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
          ],
          Text(
            l10n.language,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          const LanguageSwitcher(),
          const SizedBox(height: 24),
          ExpoSecondaryButton(
            label: l10n.logout,
            loading: session.isAuthenticating,
            onPressed: () =>
                ref.read(sessionControllerProvider.notifier).signOut(),
          ),
        ],
      ),
    );
  }
}
