import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme_tokens.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/widgets.dart';

/// Settings screen (doc 20 screen 14): language selector, app version, and
/// API environment in debug builds. Theme mode is a documented future item.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final config = ref.watch(appConfigProvider);
    final theme = Theme.of(context);

    return ExpoAppScaffold(
      title: l10n.settings,
      body: ListView(
        children: [
          Text(
            l10n.language,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          const LanguageSwitcher(),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.about,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          ExpoCard(
            child: Column(
              children: [
                _SettingsField(
                  icon: Icons.info_outline,
                  label: l10n.appVersion,
                  value: AppConstants.appVersion,
                ),
                if (kDebugMode) ...[
                  const Divider(),
                  _SettingsField(
                    icon: Icons.cloud_outlined,
                    label: l10n.apiEnvironment,
                    value: config.appEnv,
                  ),
                  const Divider(),
                  _SettingsField(
                    icon: Icons.link_outlined,
                    label: l10n.apiBaseUrl,
                    value: config.apiBaseUrl,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsField extends StatelessWidget {
  const _SettingsField({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
