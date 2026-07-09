import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expoapp_mobile/app/app.dart';
import 'package:expoapp_mobile/app/router.dart';
import 'package:expoapp_mobile/core/api/api_client.dart';
import 'package:expoapp_mobile/core/api/api_error.dart';
import 'package:expoapp_mobile/core/auth/app_user.dart';
import 'package:expoapp_mobile/core/auth/session_controller.dart';
import 'package:expoapp_mobile/core/auth/token_storage.dart';
import 'package:expoapp_mobile/core/config/app_config.dart';
import 'package:expoapp_mobile/core/providers.dart';
import 'package:expoapp_mobile/features/auth/data/auth_repository.dart';
import 'package:expoapp_mobile/features/auth/domain/demo_accounts.dart';
import 'package:expoapp_mobile/features/dashboard/data/dashboard_repository.dart';
import 'package:expoapp_mobile/features/dashboard/domain/dashboard_summary.dart';
import 'package:expoapp_mobile/features/dashboard/presentation/dashboard_providers.dart';
import 'package:expoapp_mobile/l10n/app_localizations_en.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({
    this.loginResult,
    this.loginError,
    this.meResult,
    this.meError,
  });

  AuthSession? loginResult;
  ApiError? loginError;
  AppUser? meResult;
  ApiError? meError;

  int loginCalls = 0;
  int meCalls = 0;
  int logoutCalls = 0;
  String? lastEmail;
  String? lastPassword;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    loginCalls++;
    lastEmail = email;
    lastPassword = password;
    final error = loginError;
    if (error != null) throw error;
    final result = loginResult;
    if (result == null) {
      throw ApiError.unknown('No login result configured');
    }
    return result;
  }

  @override
  Future<AppUser> fetchCurrentUser() async {
    meCalls++;
    final error = meError;
    if (error != null) throw error;
    final result = meResult;
    if (result == null) {
      throw const ApiError(
        code: 'UNAUTHORIZED',
        message: 'Unauthorized',
        statusCode: 401,
      );
    }
    return result;
  }

  @override
  Future<void> logout() async {
    logoutCalls++;
  }
}

const _employee = AppUser(
  id: 'u-emp',
  email: 'noura.alharbi@expo.sa',
  displayName: 'Noura Alharbi',
  role: AppRole.employee,
  permissions: ['notifications:read', 'accessRequests:create'],
);

const _admin = AppUser(
  id: 'u-admin',
  email: 'admin@expo.sa',
  displayName: 'Expo System Admin',
  role: AppRole.systemAdmin,
  permissions: ['notifications:create', 'audit:read'],
);

class _StubDashboardRepository implements DashboardRepository {
  _StubDashboardRepository(this.role);

  final AppRole role;

