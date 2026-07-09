import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expoapp_mobile/app/app.dart';
import 'package:expoapp_mobile/core/api/api_error.dart';
import 'package:expoapp_mobile/core/auth/app_user.dart';
import 'package:expoapp_mobile/core/auth/token_storage.dart';
import 'package:expoapp_mobile/core/providers.dart';
import 'package:expoapp_mobile/features/auth/data/auth_repository.dart';
import 'package:expoapp_mobile/features/dashboard/data/dashboard_repository.dart';
import 'package:expoapp_mobile/features/dashboard/domain/dashboard_summary.dart';
import 'package:expoapp_mobile/features/dashboard/presentation/dashboard_providers.dart';
import 'package:expoapp_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:expoapp_mobile/l10n/app_localizations.dart';
import 'package:expoapp_mobile/app/theme.dart';

const _employee = AppUser(
  id: 'u-emp',
  email: 'noura.alharbi@expo.sa',
  displayName: 'Noura Alharbi',
  role: AppRole.employee,
);

const _manager = AppUser(
  id: 'u-mgr',
  email: 'manager@expo.sa',
  displayName: 'Sara Manager',
  role: AppRole.manager,
);

const _security = AppUser(
  id: 'u-sec',
  email: 'security@expo.sa',
  displayName: 'Omar Security',
  role: AppRole.securityAdmin,
);

const _admin = AppUser(
  id: 'u-admin',
  email: 'admin@expo.sa',
  displayName: 'Expo System Admin',
  role: AppRole.systemAdmin,
);

DashboardSummary _employeeSummary({
  int unread = 2,
  List<DashboardNotificationItem> notifications = const [],
  List<DashboardRequestItem> requests = const [],
}) {
  return DashboardSummary(
    role: AppRole.employee,
    unreadNotifications: unread,
    openAccessRequests: 1,
    completedRequests: 3,
    pendingApprovals: 0,
    latestNotifications: notifications,
    latestRequests: requests,
  );
}

DashboardSummary _managerSummary() {
  return const DashboardSummary(
    role: AppRole.manager,
    unreadNotifications: 1,
    openAccessRequests: 0,
    completedRequests: 2,
    pendingApprovals: 4,
    latestNotifications: [],
    latestRequests: [],
    teamOpenRequests: 5,
  );
}

DashboardSummary _securitySummary() {
  return DashboardSummary(
    role: AppRole.securityAdmin,
    unreadNotifications: 0,
    openAccessRequests: 0,
    completedRequests: 0,
    pendingApprovals: 2,
    latestNotifications: const [],
    latestRequests: const [],
    pendingSecurityApprovals: 3,
    highRiskOpenRequests: 1,
    recentAuditEvents: [
      DashboardAuditItem(
        id: 'a1',
        action: 'ACCESS_REQUEST_APPROVED',
        entityType: 'AccessRequest',
        entityId: 'req-1',
        actorEmail: 'security@expo.sa',
        createdAt: DateTime.utc(2026, 7, 1, 10),
      ),
    ],
  );
}

DashboardSummary _adminSummary() {
  return const DashboardSummary(
    role: AppRole.systemAdmin,
    unreadNotifications: 0,
    openAccessRequests: 0,
    completedRequests: 0,
    pendingApprovals: 0,
    latestNotifications: [],
    latestRequests: [],
    notificationStats: DashboardNotificationStats(
      publishedCount: 12,
      recipientCount: 100,
      readCount: 80,
      readPercentage: 80,
    ),
    accessWorkflowStats: DashboardAccessWorkflowStats(
      openAccessRequests: 7,
      pendingManagerApprovals: 2,
      pendingSecurityApprovals: 3,
      completedRequests: 40,
    ),
    recentAuditEvents: [],
  );
}

class _FakeDashboardRepository implements DashboardRepository {
  _FakeDashboardRepository(this.summary, {this.error});

  DashboardSummary? summary;
  ApiError? error;
  int fetchCalls = 0;

  @override
  Future<DashboardSummary> fetchSummary() async {
    fetchCalls++;
    final err = error;
    if (err != null) throw err;
    final data = summary;
    if (data == null) {
      throw ApiError.unknown('No summary configured');
    }
    return data;
  }
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this.user);

  final AppUser user;

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
  Future<void> logout() async {}
}

