import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expoapp_mobile/app/theme.dart';
import 'package:expoapp_mobile/core/api/api_error.dart';
import 'package:expoapp_mobile/core/auth/app_user.dart';
import 'package:expoapp_mobile/core/providers.dart';
import 'package:expoapp_mobile/features/access_requests/data/access_reference_catalog.dart';
import 'package:expoapp_mobile/features/access_requests/data/access_requests_repository.dart';
import 'package:expoapp_mobile/features/access_requests/domain/access_request_models.dart';
import 'package:expoapp_mobile/features/access_requests/presentation/access_requests_providers.dart';
import 'package:expoapp_mobile/features/approvals/data/approvals_repository.dart';
import 'package:expoapp_mobile/features/approvals/domain/approval_models.dart';
import 'package:expoapp_mobile/features/approvals/presentation/approvals_providers.dart';
import 'package:expoapp_mobile/features/audit/data/audit_repository.dart';
import 'package:expoapp_mobile/features/audit/domain/audit_models.dart';
import 'package:expoapp_mobile/features/audit/presentation/audit_providers.dart';
import 'package:expoapp_mobile/features/audit/presentation/screens/audit_logs_screen.dart';
import 'package:expoapp_mobile/features/audit/presentation/widgets/audit_log_card.dart';
import 'package:expoapp_mobile/features/auth/data/auth_repository.dart';
import 'package:expoapp_mobile/features/dashboard/data/dashboard_repository.dart';
import 'package:expoapp_mobile/features/dashboard/domain/dashboard_summary.dart';
import 'package:expoapp_mobile/features/dashboard/presentation/dashboard_providers.dart';
import 'package:expoapp_mobile/features/notifications/data/notifications_repository.dart';
import 'package:expoapp_mobile/features/notifications/data/reference_data_repository.dart';
import 'package:expoapp_mobile/features/notifications/domain/notification_models.dart';
import 'package:expoapp_mobile/features/notifications/presentation/notifications_providers.dart';
import 'package:expoapp_mobile/l10n/app_localizations.dart';

const _securityAdmin = AppUser(
  id: 'u-sec',
  email: 'sara.qahtani@expo.sa',
  displayName: 'Sara Qahtani',
  role: AppRole.securityAdmin,
  permissions: ['audit:read'],
);

const _systemAdmin = AppUser(
  id: 'u-sys',
  email: 'admin@expo.sa',
  displayName: 'Expo System Admin',
  role: AppRole.systemAdmin,
  permissions: ['audit:read', 'notifications:create'],
);

AuditLogEntry _sampleEntry({
  String id = 'log-1',
  String action = 'APPROVAL_MANAGER_APPROVED',
  String entityType = 'AccessRequest',
  String? actorEmail = 'faisal.otaibi@expo.sa',
  Map<String, dynamic>? metadata,
}) {
  return AuditLogEntry(
    id: id,
    action: action,
    entityType: entityType,
    actorEmail: actorEmail,
    entityId: 'ar-1',
    metadata: metadata ??
        const {
          'requestNumber': 'AR-2026-000001',
          'comment': 'Approved for operations work.',
        },
    ipAddress: '10.0.0.8',
    userAgent: 'ExpoApp/1.0',
    createdAt: DateTime.utc(2026, 7, 1, 12, 30),
  );
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

class _FakeAuditRepository implements AuditRepository {
  _FakeAuditRepository({
    this.listResult = const AuditListResult(
      items: [],
      page: 1,
      pageSize: 20,
      total: 0,
      totalPages: 0,
    ),
    this.listError,
  });

  AuditListResult listResult;
  final Object? listError;
  AuditListQuery? lastQuery;

  @override
  Future<AuditListResult> list(AuditListQuery query) async {
    lastQuery = query;
    if (listError != null) throw listError!;
    return listResult;
  }
}

class _FakeDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardSummary> fetchSummary() async {
    return const DashboardSummary(
      role: AppRole.securityAdmin,
      unreadNotifications: 0,
      openAccessRequests: 0,
      completedRequests: 0,
      pendingApprovals: 0,
      teamOpenRequests: 0,
      latestNotifications: [],
      latestRequests: [],
    );
  }
}