  @override
  Future<DashboardSummary> fetchSummary() async {
    return DashboardSummary(
      role: role,
      unreadNotifications: 0,
      openAccessRequests: 0,
      completedRequests: 0,
      pendingApprovals: 0,
      latestNotifications: const [],
      latestRequests: const [],
      teamOpenRequests: role == AppRole.manager ? 0 : null,
      pendingSecurityApprovals:
          role == AppRole.securityAdmin ? 0 : null,
      highRiskOpenRequests: role == AppRole.securityAdmin ? 0 : null,
      recentAuditEvents: role == AppRole.securityAdmin ||
              role == AppRole.systemAdmin
          ? const []
          : null,
      notificationStats: role == AppRole.systemAdmin
          ? const DashboardNotificationStats(
              publishedCount: 0,
              recipientCount: 0,
              readCount: 0,
              readPercentage: 0,
            )
          : null,
      accessWorkflowStats: role == AppRole.systemAdmin
          ? const DashboardAccessWorkflowStats(
              openAccessRequests: 0,
              pendingManagerApprovals: 0,
              pendingSecurityApprovals: 0,
              completedRequests: 0,
            )
          : null,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SessionController', () {
    test('restore without token is unauthenticated', () async {
      final storage = InMemoryTokenStorage();
      final auth = _FakeAuthRepository();
      final controller = SessionController(
        tokenStorage: storage,
        authRepository: auth,
      );
      await controller.ready;
      expect(controller.state.status, SessionStatus.unauthenticated);
      expect(auth.meCalls, 0);
    });

    test('restore with valid token calls /auth/me', () async {
      final storage = InMemoryTokenStorage();
      await storage.writeTokens(accessToken: 'tok', refreshToken: 'ref');
      final auth = _FakeAuthRepository(meResult: _employee);
      final controller = SessionController(
        tokenStorage: storage,
        authRepository: auth,
      );
      await controller.ready;
      expect(controller.state.isAuthenticated, isTrue);
      expect(controller.state.user?.email, _employee.email);
      expect(auth.meCalls, 1);
    });

    test('restore with invalid token expires session', () async {
      final storage = InMemoryTokenStorage();
      await storage.writeTokens(accessToken: 'stale');
      final auth = _FakeAuthRepository(
        meError: const ApiError(
          code: 'UNAUTHORIZED',
          message: 'Unauthorized',
          statusCode: 401,
        ),
      );
      final controller = SessionController(
        tokenStorage: storage,
        authRepository: auth,
      );
      await controller.ready;
      expect(controller.state.status, SessionStatus.expired);
      expect(await storage.readAccessToken(), isNull);
    });

    test('login success persists tokens and user', () async {
      final storage = InMemoryTokenStorage();
      final auth = _FakeAuthRepository(
        loginResult: const AuthSession(
          accessToken: 'access',
          refreshToken: 'refresh',
          user: _employee,
        ),
      );
      final controller = SessionController(
        tokenStorage: storage,
        authRepository: auth,
      );
      await controller.ready;

      final ok = await controller.login(
        email: _employee.email,
        password: kDemoPassword,
      );

      expect(ok, isTrue);
      expect(controller.state.isAuthenticated, isTrue);
      expect(await storage.readAccessToken(), 'access');
      expect(await storage.readRefreshToken(), 'refresh');
      expect(auth.loginCalls, 1);
    });

    test('login failure stays unauthenticated with message', () async {
      final storage = InMemoryTokenStorage();
      final auth = _FakeAuthRepository(
        loginError: const ApiError(
          code: 'UNAUTHORIZED',
          message: 'Invalid email or password.',
          statusCode: 401,
        ),
      );
      final controller = SessionController(
        tokenStorage: storage,
        authRepository: auth,
      );
      await controller.ready;

      final ok = await controller.login(
        email: 'bad@expo.sa',
        password: 'wrong',
      );

      expect(ok, isFalse);
      expect(controller.state.status, SessionStatus.unauthenticated);
      expect(controller.state.errorMessage, contains('Invalid'));
    });

    test('signOut calls logout API and clears storage', () async {
      final storage = InMemoryTokenStorage();
      final auth = _FakeAuthRepository(
        loginResult: const AuthSession(
          accessToken: 'access',
          refreshToken: 'refresh',
          user: _employee,
        ),
      );
      final controller = SessionController(
        tokenStorage: storage,
        authRepository: auth,
      );
      await controller.ready;
      await controller.login(
        email: _employee.email,
        password: kDemoPassword,
      );

      await controller.signOut();

      expect(auth.logoutCalls, 1);
      expect(controller.state.status, SessionStatus.unauthenticated);
      expect(await storage.readAccessToken(), isNull);
    });
  });

  group('AppUser', () {
    test('parses login/me profile fields', () {
      final user = AppUser.fromJson({
        'id': '1',
        'email': 'admin@expo.sa',
        'fullNameEn': 'Expo System Admin',
        'fullNameAr': 'مدير النظام',
        'role': 'SYSTEM_ADMIN',
        'permissions': ['audit:read'],
        'department': {'id': 'd1', 'code': 'TECH', 'nameEn': 'Tech'},
      });

      expect(user.role, AppRole.systemAdmin);
      expect(user.displayName, 'Expo System Admin');
      expect(user.displayNameAr, 'مدير النظام');
      expect(user.departmentId, 'd1');
      expect(user.hasPermission('audit:read'), isTrue);
      expect(user.canViewAudit, isTrue);
    });
  });

  group('Role shell tabs', () {
    final l10n = AppLocalizationsEn();

    test('employee tabs exclude approvals and audit', () {
      final tabs = tabsForRole(AppRole.employee, l10n);
      final paths = tabs.map((t) => t.path).toList();
      expect(paths, contains('/'));
      expect(paths, contains('/notifications'));
      expect(paths, contains('/requests'));
      expect(paths, contains('/profile'));
      expect(paths, isNot(contains('/approvals')));
      expect(paths, isNot(contains('/audit')));
    });

    test('manager tabs include approvals', () {
      final paths = tabsForRole(AppRole.manager, l10n).map((t) => t.path);
      expect(paths, contains('/approvals'));
      expect(paths, isNot(contains('/audit')));
    });

    test('security admin tabs include audit', () {
      final paths =
          tabsForRole(AppRole.securityAdmin, l10n).map((t) => t.path);
      expect(paths, contains('/approvals'));
      expect(paths, contains('/audit'));
    });

    test('system admin tabs include create and audit', () {
      final paths = tabsForRole(AppRole.systemAdmin, l10n).map((t) => t.path);
      expect(paths, contains('/admin/notifications/create'));
      expect(paths, contains('/audit'));
      expect(paths, isNot(contains('/requests')));
    });
  });

