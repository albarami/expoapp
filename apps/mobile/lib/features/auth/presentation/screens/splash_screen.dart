import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme_tokens.dart';
import '../../../../core/providers.dart';
import '../../../../l10n/app_localizations.dart';

/// Cold-start splash while session restore (`/auth/me`) completes.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final config = ref.watch(appConfigProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.appName,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const CircularProgressIndicator(),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.sessionRestoring,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (config.isLocal) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  config.appEnv,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
