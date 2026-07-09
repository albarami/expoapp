import '../../../core/auth/app_user.dart';

/// Seeded Phase 1 demo accounts (`09_SEED_DATA.md` / `Password123!`).
class DemoAccount {
  const DemoAccount({
    required this.email,
    required this.password,
    required this.role,
    required this.labelKey,
  });

  final String email;
  final String password;
  final AppRole role;

  /// Localization key selector handled by the login UI.
  final DemoAccountLabel labelKey;
}

enum DemoAccountLabel {
  employee,
  manager,
  securityAdmin,
  systemAdmin,
}

/// Demo password shared by all seeded users (documented in README / env setup).
const kDemoPassword = 'Password123!';

const kDemoAccounts = <DemoAccount>[
  DemoAccount(
    email: 'noura.alharbi@expo.sa',
    password: kDemoPassword,
    role: AppRole.employee,
    labelKey: DemoAccountLabel.employee,
  ),
  DemoAccount(
    email: 'faisal.otaibi@expo.sa',
    password: kDemoPassword,
    role: AppRole.manager,
    labelKey: DemoAccountLabel.manager,
  ),
  DemoAccount(
    email: 'reem.security@expo.sa',
    password: kDemoPassword,
    role: AppRole.securityAdmin,
    labelKey: DemoAccountLabel.securityAdmin,
  ),
  DemoAccount(
    email: 'admin@expo.sa',
    password: kDemoPassword,
    role: AppRole.systemAdmin,
    labelKey: DemoAccountLabel.systemAdmin,
  ),
];