Future<Widget> _dashboardHarness({
  required AppUser user,
  required DashboardRepository dashboard,
}) async {
  final storage = InMemoryTokenStorage();
  await storage.writeTokens(accessToken: 'tok', refreshToken: 'ref');
  return ProviderScope(
    overrides: [
      tokenStorageProvider.overrideWithValue(storage),
      authRepositoryProvider.overrideWithValue(_FakeAuthRepository(user)),
      dashboardRepositoryProvider.overrideWithValue(dashboard),
    ],
    child: const ExpoApp(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DashboardSummary.fromJson', () {
    test('parses employee core fields', () {
      final summary = DashboardSummary.fromJson({
        'role': 'EMPLOYEE',
        'unreadNotifications': 2,
        'openAccessRequests': 1,
        'completedRequests': 3,
        'pendingApprovals': 0,
        'latestNotifications': [
          {
            'id': 'n1',
            'titleEn': 'Welcome',
            'titleAr': 'مرحبا',
            'priority': 'HIGH',
            'status': 'PUBLISHED',
            'readAt': null,
            'createdAt': '2026-07-01T10:00:00.000Z',
          },
        ],
        'latestRequests': [
          {
            'id': 'r1',
            'requestNumber': 'AR-0001',
            'status': 'MANAGER_PENDING',
            'urgency': 'NORMAL',
            'systemCode': 'ERP',
            'systemNameEn': 'ERP',
            'securityRoleCode': 'VIEWER',
            'securityRoleNameEn': 'Viewer',
            'submittedAt': '2026-07-01T09:00:00.000Z',
            'createdAt': '2026-07-01T08:00:00.000Z',
          },
        ],
      });

      expect(summary.role, AppRole.employee);
      expect(summary.unreadNotifications, 2);
      expect(summary.latestNotifications, hasLength(1));
      expect(summary.latestNotifications.first.isUnread, isTrue);
      expect(
        summary.latestNotifications.first.localizedTitle(arabic: true),
        'مرحبا',
      );
      expect(summary.latestRequests.first.requestNumber, 'AR-0001');
    });

    test('parses system admin optional stats', () {
      final summary = DashboardSummary.fromJson({
        'role': 'SYSTEM_ADMIN',
        'unreadNotifications': 0,
        'openAccessRequests': 0,
        'completedRequests': 0,
        'pendingApprovals': 0,
        'latestNotifications': [],
        'latestRequests': [],
        'notificationStats': {
          'publishedCount': 12,
          'recipientCount': 100,
          'readCount': 80,
          'readPercentage': 80,
        },
        'accessWorkflowStats': {
          'openAccessRequests': 7,
          'pendingManagerApprovals': 2,
          'pendingSecurityApprovals': 3,
          'completedRequests': 40,
        },
        'recentAuditEvents': [
          {
            'id': 'a1',
            'action': 'LOGIN',
            'entityType': 'User',
            'entityId': null,
            'actorEmail': 'admin@expo.sa',
            'createdAt': '2026-07-01T10:00:00.000Z',
          },
        ],
      });

      expect(summary.notificationStats?.readPercentage, 80);
      expect(summary.accessWorkflowStats?.openAccessRequests, 7);
      expect(summary.recentAuditEvents, hasLength(1));
    });
  });

  group('DashboardScreen roles', () {
    testWidgets('employee sees unread/open metrics and new request action',
        (tester) async {
      final dashboard = _FakeDashboardRepository(
        _employeeSummary(
          notifications: [
            DashboardNotificationItem(
              id: 'n1',
              titleEn: 'Policy update',
              priority: 'NORMAL',
              status: 'PUBLISHED',
              createdAt: DateTime.utc(2026, 7, 1),
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        await _dashboardHarness(user: _employee, dashboard: dashboard),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Unread notifications'), findsOneWidget);
      expect(find.text('Open access requests'), findsOneWidget);
      expect(find.text('2'), findsWidgets);
      expect(find.text('New Access Request'), findsOneWidget);
      expect(find.text('Policy update'), findsOneWidget);
      expect(find.text('Latest notifications'), findsOneWidget);
      expect(dashboard.fetchCalls, greaterThan(0));
    });

    testWidgets('manager sees pending approvals and team open requests',
        (tester) async {
      final dashboard = _FakeDashboardRepository(_managerSummary());
      await tester.pumpWidget(
        await _dashboardHarness(user: _manager, dashboard: dashboard),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pending approvals'), findsOneWidget);
      expect(find.text('Team open requests'), findsOneWidget);
      expect(find.text('4'), findsWidgets);
      expect(find.text('5'), findsWidgets);
      expect(find.text('New Access Request'), findsOneWidget);
    });

    testWidgets('security admin sees high-risk and audit section',
        (tester) async {
      final dashboard = _FakeDashboardRepository(_securitySummary());
      await tester.pumpWidget(
        await _dashboardHarness(user: _security, dashboard: dashboard),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pending security approvals'), findsOneWidget);
      expect(find.text('High-risk open requests'), findsOneWidget);
      expect(find.text('Recent audit events'), findsOneWidget);
      expect(find.text('ACCESS_REQUEST_APPROVED'), findsOneWidget);
      expect(find.text('Create Notification'), findsNothing);
    });

    testWidgets('system admin sees stats and create notification',
        (tester) async {
      final dashboard = _FakeDashboardRepository(_adminSummary());
      // Direct screen harness avoids shell bottom-nav height clipping in tests.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardRepositoryProvider.overrideWithValue(dashboard),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const DashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Published notifications'), findsWidgets);
      expect(find.text('Read percentage'), findsWidgets);
      expect(find.text('80%'), findsWidgets);
      expect(find.text('Notification stats'), findsOneWidget);
      expect(find.text('Access workflow stats'), findsOneWidget);
      expect(find.text('Create Notification'), findsOneWidget);
    });

    testWidgets('error state offers retry and reloads', (tester) async {
      final dashboard = _FakeDashboardRepository(
        null,
        error: const ApiError(
          code: 'NETWORK_ERROR',
          message: 'offline',
        ),
      );

      await tester.pumpWidget(
        await _dashboardHarness(user: _employee, dashboard: dashboard),
      );
      await tester.pumpAndSettle();

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      dashboard
        ..error = null
        ..summary = _employeeSummary(unread: 9);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('Unread notifications'), findsOneWidget);
      expect(find.text('9'), findsWidgets);
    });

    testWidgets('empty latest lists show empty states', (tester) async {
      final dashboard = _FakeDashboardRepository(_employeeSummary());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dashboardRepositoryProvider.overrideWithValue(dashboard),
          ],
          child: MaterialApp(
            theme: AppTheme.light(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const DashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No notifications yet'), findsOneWidget);
      expect(find.text('No requests yet'), findsOneWidget);
    });
  });
}
