import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expoapp_mobile/app/app.dart';
import 'package:expoapp_mobile/app/theme.dart';
import 'package:expoapp_mobile/core/api/api_envelope.dart';
import 'package:expoapp_mobile/core/api/api_error.dart';
import 'package:expoapp_mobile/core/auth/app_user.dart';
import 'package:expoapp_mobile/core/auth/token_storage.dart';
import 'package:expoapp_mobile/core/providers.dart';
import 'package:expoapp_mobile/features/auth/data/auth_repository.dart';
import 'package:expoapp_mobile/features/dashboard/data/dashboard_repository.dart';
import 'package:expoapp_mobile/features/dashboard/domain/dashboard_summary.dart';
import 'package:expoapp_mobile/features/dashboard/presentation/dashboard_providers.dart';
import 'package:expoapp_mobile/features/notifications/data/notifications_repository.dart';
import 'package:expoapp_mobile/features/notifications/data/reference_data_repository.dart';
import 'package:expoapp_mobile/features/notifications/data/users_repository.dart';
import 'package:expoapp_mobile/features/notifications/domain/notification_models.dart';
import 'package:expoapp_mobile/features/notifications/presentation/notifications_providers.dart';
import 'package:expoapp_mobile/features/notifications/presentation/screens/create_notification_screen.dart';
import 'package:expoapp_mobile/features/notifications/presentation/screens/notification_detail_screen.dart';
import 'package:expoapp_mobile/features/notifications/presentation/screens/notifications_list_screen.dart';
import 'package:expoapp_mobile/features/notifications/presentation/widgets/notification_card.dart';
import 'package:expoapp_mobile/l10n/app_localizations.dart';
import 'package:expoapp_mobile/shared/widgets/status_chip.dart';

const _employee = AppUser(
  id: 'u-emp',
  email: 'noura.alharbi@expo.sa',
  displayName: 'Noura Alharbi',
  role: AppRole.employee,
);

const _admin = AppUser(
  id: 'u-admin',
  email: 'admin@expo.sa',
  displayName: 'System Admin',
  role: AppRole.systemAdmin,
);

AppNotification _sampleNotification({
  String id = 'n1',
  String priority = 'HIGH',
  DateTime? readAt,
}) {
  return AppNotification(
    id: id,
    titleEn: 'Security access available',
    titleAr: 'خدمة الصلاحيات متاحة',
    bodyEn: 'You can now request access from ExpoApp.',
    bodyAr: 'يمكنك الآن طلب الصلاحيات من التطبيق.',
    priority: priority,
    status: 'PUBLISHED',
    audienceType: 'ALL',
    readAt: readAt,
    createdAt: DateTime.utc(2026, 7, 1, 10),
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
      openAccessRequests: 0,
      completedRequests: 0,
      pendingApprovals: 0,
      latestNotifications: const [],
      latestRequests: const [],
    );
  }
}

class _FakeNotificationsRepository implements NotificationsRepository {
  _FakeNotificationsRepository({
    this.listResult,
    this.detail,
    this.stats,
    this.listError,
  });

  NotificationListResult? listResult;
  AppNotification? detail;
  NotificationStats? stats;
  ApiError? listError;
  int listCalls = 0;
  int markReadCalls = 0;
  CreateNotificationRequest? lastCreate;

  @override
  Future<NotificationListResult> list(NotificationListQuery query) async {
    listCalls++;
    final err = listError;
    if (err != null) throw err;
    return listResult ??
        NotificationListResult(
          items: const [],
          page: query.page,
          pageSize: query.pageSize,
          total: 0,
        );
  }

  @override
  Future<AppNotification> getById(String id) async {
    final item = detail;
    if (item == null) {
      throw ApiError.unknown('missing detail');
    }
    return item;
  }

  @override
  Future<AppNotification> markAsRead(String id) async {
    markReadCalls++;
    final item = detail ?? _sampleNotification(id: id);
    final updated = item.copyWith(readAt: DateTime.utc(2026, 7, 2));
    detail = updated;
    return updated;
  }

