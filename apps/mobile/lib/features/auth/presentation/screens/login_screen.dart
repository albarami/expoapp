import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme_tokens.dart';
import '../../../../core/providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/widgets.dart';

/// Login shell for T-MOB-01. Full demo-user auth lands in T-MOB-02.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final config = ref.watch(appConfigProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.appName,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.demoLoginHint,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  ExpoTextField(
                    label: l10n.email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    enabled: false,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ExpoTextField(
                    label: l10n.password,
                    obscureText: true,
                    enabled: false,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ExpoPrimaryButton(
                    label: l10n.login,
                    onPressed: null,
                  ),
                  if (config.enableDemoLogin) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.comingSoon,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelLarge,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