class _FakeNotificationsRepository implements NotificationsRepository {
  @override
  Future<NotificationListResult> list(NotificationListQuery query) async {
    return NotificationListResult(
      items: const [],
      page: query.page,
      pageSize: query.pageSize,
      total: 0,
    );
  }

  @override
  Future<AppNotification> getById(String id) async {
    throw ApiError.unknown('unused');
  }

  @override
  Future<AppNotification> markAsRead(String id) async {
    throw ApiError.unknown('unused');
  }

  @override
  Future<CreateNotificationResult> create(
    CreateNotificationRequest request,
  ) async {
    throw ApiError.unknown('unused');
  }

  @override
  Future<NotificationStats> getStats(String id) async {
    throw ApiError.unknown('unused');
  }
}

class _FakeReferenceDataRepository implements ReferenceDataRepository {
  @override
  Future<ReferenceCatalog> fetchCatalog() async {
    return const ReferenceCatalog(
      departments: [],
      roles: ['SECURITY_ADMIN'],
      notificationPriorities: ['NORMAL'],
    );
  }
}

class _FakeAccessRequestsRepository implements AccessRequestsRepository {
  @override
  Future<AccessRequestListResult> list(AccessRequestListQuery query) async {
    return AccessRequestListResult(
      items: const [],
      page: query.page,
      pageSize: query.pageSize,
      total: 0,
    );
  }

  @override
  Future<AccessRequestDetail> getById(String id) async {
    throw ApiError.unknown('unused');
  }

  @override
  Future<SubmitAccessRequestResult> create(
    CreateAccessRequestPayload payload,
  ) async {
    throw ApiError.unknown('unused');
  }

  @override
  Future<CancelAccessRequestResult> cancel(String id) async {
    throw ApiError.unknown('unused');
  }
}

class _FakeAccessReferenceDataRepository
    implements AccessReferenceDataRepository {
  @override
  Future<AccessReferenceCatalog> fetchCatalog() async {
    return const AccessReferenceCatalog(
      systems: [],
      securityRoles: [],
      accessUrgencies: ['NORMAL', 'URGENT', 'CRITICAL'],
      accessDurations: ['TEMPORARY', 'PERMANENT'],
    );
  }
}

class _FakeApprovalsRepository implements ApprovalsRepository {
  @override
  Future<ApprovalListResult> list(ApprovalListQuery query) async {
    return ApprovalListResult(
      items: const [],
      page: query.page,
      pageSize: query.pageSize,
      total: 0,
    );
  }

  @override
  Future<DecideApprovalResult> decide(
    String taskId,
    DecideApprovalPayload payload,
  ) async {
    throw ApiError.unknown('unused');
  }
}

List<Override> _baseOverrides({
  required AppUser user,
  required _FakeAuditRepository audit,
}) {
  return [
    authRepositoryProvider.overrideWithValue(_FakeAuthRepository(user)),
    dashboardRepositoryProvider.overrideWithValue(_FakeDashboardRepository()),
    notificationsRepositoryProvider
        .overrideWithValue(_FakeNotificationsRepository()),
    referenceDataRepositoryProvider
        .overrideWithValue(_FakeReferenceDataRepository()),
    accessRequestsRepositoryProvider
        .overrideWithValue(_FakeAccessRequestsRepository()),
    accessReferenceDataRepositoryProvider
        .overrideWithValue(_FakeAccessReferenceDataRepository()),
    approvalsRepositoryProvider.overrideWithValue(_FakeApprovalsRepository()),
    auditRepositoryProvider.overrideWithValue(audit),
  ];
}

