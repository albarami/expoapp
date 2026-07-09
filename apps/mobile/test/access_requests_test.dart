import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expoapp_mobile/app/app.dart';
import 'package:expoapp_mobile/app/theme.dart';
import 'package:expoapp_mobile/core/api/api_error.dart';
import 'package:expoapp_mobile/core/auth/app_user.dart';
import 'package:expoapp_mobile/core/auth/token_storage.dart';
import 'package:expoapp_mobile/core/providers.dart';
import 'package:expoapp_mobile/features/access_requests/data/access_reference_catalog.dart';
import 'package:expoapp_mobile/features/access_requests/data/access_requests_repository.dart';
import 'package:expoapp_mobile/features/access_requests/domain/access_request_models.dart';
import 'package:expoapp_mobile/features/access_requests/presentation/access_requests_providers.dart';
import 'package:expoapp_mobile/features/access_requests/presentation/screens/access_request_detail_screen.dart';
import 'package:expoapp_mobile/features/access_requests/presentation/screens/access_requests_list_screen.dart';
import 'package:expoapp_mobile/features/access_requests/presentation/screens/create_access_request_screen.dart';
import 'package:expoapp_mobile/features/access_requests/presentation/widgets/access_request_card.dart';
import 'package:expoapp_mobile/features/auth/data/auth_repository.dart';
import 'package:expoapp_mobile/features/dashboard/data/dashboard_repository.dart';
import 'package:expoapp_mobile/features/dashboard/domain/dashboard_summary.dart';
import 'package:expoapp_mobile/features/dashboard/presentation/dashboard_providers.dart';
import 'package:expoapp_mobile/features/notifications/data/notifications_repository.dart';
import 'package:expoapp_mobile/features/notifications/data/reference_data_repository.dart';
import 'package:expoapp_mobile/features/notifications/domain/notification_models.dart';
import 'package:expoapp_mobile/features/notifications/presentation/notifications_providers.dart';
import 'package:expoapp_mobile/l10n/app_localizations.dart';
import 'package:expoapp_mobile/shared/widgets/status_chip.dart';

const _employee = AppUser(
  id: 'u-emp',
  email: 'noura.alharbi@expo.sa',
  displayName: 'Noura Alharbi',
  role: AppRole.employee,
);

AccessRequestListItem _sampleListItem({
  String id = 'ar-1',
  String status = 'MANAGER_PENDING',
  String stage = 'MANAGER',
}) {
  return AccessRequestListItem(
    id: id,
    requestNumber: 'AR-2026-000001',
    status: status,
    currentStage: stage,
    urgency: 'NORMAL',
    accessDuration: 'TEMPORARY',
    system: const NamedRef(
      id: 'sys-1',
      code: 'ORACLE_FUSION_ERP',
      nameEn: 'Oracle Fusion ERP',
      nameAr: 'أوراكل فيوجن',
    ),
    securityRole: const NamedRef(
      id: 'role-1',
      code: 'AP_INQUIRY',
      nameEn: 'AP Inquiry',
      nameAr: 'استعلام الموردين',
    ),
    requester: const PersonRef(
      id: 'u-emp',
      fullNameEn: 'Noura Alharbi',
      fullNameAr: 'نورة الحربي',
      email: 'noura.alharbi@expo.sa',
    ),
    submittedAt: DateTime.utc(2026, 7, 1, 10),
    createdAt: DateTime.utc(2026, 7, 1, 10),
  );
}

AccessRequestDetail _sampleDetail({
  String status = 'MANAGER_PENDING',
  String requesterId = 'u-emp',
}) {
  return AccessRequestDetail(
    id: 'ar-1',
    requestNumber: 'AR-2026-000001',
    status: status,
    currentStage: 'MANAGER',
    businessJustification:
        'Need temporary AP inquiry access for month-end reconciliation.',
    accessDuration: 'TEMPORARY',
    urgency: 'NORMAL',
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
      riskLevel: 'LOW',
    ),
    requester: PersonRef(
      id: requesterId,
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
        messageAr: 'تم تقديم الطلب بواسطة نورة الحربي',
        actor: const PersonRef(id: 'u-emp', fullNameEn: 'Noura Alharbi'),
        createdAt: DateTime.utc(2026, 7, 1, 10),
      ),
      AccessRequestTimelineEvent(
        id: 'ev-2',
        eventType: 'MANAGER_TASK_ASSIGNED',
        messageEn: 'Manager approval task assigned to Faisal Otaibi',
        messageAr: 'تم تعيين مهمة موافقة المدير إلى فيصل العتيبي',
        actor: const PersonRef(id: 'u-mgr', fullNameEn: 'Faisal Otaibi'),
        createdAt: DateTime.utc(2026, 7, 1, 10, 1),
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
    return DashboardSummary(
      role: AppRole.employee,
      unreadNotifications: 0,
      openAccessRequests: 1,
      completedRequests: 0,
      pendingApprovals: 0,
      latestNotifications: const [],
      latestRequests: const [],
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
      roles: ['EMPLOYEE'],
      notificationPriorities: ['NORMAL'],
    );
  }
}

