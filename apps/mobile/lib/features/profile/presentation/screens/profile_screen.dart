import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme_tokens.dart';
import '../../../../core/providers.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/widgets.dart';

/// Profile screen (doc 20 screen 13): identity, role, department, employee
/// number, language setting, and logout.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionControllerProvider);
    final user = session.user;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return ExpoAppScaffold(
      title: l10n.profile,
      actions: [
        IconButton(
          key: const Key('openSettingsButton'),
          tooltip: l10n.settings,
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => context.go('/settings'),
        ),
      ],
      body: ListView(
        children: [
          if (user != null) ...[
            Text(
              l10n.signedInAs(user.localizedName(arabic: isArabic)),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ExpoCard(
              child: Column(
                children: [
                  _ProfileField(
                    icon: Icons.badge_outlined,
                    label: l10n.role,
                    value: _roleLabel(l10n, user.role.apiValue),
                  ),
                  const Divider(),
                  _ProfileField(
                    icon: Icons.apartment_outlined,
                    label: l10n.department,
                    value: user.localizedDepartment(arabic: isArabic) ??
                        l10n.notAvailable,
                  ),
                  const Divider(),
                  _ProfileField(
                    icon: Icons.numbers_outlined,
                    label: l10n.employeeNumber,
                    value: user.employeeNumber ?? l10n.notAvailable,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          Text(
            l10n.language,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          const LanguageSwitcher(),
          const SizedBox(height: AppSpacing.lg),
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

  String _roleLabel(AppLocalizations l10n, String apiRole) {
    switch (apiRole) {
      case 'MANAGER':
        return l10n.roleManager;
      case 'SECURITY_ADMIN':
        return l10n.roleSecurityAdmin;
      case 'SYSTEM_ADMIN':
        return l10n.roleSystemAdmin;
      default:
        return l10n.roleEmployee;
    }
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
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
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.end,
        ),
      ],
    );
  }
}