  @override
  Future<CreateNotificationResult> create(
    CreateNotificationRequest request,
  ) async {
    lastCreate = request;
    return const CreateNotificationResult(
      id: 'created-1',
      status: 'PUBLISHED',
      recipientCount: 4,
    );
  }

  @override
  Future<NotificationStats> getStats(String id) async {
    return stats ??
        NotificationStats(
          notificationId: id,
          recipientCount: 10,
          deliveredCount: 10,
          readCount: 4,
          unreadCount: 6,
          readPercentage: 40,
        );
  }
}

class _FakeUsersRepository implements UsersRepository {
  _FakeUsersRepository({List<AudienceUser>? users})
      : users = users ??
            const [
              AudienceUser(
                id: 'u-emp',
                email: 'noura.alharbi@expo.sa',
                fullNameEn: 'Noura Alharbi',
                fullNameAr: 'نورة الحربي',
                employeeNumber: 'E1001',
                departmentCode: 'OPS',
              ),
              AudienceUser(
                id: 'u-mgr',
                email: 'faisal.otaibi@expo.sa',
                fullNameEn: 'Faisal Otaibi',
                employeeNumber: 'M2001',
                departmentCode: 'OPS',
              ),
            ];

  final List<AudienceUser> users;
  String? lastQuery;

  @override
  Future<UserListResult> search({
    String? query,
    int page = 1,
    int pageSize = 50,
  }) async {
    lastQuery = query;
    final q = query?.trim().toLowerCase() ?? '';
    final matches = q.isEmpty
        ? users
        : users
            .where(
              (user) =>
                  user.fullNameEn.toLowerCase().contains(q) ||
                  user.email.toLowerCase().contains(q),
            )
            .toList(growable: false);
    return UserListResult(
      items: matches,
      page: page,
      pageSize: pageSize,
      total: matches.length,
    );
  }
}

class _FakeReferenceDataRepository implements ReferenceDataRepository {
  @override
  Future<ReferenceCatalog> fetchCatalog() async {
    return const ReferenceCatalog(
      departments: [
        ReferenceDepartment(id: 'd1', code: 'OPS', nameEn: 'Operations'),
        ReferenceDepartment(id: 'd2', code: 'SEC', nameEn: 'Security'),
      ],
      roles: ['EMPLOYEE', 'MANAGER', 'SECURITY_ADMIN', 'SYSTEM_ADMIN'],
      notificationPriorities: ['LOW', 'NORMAL', 'HIGH', 'CRITICAL'],
    );
  }
}