class _FakeAccessRequestsRepository implements AccessRequestsRepository {
  _FakeAccessRequestsRepository({
    this.listResult,
    this.detail,
    this.listError,
  });

  AccessRequestListResult? listResult;
  AccessRequestDetail? detail;
  ApiError? listError;
  int listCalls = 0;
  int cancelCalls = 0;
  CreateAccessRequestPayload? lastCreate;

  @override
  Future<AccessRequestListResult> list(AccessRequestListQuery query) async {
    listCalls++;
    final err = listError;
    if (err != null) throw err;
    return listResult ??
        AccessRequestListResult(
          items: const [],
          page: query.page,
          pageSize: query.pageSize,
          total: 0,
        );
  }

  @override
  Future<AccessRequestDetail> getById(String id) async {
    final item = detail;
    if (item != null && (item.id == id || id == 'ar-1')) {
      return item;
    }
    if (id == 'ar-new') {
      return _sampleDetail().copyWithId(id: 'ar-new', requestNumber: 'AR-2026-000099');
    }
    if (item == null) {
      throw ApiError.unknown('missing detail');
    }
    return item;
  }

  @override
  Future<SubmitAccessRequestResult> create(
    CreateAccessRequestPayload payload,
  ) async {
    lastCreate = payload;
    detail = _sampleDetail().copyWithId(
      id: 'ar-new',
      requestNumber: 'AR-2026-000099',
    );
    return const SubmitAccessRequestResult(
      id: 'ar-new',
      requestNumber: 'AR-2026-000099',
      status: 'MANAGER_PENDING',
      currentStage: 'MANAGER',
    );
  }

  @override
  Future<CancelAccessRequestResult> cancel(String id) async {
    cancelCalls++;
    detail = _sampleDetail(status: 'CANCELLED');
    return const CancelAccessRequestResult(
      id: 'ar-1',
      requestNumber: 'AR-2026-000001',
      status: 'CANCELLED',
      currentStage: 'REQUESTER',
    );
  }
}

class _FakeAccessReferenceDataRepository
    implements AccessReferenceDataRepository {
  @override
  Future<AccessReferenceCatalog> fetchCatalog() async {
    return const AccessReferenceCatalog(
      systems: [
        AccessReferenceSystem(
          id: 'sys-1',
          code: 'ORACLE_FUSION_ERP',
          nameEn: 'Oracle Fusion ERP',
          nameAr: 'أوراكل فيوجن',
        ),
      ],
      securityRoles: [
        AccessReferenceSecurityRole(
          id: 'role-1',
          systemId: 'sys-1',
          systemCode: 'ORACLE_FUSION_ERP',
          code: 'AP_INQUIRY',
          nameEn: 'AP Inquiry',
          riskLevel: 'LOW',
        ),
        AccessReferenceSecurityRole(
          id: 'role-2',
          systemId: 'sys-other',
          systemCode: 'OTHER',
          code: 'OTHER_ROLE',
          nameEn: 'Other Role',
        ),
      ],
      accessUrgencies: ['NORMAL', 'URGENT', 'CRITICAL'],
      accessDurations: ['TEMPORARY', 'PERMANENT'],
    );
  }
}

