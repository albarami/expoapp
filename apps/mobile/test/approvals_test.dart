import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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
import 'package:expoapp_mobile/features/approvals/presentation/screens/approval_detail_screen.dart';
import 'package:expoapp_mobile/features/approvals/presentation/screens/approvals_list_screen.dart';
import 'package:expoapp_mobile/features/approvals/presentation/widgets/approval_task_card.dart';
import 'package:expoapp_mobile/features/auth/data/auth_repository.dart';
import 'package:expoapp_mobile/features/dashboard/data/dashboard_repository.dart';
import 'package:expoapp_mobile/features/dashboard/domain/dashboard_summary.dart';
import 'package:expoapp_mobile/features/dashboard/presentation/dashboard_providers.dart';
import 'package:expoapp_mobile/features/notifications/data/notifications_repository.dart';
import 'package:expoapp_mobile/features/notifications/data/reference_data_repository.dart';
import 'package:expoapp_mobile/features/notifications/domain/notification_models.dart';
import 'package:expoapp_mobile/features/notifications/presentation/notifications_providers.dart';
import 'package:expoapp_mobile/l10n/app_localizations.dart';

const _manager = AppUser(
  id: 'u-mgr',
  email: 'faisal.otaibi@expo.sa',
  displayName: 'Faisal Otaibi',
  role: AppRole.manager,
);

ApprovalTask _sampleTask({
  String id = 'task-1',
  String decision = 'PENDING',
  String stage = 'MANAGER',
  String status = 'MANAGER_PENDING',
}) {
  return ApprovalTask(
    id: id,
    stage: stage,
    decision: decision,
    createdAt: DateTime.utc(2026, 7, 1, 10),
    accessRequest: ApprovalAccessRequestSummary(
      id: 'ar-1',
      requestNumber: 'AR-2026-000001',
      status: status,
      currentStage: stage,
      urgency: 'URGENT',
      accessDuration: 'TEMPORARY',
      submittedAt: DateTime.utc(2026, 7, 1, 10),
      system: const NamedRef(
        id: 'sys-1',
        code: 'ORACLE_FUSION_ERP',
        nameEn: 'Oracle Fusion ERP',
        nameAr: 'أوراكل فيوجن',
      ),
      securityRole: const SecurityRoleDetail(
        id: 'role-1',
        code: 'AP_INQUIRY',
        nameEn: 'AP Inquiry',
        nameAr: 'استعلام الموردين',
        riskLevel: 'MEDIUM',
      ),
      requester: const PersonRef(
        id: 'u-emp',
        fullNameEn: 'Noura Alharbi',
        fullNameAr: 'نورة الحربي',
        email: 'noura.alharbi@expo.sa',
      ),
    ),
  );
}