Future<Widget> _appHarness({
  required AppUser user,
  required NotificationsRepository notifications,
  ReferenceDataRepository? reference,
}) async {
  final storage = InMemoryTokenStorage();
  await storage.writeTokens(accessToken: 'tok', refreshToken: 'ref');
  return ProviderScope(
    overrides: [
      tokenStorageProvider.overrideWithValue(storage),
      authRepositoryProvider.overrideWithValue(_FakeAuthRepository(user)),
      dashboardRepositoryProvider.overrideWithValue(_FakeDashboardRepository()),
      notificationsRepositoryProvider.overrideWithValue(notifications),
      referenceDataRepositoryProvider.overrideWithValue(
        reference ?? _FakeReferenceDataRepository(),
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

  group('api envelope', () {
    test('unwraps nested data map', () {
      final data = unwrapDataMap({
        'data': {'id': '1', 'titleEn': 'Hi'},
        'meta': {'traceId': 't'},
      });
      expect(data['id'], '1');
    });

    test('accepts already-unwrapped payloads', () {
      final data = unwrapDataMap({'accessToken': 'a', 'user': {}});
      expect(data['accessToken'], 'a');
    });
  });

  group('notification models', () {
    test('parses list item and localizes', () {
      final n = AppNotification.fromJson({
        'id': 'n1',
        'titleEn': 'Hello',
        'titleAr': 'مرحبا',
        'bodyEn': 'Body english text',
        'bodyAr': 'نص عربي',
        'priority': 'CRITICAL',
        'status': 'PUBLISHED',
        'audienceType': 'DEPARTMENT',
        'readAt': null,
        'createdAt': '2026-07-01T10:00:00.000Z',
      });
      expect(n.isUnread, isTrue);
      expect(n.priorityEnum, AppNotificationPriority.critical);
      expect(n.localizedTitle(arabic: true), 'مرحبا');
      expect(n.bodyPreview(arabic: false).contains('Body'), isTrue);
    });

    test('create request serializes audience filter', () {
      final json = const CreateNotificationRequest(
        titleEn: 'Ops briefing',
        bodyEn: 'Attend the morning briefing today.',
        priority: AppNotificationPriority.high,
        audienceType: AppAudienceType.department,
        audienceFilter: {
          'departmentCodes': ['OPS'],
        },
      ).toJson();
      expect(json['priority'], 'HIGH');
      expect(json['audienceType'], 'DEPARTMENT');
      expect(json['publishNow'], isTrue);
    });
  });

  group('NotificationCard', () {
    testWidgets('shows localized title and priority chip', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light(),
          home: Scaffold(
            body: NotificationCard(
              notification: _sampleNotification(priority: 'CRITICAL'),
              isArabic: false,
              onTap: () {},
            ),
          ),
        ),
      );
      expect(find.text('Security access available'), findsOneWidget);
      expect(find.text('Critical'), findsOneWidget);
      expect(find.byType(PriorityChip), findsOneWidget);
    });

    testWidgets('Arabic title when isArabic true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light(),
          home: Scaffold(
            body: NotificationCard(
              notification: _sampleNotification(),
              isArabic: true,
              onTap: () {},
            ),
          ),
        ),
      );
      expect(find.text('خدمة الصلاحيات متاحة'), findsOneWidget);
    });
  });

  group('NotificationsListScreen', () {
    testWidgets('renders items from API', (tester) async {
      final repo = _FakeNotificationsRepository(
        listResult: NotificationListResult(
          items: [_sampleNotification()],
          page: 1,
          pageSize: 20,
          total: 1,
        ),
      );
      await tester.pumpWidget(
        await _appHarness(user: _employee, notifications: repo),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();

      expect(find.byType(NotificationsListScreen), findsOneWidget);
      expect(find.text('Security access available'), findsOneWidget);
      expect(find.text('High'), findsWidgets);
      expect(find.byType(PriorityChip), findsOneWidget);
    });

    testWidgets('shows error and retry', (tester) async {
      final repo = _FakeNotificationsRepository(
        listError: ApiError.network('down'),
      );
      await tester.pumpWidget(
        await _appHarness(user: _employee, notifications: repo),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('employee has no create FAB and sees empty state', (tester) async {
      final repo = _FakeNotificationsRepository(
        listResult: const NotificationListResult(
          items: [],
          page: 1,
          pageSize: 20,
          total: 0,
        ),
      );
      await tester.pumpWidget(
        await _appHarness(user: _employee, notifications: repo),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsNothing);
      expect(find.text('No notifications yet'), findsOneWidget);
      expect(find.text('Create'), findsNothing);
    });

    testWidgets('admin shows create FAB', (tester) async {
      final repo = _FakeNotificationsRepository(
        listResult: const NotificationListResult(
          items: [],
          page: 1,
          pageSize: 20,
          total: 0,
        ),
      );
      await tester.pumpWidget(
        await _appHarness(user: _admin, notifications: repo),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Notifications'));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });

  group('router guards', () {
    testWidgets('employee redirected from create notification', (tester) async {
      final repo = _FakeNotificationsRepository();
      await tester.pumpWidget(
        await _appHarness(user: _employee, notifications: repo),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(Scaffold).first);
      GoRouter.of(context).go('/admin/notifications/create');
      await tester.pumpAndSettle();

      expect(find.byType(CreateNotificationScreen), findsNothing);
      expect(find.text('You do not have permission to view this screen.'), findsOneWidget);
    });
  });

  group('NotificationDetailScreen', () {
    testWidgets('mark as read calls repository', (tester) async {
      final repo = _FakeNotificationsRepository(
        detail: _sampleNotification(readAt: null),
      );
      final storage = InMemoryTokenStorage();
      await storage.writeTokens(accessToken: 'tok', refreshToken: 'ref');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tokenStorageProvider.overrideWithValue(storage),
            authRepositoryProvider
                .overrideWithValue(_FakeAuthRepository(_employee)),
            notificationsRepositoryProvider.overrideWithValue(repo),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.light(),
            home: const NotificationDetailScreen(notificationId: 'n1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Security access available'), findsOneWidget);
      expect(find.text('Mark as read'), findsOneWidget);
      await tester.tap(find.text('Mark as read'));
      await tester.pumpAndSettle();
      expect(repo.markReadCalls, 1);
    });

    testWidgets('admin sees stats section', (tester) async {
      final repo = _FakeNotificationsRepository(
        detail: _sampleNotification(readAt: DateTime.utc(2026, 7, 2)),
        stats: const NotificationStats(
          notificationId: 'n1',
          recipientCount: 10,
          deliveredCount: 10,
          readCount: 4,
          unreadCount: 6,
          readPercentage: 40,
        ),
      );
      final storage = InMemoryTokenStorage();
      await storage.writeTokens(accessToken: 'tok', refreshToken: 'ref');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tokenStorageProvider.overrideWithValue(storage),
            authRepositoryProvider.overrideWithValue(_FakeAuthRepository(_admin)),
            notificationsRepositoryProvider.overrideWithValue(repo),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.light(),
            home: const NotificationDetailScreen(notificationId: 'n1'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Notification stats'), findsOneWidget);
      expect(find.text('10'), findsWidgets);
    });
  });

  group('CreateNotificationScreen', () {
    testWidgets('admin form renders fields and publish action', (tester) async {
      final repo = _FakeNotificationsRepository();
      final storage = InMemoryTokenStorage();
      await storage.writeTokens(accessToken: 'tok', refreshToken: 'ref');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tokenStorageProvider.overrideWithValue(storage),
            authRepositoryProvider.overrideWithValue(_FakeAuthRepository(_admin)),
            notificationsRepositoryProvider.overrideWithValue(repo),
            referenceDataRepositoryProvider
                .overrideWithValue(_FakeReferenceDataRepository()),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.light(),
            home: const CreateNotificationScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Create Notification'), findsOneWidget);
      expect(find.text('Title (English)'), findsWidgets);
      expect(find.text('Body (English)'), findsWidgets);
      expect(find.text('Everyone'), findsOneWidget);

      final publishButton = find.byKey(const Key('publishNotificationButton'));
      await tester.scrollUntilVisible(
        publishButton,
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      expect(publishButton, findsOneWidget);
      expect(find.text('Publish'), findsOneWidget);
    });

    test('create request payload matches API contract', () {
      final request = CreateNotificationRequest(
        titleEn: 'Ops briefing',
        bodyEn: 'All operations staff must attend the 9 AM briefing.',
        priority: AppNotificationPriority.critical,
        audienceType: AppAudienceType.all,
        audienceFilter: const {'all': true},
        publishNow: true,
      );
      final json = request.toJson();
      expect(json['titleEn'], 'Ops briefing');
      expect(json['priority'], 'CRITICAL');
      expect(json['audienceType'], 'ALL');
      expect(json['audienceFilter'], {'all': true});
      expect(json['publishNow'], isTrue);
    });

    testWidgets('FV-02 validates required title and body before publish',
        (tester) async {
      final repo = _FakeNotificationsRepository();
      final storage = InMemoryTokenStorage();
      await storage.writeTokens(accessToken: 'tok', refreshToken: 'ref');
      await tester.binding.setSurfaceSize(const Size(800, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tokenStorageProvider.overrideWithValue(storage),
            authRepositoryProvider.overrideWithValue(_FakeAuthRepository(_admin)),
            notificationsRepositoryProvider.overrideWithValue(repo),
            referenceDataRepositoryProvider
                .overrideWithValue(_FakeReferenceDataRepository()),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.light(),
            home: const CreateNotificationScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final publishButton = find.byKey(const Key('publishNotificationButton'));
      await tester.scrollUntilVisible(
        publishButton,
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      await tester.tap(publishButton);
      await tester.pumpAndSettle();

      expect(find.text('This field is required.'), findsWidgets);
      expect(repo.lastCreate, isNull);
    });
  });

  group('CreateNotificationScreen USERS audience picker', () {
    Future<
        ({
          _FakeNotificationsRepository repo,
          _FakeUsersRepository users,
        })> pumpCreateScreen(
      WidgetTester tester, {
      _FakeUsersRepository? usersRepository,
    }) async {
      final repo = _FakeNotificationsRepository();
      final users = usersRepository ?? _FakeUsersRepository();
      final storage = InMemoryTokenStorage();
      await storage.writeTokens(accessToken: 'tok', refreshToken: 'ref');
      await tester.binding.setSurfaceSize(const Size(800, 1800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tokenStorageProvider.overrideWithValue(storage),
            authRepositoryProvider.overrideWithValue(_FakeAuthRepository(_admin)),
            notificationsRepositoryProvider.overrideWithValue(repo),
            referenceDataRepositoryProvider
                .overrideWithValue(_FakeReferenceDataRepository()),
            usersRepositoryProvider.overrideWithValue(users),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.light(),
            home: const CreateNotificationScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      return (repo: repo, users: users);
    }

    Future<void> selectUsersAudience(WidgetTester tester) async {
      await tester.tap(find.byType(DropdownButtonFormField<AppAudienceType>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Selected users').last);
      await tester.pumpAndSettle();
    }

    testWidgets('publishes with selected userIds (happy path)', (tester) async {
      final harness = await pumpCreateScreen(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title (English)'),
        'Targeted notice',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Body (English)'),
        'Direct message for selected users only.',
      );

      await selectUsersAudience(tester);
      expect(find.byKey(const Key('audienceUserSearchField')), findsOneWidget);
      expect(find.text('Noura Alharbi'), findsOneWidget);

      await tester.tap(find.byKey(const Key('audienceUser-u-emp')));
      await tester.pump();
      expect(find.text('1 selected'), findsOneWidget);

      final publishButton = find.byKey(const Key('publishNotificationButton'));
      await tester.scrollUntilVisible(
        publishButton,
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      await tester.tap(publishButton);
      // The submit flow keeps the button in a loading state while awaiting the
      // success dialog, so pump with bounded frames instead of pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final created = harness.repo.lastCreate;
      expect(created, isNotNull);
      expect(created!.audienceType, AppAudienceType.users);
      expect(created.audienceFilter, {
        'userIds': ['u-emp'],
      });
    });

    testWidgets('search filters and shows doc-19 empty state (edge)',
        (tester) async {
      final harness = await pumpCreateScreen(tester);

      await selectUsersAudience(tester);
      await tester.enterText(
        find.byKey(const Key('audienceUserSearchField')),
        'zzz-no-match',
      );
      await tester.pumpAndSettle();

      expect(harness.users.lastQuery, 'zzz-no-match');
      expect(find.text('No matching users found'), findsOneWidget);
    });

    testWidgets('blocks publish when no user selected (failure path)',
        (tester) async {
      final harness = await pumpCreateScreen(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title (English)'),
        'Targeted notice',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Body (English)'),
        'Direct message for selected users only.',
      );

      await selectUsersAudience(tester);

      final publishButton = find.byKey(const Key('publishNotificationButton'));
      await tester.scrollUntilVisible(
        publishButton,
        400,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();
      await tester.tap(publishButton);
      await tester.pumpAndSettle();

      expect(find.text('Select at least one audience value.'), findsOneWidget);
      expect(harness.repo.lastCreate, isNull);
    });
  });
}