Future<Widget> _appHarness({
  required AppUser user,
  required AccessRequestsRepository accessRequests,
  AccessReferenceDataRepository? reference,
}) async {
  final storage = InMemoryTokenStorage();
  await storage.writeTokens(accessToken: 'tok', refreshToken: 'ref');
  return ProviderScope(
    overrides: [
      tokenStorageProvider.overrideWithValue(storage),
      authRepositoryProvider.overrideWithValue(_FakeAuthRepository(user)),
      dashboardRepositoryProvider.overrideWithValue(_FakeDashboardRepository()),
      notificationsRepositoryProvider.overrideWithValue(
        _FakeNotificationsRepository(),
      ),
      referenceDataRepositoryProvider.overrideWithValue(
        _FakeReferenceDataRepository(),
      ),
      accessRequestsRepositoryProvider.overrideWithValue(accessRequests),
      accessReferenceDataRepositoryProvider.overrideWithValue(
        reference ?? _FakeAccessReferenceDataRepository(),
      ),
    ],
    child: const ExpoApp(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('access request models', () {
    test('parses list item and cancelable statuses', () {
      final item = AccessRequestListItem.fromJson({
        'id': 'ar-1',
        'requestNumber': 'AR-2026-000001',
        'status': 'MANAGER_PENDING',
        'currentStage': 'MANAGER',
        'urgency': 'URGENT',
        'accessDuration': 'TEMPORARY',
        'system': {
          'id': 'sys-1',
          'code': 'ERP',
          'nameEn': 'ERP',
          'nameAr': 'نظام',
        },
        'securityRole': {
          'id': 'role-1',
          'code': 'AP',
          'nameEn': 'AP',
        },
        'requester': {
          'id': 'u-emp',
          'fullNameEn': 'Noura',
          'email': 'noura@expo.sa',
        },
        'submittedAt': '2026-07-01T10:00:00.000Z',
        'createdAt': '2026-07-01T10:00:00.000Z',
      });
      expect(item.isCancelable, isTrue);
      expect(item.system.localizedName(arabic: true), 'نظام');
      expect(AccessRequestListTab.pending.matches('MANAGER_PENDING'), isTrue);
      expect(AccessRequestListTab.completed.matches('MANAGER_PENDING'), isFalse);
      expect(AccessRequestListTab.rejected.matches('CANCELLED'), isTrue);
    });

    test('create payload serializes enums and dates', () {
      final json = CreateAccessRequestPayload(
        systemId: 'sys-1',
        securityRoleId: 'role-1',
        businessJustification: 'Need access for month-end close activities.',
        accessDuration: AccessDuration.temporary,
        startDate: DateTime.utc(2026, 7, 10),
        endDate: DateTime.utc(2026, 8, 10),
        urgency: AccessUrgency.critical,
      ).toJson();
      expect(json['accessDuration'], 'TEMPORARY');
      expect(json['urgency'], 'CRITICAL');
      expect(json['startDate'], contains('2026-07-10'));
      expect(json['endDate'], contains('2026-08-10'));
    });

    test('detail parses timeline bilingual messages', () {
      final detail = AccessRequestDetail.fromJson({
        'id': 'ar-1',
        'requestNumber': 'AR-2026-000001',
        'status': 'SECURITY_PENDING',
        'currentStage': 'SECURITY',
        'businessJustification': 'Need temporary AP inquiry access now.',
        'accessDuration': 'TEMPORARY',
        'urgency': 'NORMAL',
        'startDate': '2026-07-10T00:00:00.000Z',
        'endDate': null,
        'system': {'id': 's', 'code': 'ERP', 'nameEn': 'ERP'},
        'securityRole': {
          'id': 'r',
          'code': 'AP',
          'nameEn': 'AP',
          'requiresManagerApproval': true,
          'requiresSecurityApproval': true,
          'riskLevel': 'MEDIUM',
        },
        'requester': {
          'id': 'u',
          'fullNameEn': 'Noura',
          'email': 'n@expo.sa',
        },
        'nextApprover': null,
        'timeline': [
          {
            'id': 'e1',
            'eventType': 'SUBMITTED',
            'messageEn': 'Submitted',
            'messageAr': 'مُرسل',
            'actor': {'id': 'u', 'fullNameEn': 'Noura'},
            'createdAt': '2026-07-01T10:00:00.000Z',
            'metadata': null,
          },
        ],
        'createdAt': '2026-07-01T10:00:00.000Z',
        'updatedAt': '2026-07-01T10:00:00.000Z',
      });
      expect(detail.isCancelable, isTrue);
      expect(detail.timeline.first.localizedMessage(arabic: true), 'مُرسل');
    });
  });

  group('AccessRequestCard', () {
    testWidgets('shows request number, system, and status', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light(),
          home: Scaffold(
            body: AccessRequestCard(
              item: _sampleListItem(),
              isArabic: false,
              onTap: () {},
            ),
          ),
        ),
      );
      expect(find.text('AR-2026-000001'), findsOneWidget);
      expect(find.text('Oracle Fusion ERP'), findsOneWidget);
      expect(find.text('AP Inquiry'), findsOneWidget);
      expect(find.byType(StatusChip), findsOneWidget);
    });
  });

  group('AccessRequestsListScreen', () {
    testWidgets('shows empty state and FAB', (tester) async {
      final repo = _FakeAccessRequestsRepository(
        listResult: const AccessRequestListResult(
          items: [],
          page: 1,
          pageSize: 20,
          total: 0,
        ),
      );
      await tester.pumpWidget(
        await _appHarness(user: _employee, accessRequests: repo),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Requests'));
      await tester.pumpAndSettle();

      expect(find.byType(AccessRequestsListScreen), findsOneWidget);
      expect(find.text('No requests yet'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('filters pending tab and opens detail', (tester) async {
      final repo = _FakeAccessRequestsRepository(
        listResult: AccessRequestListResult(
          items: [
            _sampleListItem(id: 'ar-1', status: 'MANAGER_PENDING'),
            _sampleListItem(
              id: 'ar-2',
              status: 'COMPLETED',
              stage: 'COMPLETE',
            ),
          ],
          page: 1,
          pageSize: 20,
          total: 2,
        ),
        detail: _sampleDetail(),
      );
      await tester.pumpWidget(
        await _appHarness(user: _employee, accessRequests: repo),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Requests'));
      await tester.pumpAndSettle();

      expect(find.text('AR-2026-000001'), findsNWidgets(2));

      await tester.tap(find.text('Pending'));
      await tester.pumpAndSettle();
      expect(find.text('AR-2026-000001'), findsOneWidget);

      await tester.tap(find.text('AR-2026-000001'));
      await tester.pumpAndSettle();
      expect(find.byType(AccessRequestDetailScreen), findsOneWidget);
      expect(find.textContaining('AR-2026-000001'), findsWidgets);
      expect(find.textContaining('Oracle Fusion ERP'), findsWidgets);
      expect(find.textContaining('AP Inquiry'), findsWidgets);
    });

    testWidgets('shows error state with retry', (tester) async {
      final repo = _FakeAccessRequestsRepository(
        listError: const ApiError(code: 'NETWORK_ERROR', message: 'down'),
      );
      await tester.pumpWidget(
        await _appHarness(user: _employee, accessRequests: repo),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Requests'));
      await tester.pumpAndSettle();

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(repo.listCalls, greaterThanOrEqualTo(1));

      repo.listError = null;
      repo.listResult = AccessRequestListResult(
        items: [_sampleListItem()],
        page: 1,
        pageSize: 20,
        total: 1,
      );
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('AR-2026-000001'), findsOneWidget);
    });
  });

  group('CreateAccessRequestScreen', () {
    testWidgets('loads reference systems into the form', (tester) async {
      final repo = _FakeAccessRequestsRepository();
      final storage = InMemoryTokenStorage();
      await storage.writeTokens(accessToken: 'tok', refreshToken: 'ref');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tokenStorageProvider.overrideWithValue(storage),
            authRepositoryProvider
                .overrideWithValue(_FakeAuthRepository(_employee)),
            accessRequestsRepositoryProvider.overrideWithValue(repo),
            accessReferenceDataRepositoryProvider.overrideWithValue(
              _FakeAccessReferenceDataRepository(),
            ),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.light(),
            home: const CreateAccessRequestScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CreateAccessRequestScreen), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
      expect(find.text('Business justification'), findsOneWidget);
      expect(find.text('Temporary'), findsOneWidget);
      expect(find.text('Permanent'), findsOneWidget);

      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();
      expect(find.text('Oracle Fusion ERP'), findsWidgets);
    });

    test('create payload matches API contract', () {
      final payload = CreateAccessRequestPayload(
        systemId: 'sys-1',
        securityRoleId: 'role-1',
        businessJustification: 'Need temporary AP inquiry access for close.',
        accessDuration: AccessDuration.temporary,
        startDate: DateTime.utc(2026, 7, 10),
        endDate: DateTime.utc(2026, 8, 10),
        urgency: AccessUrgency.urgent,
      );
      final json = payload.toJson();
      expect(json['systemId'], 'sys-1');
      expect(json['securityRoleId'], 'role-1');
      expect(json['accessDuration'], 'TEMPORARY');
      expect(json['urgency'], 'URGENT');
      expect(json.containsKey('endDate'), isTrue);
    });
  });

  group('AccessRequestDetailScreen', () {
    testWidgets('shows cancel for requester when pending', (tester) async {
      final repo = _FakeAccessRequestsRepository(detail: _sampleDetail());
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        await _appHarness(user: _employee, accessRequests: repo),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(Scaffold).first);
      GoRouter.of(context).go('/requests/ar-1');
      await tester.pumpAndSettle();

      expect(find.byType(AccessRequestDetailScreen), findsOneWidget);
      expect(find.textContaining('AR-2026-000001'), findsWidgets);
      expect(
        find.textContaining('Request submitted by Noura Alharbi'),
        findsOneWidget,
      );
      expect(find.text('Cancel request'), findsOneWidget);

      await tester.tap(find.text('Cancel request'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(repo.cancelCalls, 1);
      expect(find.text('Request cancelled.'), findsOneWidget);
    });

    testWidgets('hides cancel when not cancelable', (tester) async {
      final repo = _FakeAccessRequestsRepository(
        detail: _sampleDetail(status: 'COMPLETED'),
      );
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        await _appHarness(user: _employee, accessRequests: repo),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(Scaffold).first);
      GoRouter.of(context).go('/requests/ar-1');
      await tester.pumpAndSettle();

      expect(find.textContaining('AR-2026-000001'), findsWidgets);
      expect(find.text('Cancel request'), findsNothing);
    });
  });
}