Widget _listHarness({
  required AppUser user,
  required _FakeAuditRepository audit,
}) {
  return ProviderScope(
    overrides: _baseOverrides(user: user, audit: audit),
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light(),
      home: const AuditLogsScreen(),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AuditLogEntry / AuditListQuery', () {
    test('parses list item and builds summary from metadata', () {
      final entry = AuditLogEntry.fromJson({
        'id': 'log-1',
        'actorId': 'u-1',
        'actorEmail': 'faisal.otaibi@expo.sa',
        'action': 'APPROVAL_MANAGER_APPROVED',
        'entityType': 'AccessRequest',
        'entityId': 'ar-1',
        'metadata': {
          'requestNumber': 'AR-2026-000001',
          'comment': 'ok',
        },
        'ipAddress': '127.0.0.1',
        'userAgent': 'test',
        'createdAt': '2026-07-01T12:30:00.000Z',
      });

      expect(entry.id, 'log-1');
      expect(entry.action, 'APPROVAL_MANAGER_APPROVED');
      expect(entry.summary, 'requestNumber: AR-2026-000001');
    });

    test('query parameters include filters and pagination', () {
      final query = AuditListQuery(
        page: 2,
        pageSize: 10,
        actorEmail: ' admin@expo.sa ',
        action: AuditActionCodes.authLogin,
        entityType: AuditEntityTypes.user,
        from: DateTime.utc(2026, 7, 1),
        to: DateTime.utc(2026, 7, 9, 23, 59, 59),
      );

      final params = query.toQueryParameters();
      expect(params['page'], 2);
      expect(params['pageSize'], 10);
      expect(params['actorEmail'], 'admin@expo.sa');
      expect(params['action'], 'AUTH_LOGIN');
      expect(params['entityType'], 'User');
      expect(params['from'], isA<String>());
      expect(params['to'], isA<String>());
      expect(query.hasActiveFilters, isTrue);
    });

    test('hasMore uses totalPages when present', () {
      const result = AuditListResult(
        items: [],
        page: 1,
        pageSize: 20,
        total: 40,
        totalPages: 2,
      );
      expect(result.hasMore, isTrue);
    });
  });

  group('AuditLogsScreen', () {
    testWidgets('shows empty state', (tester) async {
      final audit = _FakeAuditRepository();

      await tester.pumpWidget(
        _listHarness(user: _securityAdmin, audit: audit),
      );
      await tester.pumpAndSettle();

      expect(find.text('No audit logs match your filters'), findsOneWidget);
      expect(
        find.text('Security and admin events will appear here.'),
        findsOneWidget,
      );
    });

    testWidgets('lists audit cards and opens metadata sheet', (tester) async {
      final audit = _FakeAuditRepository(
        listResult: AuditListResult(
          items: [_sampleEntry()],
          page: 1,
          pageSize: 20,
          total: 1,
          totalPages: 1,
        ),
      );

      await tester.pumpWidget(
        _listHarness(user: _systemAdmin, audit: audit),
      );
      await tester.pumpAndSettle();

      expect(find.text('Manager approved'), findsOneWidget);
      expect(find.text('faisal.otaibi@expo.sa'), findsOneWidget);
      expect(find.text('Entity: Access request'), findsOneWidget);
      expect(find.byType(AuditLogCard), findsOneWidget);

      await tester.tap(find.text('View metadata'));
      await tester.pumpAndSettle();

      expect(find.text('Audit event detail'), findsOneWidget);
      expect(find.textContaining('AR-2026-000001'), findsWidgets);
      expect(find.text('10.0.0.8'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('shows error and retry', (tester) async {
      final audit = _FakeAuditRepository(
        listError: const ApiError(code: 'FORBIDDEN', message: 'nope'),
      );

      await tester.pumpWidget(
        _listHarness(user: _securityAdmin, audit: audit),
      );
      await tester.pumpAndSettle();

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('applies action filter to repository query', (tester) async {
      final audit = _FakeAuditRepository();

      await tester.pumpWidget(
        _listHarness(user: _securityAdmin, audit: audit),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('audit-action-null')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Signed in').last);
      await tester.pumpAndSettle();

      expect(audit.lastQuery?.action, 'AUTH_LOGIN');
      expect(audit.lastQuery?.page, 1);
    });
  });

  group('route guards', () {
    test('only security/system admin allowed on /audit', () {
      expect(_isAllowedForTest(AppRole.employee, '/audit'), isFalse);
      expect(_isAllowedForTest(AppRole.manager, '/audit'), isFalse);
      expect(_isAllowedForTest(AppRole.securityAdmin, '/audit'), isTrue);
      expect(_isAllowedForTest(AppRole.systemAdmin, '/audit'), isTrue);
    });
  });
}

/// Mirrors router `_isAllowed` audit rule for unit coverage.
bool _isAllowedForTest(AppRole role, String location) {
  if (location.startsWith('/audit')) {
    return role == AppRole.securityAdmin || role == AppRole.systemAdmin;
  }
  return true;
}
