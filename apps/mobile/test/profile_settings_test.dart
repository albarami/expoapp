import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expoapp_mobile/app/app.dart';
import 'package:expoapp_mobile/app/theme.dart';
import 'package:expoapp_mobile/core/auth/app_user.dart';
import 'package:expoapp_mobile/core/auth/token_storage.dart';
import 'package:expoapp_mobile/core/constants/app_constants.dart';
import 'package:expoapp_mobile/core/providers.dart';
import 'package:expoapp_mobile/features/auth/data/auth_repository.dart';
import 'package:expoapp_mobile/features/dashboard/data/dashboard_repository.dart';
import 'package:expoapp_mobile/features/dashboard/domain/dashboard_summary.dart';
import 'package:expoapp_mobile/features/dashboard/presentation/dashboard_providers.dart';
import 'package:expoapp_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:expoapp_mobile/features/settings/presentation/screens/settings_screen.dart';
import 'package:expoapp_mobile/l10n/app_localizations.dart';
import 'package:expoapp_mobile/shared/widgets/language_switcher.dart';

const _employee = AppUser(
  id: 'u-emp',
  email: 'noura.alharbi@expo.sa',
  displayName: 'Noura Alharbi',
  displayNameAr: 'نورة الحربي',
  role: AppRole.employee,
  employeeNumber: 'E1001',
  departmentId: 'd1',
  departmentNameEn: 'Operations',
  departmentNameAr: 'العمليات',
);

const _userWithoutHrData = AppUser(
  id: 'u-min',
  email: 'minimal@expo.sa',
  displayName: 'Minimal User',
  role: AppRole.employee,
);

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this.user);

  final AppUser user;
  int logoutCalls = 0;

  @override
  Future<AppUser> fetchCurrentUser() async => user;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    return AuthSession(
      accessToken: 'access',
      refreshToken: 'refresh',
      user: user,
    );
  }

  @override
  Future<void> logout() async {
    logoutCalls++;
  }
}

class _FakeDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardSummary> fetchSummary() async {
    return DashboardSummary(
      role: AppRole.employee,
      unreadNotifications: 0,
      openAccessRequests: 0,
      completedRequests: 0,
      pendingApprovals: 0,
      latestNotifications: const [],
      latestRequests: const [],
    );
  }
}

Future<Widget> _screenHarness({
  required AppUser user,
  required Widget home,
  _FakeAuthRepository? auth,
}) async {
  final storage = InMemoryTokenStorage();
  await storage.writeTokens(accessToken: 'tok', refreshToken: 'ref');
  return ProviderScope(
    overrides: [
      tokenStorageProvider.overrideWithValue(storage),
      authRepositoryProvider.overrideWithValue(
        auth ?? _FakeAuthRepository(user),
      ),
    ],
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light(),
      home: home,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ProfileScreen', () {
    testWidgets('shows role, department, and employee number (happy path)',
        (tester) async {
      await tester.pumpWidget(
        await _screenHarness(user: _employee, home: const ProfileScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Signed in as Noura Alharbi'), findsOneWidget);
      expect(find.text('noura.alharbi@expo.sa'), findsOneWidget);
      expect(find.text('Role'), findsOneWidget);
      expect(find.text('Employee'), findsOneWidget);
      expect(find.text('Department'), findsOneWidget);
      expect(find.text('Operations'), findsOneWidget);
      expect(find.text('Employee number'), findsOneWidget);
      expect(find.text('E1001'), findsOneWidget);
      expect(find.byType(LanguageSwitcher), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
      expect(find.byKey(const Key('openSettingsButton')), findsOneWidget);
    });

    testWidgets('falls back when HR fields are missing (edge)', (tester) async {
      await tester.pumpWidget(
        await _screenHarness(
          user: _userWithoutHrData,
          home: const ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Not available'), findsNWidgets(2));
    });

    testWidgets('logout calls the auth repository (failure-path guard)',
        (tester) async {
      final auth = _FakeAuthRepository(_employee);
      await tester.pumpWidget(
        await _screenHarness(
          user: _employee,
          home: const ProfileScreen(),
          auth: auth,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(auth.logoutCalls, 1);
    });
  });

  group('SettingsScreen', () {
    testWidgets('shows language switcher, version, and API environment',
        (tester) async {
      await tester.pumpWidget(
        await _screenHarness(user: _employee, home: const SettingsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.byType(LanguageSwitcher), findsOneWidget);
      expect(find.text('App version'), findsOneWidget);
      expect(find.text(AppConstants.appVersion), findsOneWidget);
      // flutter test runs in debug mode, so debug-only rows are visible.
      expect(find.text('API environment'), findsOneWidget);
      expect(find.text('API base URL'), findsOneWidget);
    });
  });

  group('Profile → Settings navigation', () {
    testWidgets('gear icon routes to /settings', (tester) async {
      final storage = InMemoryTokenStorage();
      await storage.writeTokens(accessToken: 'tok', refreshToken: 'ref');
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tokenStorageProvider.overrideWithValue(storage),
            authRepositoryProvider
                .overrideWithValue(_FakeAuthRepository(_employee)),
            dashboardRepositoryProvider
                .overrideWithValue(_FakeDashboardRepository()),
          ],
          child: const ExpoApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);

      await tester.tap(find.byKey(const Key('openSettingsButton')));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
    });
  });
}