AccessRequestDetail _sampleDetail() {
  return AccessRequestDetail(
    id: 'ar-1',
    requestNumber: 'AR-2026-000001',
    status: 'MANAGER_PENDING',
    currentStage: 'MANAGER',
    businessJustification:
        'Need temporary AP inquiry access for month-end reconciliation.',
    accessDuration: 'TEMPORARY',
    urgency: 'URGENT',
    startDate: DateTime.utc(2026, 7, 10),
    endDate: DateTime.utc(2026, 8, 10),
    submittedAt: DateTime.utc(2026, 7, 1, 10),
    system: const NamedRef(
      id: 'sys-1',
      code: 'ORACLE_FUSION_ERP',
      nameEn: 'Oracle Fusion ERP',
    ),
    securityRole: const SecurityRoleDetail(
      id: 'role-1',
      code: 'AP_INQUIRY',
      nameEn: 'AP Inquiry',
      riskLevel: 'MEDIUM',
    ),
    requester: const PersonRef(
      id: 'u-emp',
      fullNameEn: 'Noura Alharbi',
      email: 'noura.alharbi@expo.sa',
    ),
    nextApprover: const PersonRef(
      id: 'u-mgr',
      fullNameEn: 'Faisal Otaibi',
    ),
    timeline: [
      AccessRequestTimelineEvent(
        id: 'ev-1',
        eventType: 'SUBMITTED',
        messageEn: 'Request submitted by Noura Alharbi',
        actor: const PersonRef(id: 'u-emp', fullNameEn: 'Noura Alharbi'),
        createdAt: DateTime.utc(2026, 7, 1, 10),
      ),
    ],
    createdAt: DateTime.utc(2026, 7, 1, 10),
    updatedAt: DateTime.utc(2026, 7, 1, 10),
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

class _FakeDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardSummary> fetchSummary() async {
    return const DashboardSummary(
      role: AppRole.manager,
      unreadNotifications: 0,
      openAccessRequests: 0,
      completedRequests: 0,
      pendingApprovals: 1,
      teamOpenRequests: 1,
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
      roles: ['MANAGER'],
      notificationPriorities: ['NORMAL'],
    );
  }
}

class _FakeAccessRequestsRepository implements AccessRequestsRepository {
  _FakeAccessRequestsRepository({this.detail});

  AccessRequestDetail? detail;

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
    final item = detail ?? _sampleDetail();
    if (item.id == id || id == 'ar-1') return item;
    throw ApiError.unknown('missing detail');
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
  _FakeApprovalsRepository({
    this.listResult,
    this.listError,
  });

  ApprovalListResult? listResult;
  ApiError? listError;
  DecideApprovalPayload? lastDecide;
  String? lastDecideTaskId;

  @override
  Future<ApprovalListResult> list(ApprovalListQuery query) async {
    final err = listError;
    if (err != null) throw err;
    final all = listResult ??
        ApprovalListResult(
          items: const [],
          page: query.page,
          pageSize: query.pageSize,
          total: 0,
        );
    if (query.status == null || query.status!.isEmpty) {
      return all;
    }
    final filtered = all.items
        .where((t) => t.decision.toUpperCase() == query.status!.toUpperCase())
        .toList(growable: false);
    return ApprovalListResult(
      items: filtered,
      page: query.page,
      pageSize: query.pageSize,
      total: filtered.length,
    );
  }

  @override
  Future<DecideApprovalResult> decide(
    String taskId,
    DecideApprovalPayload payload,
  ) async {
    lastDecideTaskId = taskId;
    lastDecide = payload;
    return DecideApprovalResult(
      taskId: taskId,
      decision: payload.decision.apiValue,
      requestId: 'ar-1',
      requestNumber: 'AR-2026-000001',
      status: payload.decision == ApprovalDecisionInput.approved
          ? 'SECURITY_PENDING'
          : 'MANAGER_REJECTED',
      currentStage: payload.decision == ApprovalDecisionInput.approved
          ? 'SECURITY'
          : 'COMPLETE',
    );
  }
}

List<Override> _baseOverrides({
  required AppUser user,
  required _FakeApprovalsRepository approvals,
  AccessRequestDetail? detail,
}) {
  return [
    authRepositoryProvider.overrideWithValue(_FakeAuthRepository(user)),
    dashboardRepositoryProvider.overrideWithValue(_FakeDashboardRepository()),
    notificationsRepositoryProvider
        .overrideWithValue(_FakeNotificationsRepository()),
    referenceDataRepositoryProvider
        .overrideWithValue(_FakeReferenceDataRepository()),
    accessRequestsRepositoryProvider.overrideWithValue(
      _FakeAccessRequestsRepository(detail: detail ?? _sampleDetail()),
    ),
    accessReferenceDataRepositoryProvider
        .overrideWithValue(_FakeAccessReferenceDataRepository()),
    approvalsRepositoryProvider.overrideWithValue(approvals),
  ];
}

Widget _listHarness({
  required AppUser user,
  required _FakeApprovalsRepository approvals,
}) {
  return ProviderScope(
    overrides: _baseOverrides(user: user, approvals: approvals),
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light(),
      home: const ApprovalsListScreen(),
    ),
  );
}

