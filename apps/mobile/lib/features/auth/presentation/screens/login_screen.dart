import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme_tokens.dart';
import '../../../../core/auth/session_controller.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/api/api_error.dart';
import '../../../../core/providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/demo_accounts.dart';

/// Login screen with email/password, language toggle, and demo quick buttons.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _formError;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _formError = null);

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final ok = await ref.read(sessionControllerProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;
    if (!ok) {
      final session = ref.read(sessionControllerProvider);
      final message = session.errorMessage;
      setState(() {
        _formError = message == null || message.isEmpty
            ? l10n.errorInvalidCredentials
            : (message.toLowerCase().contains('invalid')
                ? l10n.errorInvalidCredentials
                : message);
      });
    }
  }

  Future<void> _demoLogin(DemoAccount account) async {
    _emailController.text = account.email;
    _passwordController.text = account.password;
    await _submit();
  }

  String _demoLabel(AppLocalizations l10n, DemoAccountLabel key) {
    switch (key) {
      case DemoAccountLabel.employee:
        return l10n.demoEmployee;
      case DemoAccountLabel.manager:
        return l10n.demoManager;
      case DemoAccountLabel.securityAdmin:
        return l10n.demoSecurityAdmin;
      case DemoAccountLabel.systemAdmin:
        return l10n.demoSystemAdmin;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final config = ref.watch(appConfigProvider);
    final session = ref.watch(sessionControllerProvider);
    final authenticating = session.isAuthenticating;
    final expired = session.status == SessionStatus.expired;

    ref.listen<SessionState>(sessionControllerProvider, (previous, next) {
      if (next.status == SessionStatus.expired &&
          previous?.status != SessionStatus.expired) {
        setState(() => _formError = l10n.errorUnauthorized);
        ref.read(sessionControllerProvider.notifier).clearExpiredBanner();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: const LanguageSwitcher(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Semantics(
                      header: true,
                      child: Text(
                        l10n.appName,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
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
                    if (expired || _formError != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      _ErrorBanner(
                        message: _formError ?? l10n.errorUnauthorized,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    ExpoTextField(
                      label: l10n.email,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      enabled: !authenticating,
                      validator: (value) {
                        final trimmed = value?.trim() ?? '';
                        if (trimmed.isEmpty) {
                          return l10n.validationEmailRequired;
                        }
                        if (!_looksLikeEmail(trimmed)) {
                          return l10n.validationEmailInvalid;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ExpoTextField(
                      label: l10n.password,
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      enabled: !authenticating,
                      onFieldSubmitted: (_) {
                        if (!authenticating) {
                          _submit();
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.validationPasswordRequired;
                        }
                        return null;
                      },
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: authenticating
                            ? null
                            : () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                        child: Text(
                          _obscurePassword
                              ? l10n.showPassword
                              : l10n.hidePassword,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ExpoPrimaryButton(
                      label: l10n.login,
                      loading: authenticating,
                      onPressed: authenticating ? null : _submit,
                    ),
                    if (config.enableDemoLogin) ...[
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        l10n.demoQuickLogin,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          for (final account in kDemoAccounts)
                            _DemoLoginChip(
                              label: _demoLabel(l10n, account.labelKey),
                              enabled: !authenticating,
                              onPressed: () => _demoLogin(account),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

bool _looksLikeEmail(String value) {
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      liveRegion: true,
      child: Material(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: theme.colorScheme.onErrorContainer,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoLoginChip extends StatelessWidget {
  const _DemoLoginChip({
    required this.label,
    required this.onPressed,
    required this.enabled,
  });

  final String label;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: ActionChip(
        label: Text(label),
        onPressed: enabled ? onPressed : null,
        avatar: const Icon(Icons.person_outline, size: 18),
      ),
    );
  }
}

/// Maps login [ApiError] to a localized string (used by tests / callers).
String localizeLoginError(AppLocalizations l10n, ApiError error) {
  if (error.isUnauthorized) {
    return l10n.errorInvalidCredentials;
  }
  return localizeApiError(l10n, error);
}