  group('Demo accounts', () {
    test('covers four primary personas', () {
      expect(kDemoAccounts, hasLength(4));
      expect(
        kDemoAccounts.map((a) => a.role).toSet(),
        {
          AppRole.employee,
          AppRole.manager,
          AppRole.securityAdmin,
          AppRole.systemAdmin,
        },
      );
      expect(
        kDemoAccounts.every((a) => a.password == kDemoPassword),
        isTrue,
      );
    });
  });

  group('ApiClient 401', () {
    test('clears tokens and invokes unauthorized handler', () async {
      final storage = InMemoryTokenStorage();
      await storage.writeTokens(accessToken: 'tok');
      var unauthorized = false;

      final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));
      dio.httpClientAdapter = _UnauthorizedAdapter();

      final client = ApiClient(
        config: const AppConfig(
          appEnv: 'local',
          apiBaseUrl: 'http://localhost',
          defaultLocale: 'en',
          enableDemoLogin: true,
        ),
        tokenStorage: storage,
        onUnauthorized: () async {
          unauthorized = true;
        },
        dio: dio,
      );

      await expectLater(
        client.get<Map<String, dynamic>>('/secure'),
        throwsA(isA<ApiError>()),
      );
      expect(unauthorized, isTrue);
      expect(await storage.readAccessToken(), isNull);
    });
  });

  group('Login UI', () {
    testWidgets('shows demo quick login chips when enabled', (tester) async {
      final auth = _FakeAuthRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tokenStorageProvider.overrideWithValue(InMemoryTokenStorage()),
            authRepositoryProvider.overrideWithValue(auth),
            appConfigProvider.overrideWithValue(
              const AppConfig(
                appEnv: 'local',
                apiBaseUrl: 'http://localhost:3000/api/v1',
                defaultLocale: 'en',
                enableDemoLogin: true,
              ),
            ),
          ],
          child: const ExpoApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Quick demo login'), findsOneWidget);
      expect(find.text('Employee'), findsOneWidget);
      expect(find.text('Manager'), findsOneWidget);
      expect(find.text('Security Admin'), findsOneWidget);
      expect(find.text('System Admin'), findsOneWidget);
    });

    testWidgets('validates empty email/password', (tester) async {
      final auth = _FakeAuthRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tokenStorageProvider.overrideWithValue(InMemoryTokenStorage()),
            authRepositoryProvider.overrideWithValue(auth),
          ],
          child: const ExpoApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Email is required.'), findsOneWidget);
      expect(find.text('Password is required.'), findsOneWidget);
      expect(auth.loginCalls, 0);
    });

    testWidgets('demo chip logs in and reaches dashboard', (tester) async {
      final auth = _FakeAuthRepository(
        loginResult: const AuthSession(
          accessToken: 'access',
          refreshToken: 'refresh',
          user: _admin,
        ),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tokenStorageProvider.overrideWithValue(InMemoryTokenStorage()),
            authRepositoryProvider.overrideWithValue(auth),
            dashboardRepositoryProvider.overrideWithValue(
              _StubDashboardRepository(AppRole.systemAdmin),
            ),
          ],
          child: const ExpoApp(),
        ),
      );
      await tester.pumpAndSettle();

      final adminChip = find.text('System Admin');
      await tester.ensureVisible(adminChip);
      await tester.pumpAndSettle();
      await tester.tap(adminChip);
      await tester.pumpAndSettle();

      expect(auth.loginCalls, 1);
      expect(auth.lastEmail, 'admin@expo.sa');
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Create'), findsOneWidget);
      expect(find.text('Audit Logs'), findsOneWidget);
    });

    testWidgets('authenticated session redirects away from login',
        (tester) async {
      final storage = InMemoryTokenStorage();
      await storage.writeTokens(accessToken: 'tok');
      final auth = _FakeAuthRepository(meResult: _employee);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tokenStorageProvider.overrideWithValue(storage),
            authRepositoryProvider.overrideWithValue(auth),
            dashboardRepositoryProvider.overrideWithValue(
              _StubDashboardRepository(AppRole.employee),
            ),
          ],
          child: const ExpoApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Login'), findsNothing);
      expect(find.text('Approvals'), findsNothing);
    });
  });
}

class _UnauthorizedAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{"error":{"code":"UNAUTHORIZED","message":"Unauthorized"}}',
      401,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}