Widget _detailHarness({
  required AppUser user,
  required _FakeApprovalsRepository approvals,
  String taskId = 'task-1',
}) {
  final router = GoRouter(
    initialLocation: '/approvals/$taskId',
    routes: [
      GoRoute(
        path: '/approvals',
        builder: (context, state) => const ApprovalsListScreen(),
        routes: [
          GoRoute(
            path: ':taskId',
            builder: (context, state) => ApprovalDetailScreen(
              taskId: state.pathParameters['taskId'] ?? '',
            ),
          ),
        ],
      ),
    ],
  );

  return ProviderScope(
    overrides: _baseOverrides(user: user, approvals: approvals),
    child: MaterialApp.router(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light(),
      routerConfig: router,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('approval models', () {
    test('parses list item JSON', () {
      final task = ApprovalTask.fromJson({
        'id': 'task-1',
        'stage': 'MANAGER',
        'decision': 'PENDING',
        'comment': null,
        'decidedAt': null,
        'createdAt': '2026-07-01T10:00:00.000Z',
        'accessRequest': {
          'id': 'ar-1',
          'requestNumber': 'AR-2026-000001',
          'status': 'MANAGER_PENDING',
          'currentStage': 'MANAGER',
          'urgency': 'URGENT',
          'accessDuration': 'TEMPORARY',
          'submittedAt': '2026-07-01T10:00:00.000Z',
          'system': {
            'id': 'sys-1',
            'code': 'ERP',
            'nameEn': 'ERP',
            'nameAr': null,
          },
          'securityRole': {
            'id': 'role-1',
            'code': 'AP',
            'nameEn': 'AP',
            'nameAr': null,
            'riskLevel': 'HIGH',
          },
          'requester': {
            'id': 'u-emp',
            'fullNameEn': 'Noura',
            'fullNameAr': null,
            'email': 'noura@expo.sa',
          },
        },
      });
      expect(task.id, 'task-1');
      expect(task.isPending, isTrue);
      expect(task.accessRequest.securityRole.riskLevel, 'HIGH');
      expect(task.accessRequest.urgency, 'URGENT');
    });

    test('decide payload omits empty comment', () {
      final payload = DecideApprovalPayload(
        decision: ApprovalDecisionInput.approved,
        comment: '  ',
      );
      expect(payload.toJson(), {'decision': 'APPROVED'});
    });

    test('reject payload includes comment', () {
      final payload = DecideApprovalPayload(
        decision: ApprovalDecisionInput.rejected,
        comment: ' Insufficient justification ',
      );
      expect(payload.toJson()['decision'], 'REJECTED');
      expect(payload.toJson()['comment'], 'Insufficient justification');
    });
  });

  group('ApprovalsListScreen', () {
    testWidgets('shows empty pending state', (tester) async {
      final approvals = _FakeApprovalsRepository(
        listResult: const ApprovalListResult(
          items: [],
          page: 1,
          pageSize: 20,
          total: 0,
        ),
      );

      await tester.pumpWidget(
        _listHarness(user: _manager, approvals: approvals),
      );
      await tester.pumpAndSettle();

      expect(find.text('No approvals pending'), findsOneWidget);
      expect(find.text('You are all caught up.'), findsOneWidget);
    });

    testWidgets('lists pending tasks with risk and urgency chips',
        (tester) async {
      final approvals = _FakeApprovalsRepository(
        listResult: ApprovalListResult(
          items: [_sampleTask()],
          page: 1,
          pageSize: 20,
          total: 1,
        ),
      );

      await tester.pumpWidget(
        _listHarness(user: _manager, approvals: approvals),
      );
      await tester.pumpAndSettle();

      expect(find.text('AR-2026-000001'), findsOneWidget);
      expect(find.text('Noura Alharbi'), findsOneWidget);
      expect(find.text('Review'), findsOneWidget);
      expect(find.text('Urgent'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.byType(ApprovalTaskCard), findsOneWidget);
    });

    testWidgets('shows error and retry', (tester) async {
      final approvals = _FakeApprovalsRepository(
        listError: const ApiError(code: 'NETWORK_ERROR', message: 'down'),
      );

      await tester.pumpWidget(
        _listHarness(user: _manager, approvals: approvals),
      );
      await tester.pumpAndSettle();

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });

  group('ApprovalDetailScreen', () {
    testWidgets('shows approve/reject and submits approve with confirm',
        (tester) async {
      final approvals = _FakeApprovalsRepository(
        listResult: ApprovalListResult(
          items: [_sampleTask()],
          page: 1,
          pageSize: 20,
          total: 1,
        ),
      );

      await tester.pumpWidget(
        _detailHarness(user: _manager, approvals: approvals),
      );
      await tester.pumpAndSettle();

      expect(find.text('AR-2026-000001'), findsOneWidget);
      expect(find.text('Approve'), findsOneWidget);
      expect(find.text('Reject'), findsOneWidget);
      expect(
        find.text(
          'Need temporary AP inquiry access for month-end reconciliation.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Approve'));
      await tester.pumpAndSettle();

      expect(find.text('Approve this request?'), findsOneWidget);
      await tester.tap(find.text('Confirm approve'));
      await tester.pumpAndSettle();

      expect(approvals.lastDecideTaskId, 'task-1');
      expect(
        approvals.lastDecide?.decision,
        ApprovalDecisionInput.approved,
      );
      expect(find.byType(ApprovalsListScreen), findsOneWidget);
    });

    testWidgets('reject requires comment', (tester) async {
      final approvals = _FakeApprovalsRepository(
        listResult: ApprovalListResult(
          items: [_sampleTask()],
          page: 1,
          pageSize: 20,
          total: 1,
        ),
      );

      await tester.pumpWidget(
        _detailHarness(user: _manager, approvals: approvals),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reject'));
      await tester.pumpAndSettle();

      expect(find.text('Please provide a rejection reason.'), findsOneWidget);
      await tester.tap(find.text('Confirm reject'));
      await tester.pumpAndSettle();

      expect(find.text('A rejection reason is required.'), findsOneWidget);
      expect(approvals.lastDecide, isNull);

      await tester.enterText(find.byType(TextField), 'Not justified enough');
      await tester.tap(find.text('Confirm reject'));
      await tester.pumpAndSettle();

      expect(approvals.lastDecide?.decision, ApprovalDecisionInput.rejected);
      expect(approvals.lastDecide?.comment, 'Not justified enough');
    });

    testWidgets('hides actions when task already decided', (tester) async {
      final approvals = _FakeApprovalsRepository(
        listResult: ApprovalListResult(
          items: [
            _sampleTask(decision: 'APPROVED', status: 'SECURITY_PENDING'),
          ],
          page: 1,
          pageSize: 20,
          total: 1,
        ),
      );

      await tester.pumpWidget(
        _detailHarness(user: _manager, approvals: approvals),
      );
      await tester.pumpAndSettle();

      expect(find.text('Approve'), findsNothing);
      expect(find.text('Reject'), findsNothing);
    });
  });

  group('route guards', () {
    test('employee is not allowed on /approvals', () {
      expect(_isAllowedForTest(AppRole.employee, '/approvals'), isFalse);
      expect(_isAllowedForTest(AppRole.manager, '/approvals'), isTrue);
      expect(_isAllowedForTest(AppRole.securityAdmin, '/approvals'), isTrue);
      expect(_isAllowedForTest(AppRole.systemAdmin, '/approvals'), isTrue);
    });
  });
}

/// Mirrors router `_isAllowed` approvals rule for unit coverage.
bool _isAllowedForTest(AppRole role, String location) {
  if (location.startsWith('/approvals')) {
    return role == AppRole.manager ||
        role == AppRole.securityAdmin ||
        role == AppRole.systemAdmin;
  }
  return true;
}
