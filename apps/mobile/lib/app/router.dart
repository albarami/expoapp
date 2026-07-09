import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/app_user.dart';
import '../core/auth/session_controller.dart';
import '../core/providers.dart';
import '../features/access_requests/presentation/screens/access_request_detail_screen.dart';
import '../features/access_requests/presentation/screens/access_requests_list_screen.dart';
import '../features/access_requests/presentation/screens/create_access_request_screen.dart';
import '../features/approvals/presentation/screens/approval_detail_screen.dart';
import '../features/approvals/presentation/screens/approvals_list_screen.dart';
import '../features/audit/presentation/screens/audit_logs_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/notifications/presentation/screens/create_notification_screen.dart';
import '../features/notifications/presentation/screens/notification_detail_screen.dart';
import '../features/notifications/presentation/screens/notifications_list_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../l10n/app_localizations.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>(debugLabel: 'scaffoldMessenger');

/// Listenable bridge so GoRouter rebuilds on session changes.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Ref ref) {
    _subscription = ref.listen<SessionState>(
      sessionControllerProvider,
      (previous, next) => notifyListeners(),
    );
  }

  late final ProviderSubscription<SessionState> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = GoRouterRefreshStream(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(sessionControllerProvider);
      final loc = state.matchedLocation;
      final atSplash = loc == '/splash';
      final loggingIn = loc == '/login';

      if (session.status == SessionStatus.unknown) {
        return atSplash ? null : '/splash';
      }

      if (session.status == SessionStatus.expired ||
          !session.isAuthenticated) {
        if (loggingIn) return null;
        return '/login';
      }

      // Authenticated
      if (loggingIn || atSplash) {
        return '/';
      }

      final user = session.user;
      if (user != null && !_isAllowed(user.role, loc)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final messenger = _scaffoldMessengerKey.currentState;
          final l10n = AppLocalizations.of(context);
          messenger?.showSnackBar(
            SnackBar(content: Text(l10n.unauthorizedMessage)),
          );
        });
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return RoleAwareShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/notifications',
            name: 'notifications',
            builder: (context, state) => const NotificationsListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                name: 'notification-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return NotificationDetailScreen(notificationId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/admin/notifications/create',
            name: 'create-notification',
            builder: (context, state) => const CreateNotificationScreen(),
          ),
          GoRoute(
            path: '/requests',
            name: 'requests',
            builder: (context, state) => const AccessRequestsListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'request-new',
                builder: (context, state) => const CreateAccessRequestScreen(),
              ),
              GoRoute(
                path: ':id',
                name: 'request-detail',
                builder: (context, state) {
                  final id = state.pathParameters['id'] ?? '';
                  return AccessRequestDetailScreen(requestId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/approvals',
            name: 'approvals',
            builder: (context, state) => const ApprovalsListScreen(),
            routes: [
              GoRoute(
                path: ':taskId',
                name: 'approval-detail',
                builder: (context, state) {
                  final taskId = state.pathParameters['taskId'] ?? '';
                  return ApprovalDetailScreen(taskId: taskId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/audit',
            name: 'audit',
            builder: (context, state) => const AuditLogsScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});

/// Root scaffold messenger key for unauthorized snackbars from redirects.
GlobalKey<ScaffoldMessengerState> get appScaffoldMessengerKey =>
    _scaffoldMessengerKey;

bool _isAllowed(AppRole role, String location) {
  if (location.startsWith('/audit')) {
    return role == AppRole.securityAdmin || role == AppRole.systemAdmin;
  }
  if (location.startsWith('/admin/')) {
    return role == AppRole.systemAdmin || role == AppRole.securityAdmin;
  }
  if (location.startsWith('/approvals')) {
    return role == AppRole.manager ||
        role == AppRole.securityAdmin ||
        role == AppRole.systemAdmin;
  }
  return true;
}

/// Shell that maps role tabs to documented routes via [context.go].
class RoleAwareShell extends ConsumerWidget {
  const RoleAwareShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(sessionControllerProvider).user;
    final location = GoRouterState.of(context).uri.path;
    final tabs = tabsForRole(user?.role, l10n);
    final selected = selectedTabIndex(location, tabs);
    final width = MediaQuery.sizeOf(context).width;
    final useRail = width >= 900;

    void onSelect(int index) {
      context.go(tabs[index].path);
    }

    if (useRail) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selected,
              onDestinationSelected: onSelect,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final tab in tabs)
                  NavigationRailDestination(
                    icon: Icon(tab.icon),
                    selectedIcon: Icon(tab.selectedIcon),
                    label: Text(tab.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: onSelect,
        destinations: [
          for (final tab in tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.selectedIcon),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}

class ShellTab {
  const ShellTab({
    required this.path,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.matchPrefix,
  });

  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String? matchPrefix;
}

/// Role → bottom-nav / rail destinations (testable).
List<ShellTab> tabsForRole(AppRole? role, AppLocalizations l10n) {
  switch (role) {
    case AppRole.manager:
      return [
        ShellTab(
          path: '/',
          label: l10n.home,
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
        ),
        ShellTab(
          path: '/notifications',
          label: l10n.notifications,
          icon: Icons.notifications_outlined,
          selectedIcon: Icons.notifications,
          matchPrefix: '/notifications',
        ),
        ShellTab(
          path: '/requests',
          label: l10n.requests,
          icon: Icons.assignment_outlined,
          selectedIcon: Icons.assignment,
          matchPrefix: '/requests',
        ),
        ShellTab(
          path: '/approvals',
          label: l10n.approvals,
          icon: Icons.fact_check_outlined,
          selectedIcon: Icons.fact_check,
          matchPrefix: '/approvals',
        ),
        ShellTab(
          path: '/profile',
          label: l10n.profile,
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          matchPrefix: '/profile',
        ),
      ];
    case AppRole.securityAdmin:
      return [
        ShellTab(
          path: '/',
          label: l10n.home,
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
        ),
        ShellTab(
          path: '/notifications',
          label: l10n.notifications,
          icon: Icons.notifications_outlined,
          selectedIcon: Icons.notifications,
          matchPrefix: '/notifications',
        ),
        ShellTab(
          path: '/approvals',
          label: l10n.security,
          icon: Icons.security_outlined,
          selectedIcon: Icons.security,
          matchPrefix: '/approvals',
        ),
        ShellTab(
          path: '/audit',
          label: l10n.auditLogs,
          icon: Icons.history_outlined,
          selectedIcon: Icons.history,
          matchPrefix: '/audit',
        ),
        ShellTab(
          path: '/profile',
          label: l10n.profile,
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          matchPrefix: '/profile',
        ),
      ];
    case AppRole.systemAdmin:
      return [
        ShellTab(
          path: '/',
          label: l10n.home,
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
        ),
        ShellTab(
          path: '/notifications',
          label: l10n.notifications,
          icon: Icons.notifications_outlined,
          selectedIcon: Icons.notifications,
          matchPrefix: '/notifications',
        ),
        ShellTab(
          path: '/admin/notifications/create',
          label: l10n.create,
          icon: Icons.add_circle_outline,
          selectedIcon: Icons.add_circle,
          matchPrefix: '/admin',
        ),
        ShellTab(
          path: '/audit',
          label: l10n.auditLogs,
          icon: Icons.history_outlined,
          selectedIcon: Icons.history,
          matchPrefix: '/audit',
        ),
        ShellTab(
          path: '/profile',
          label: l10n.profile,
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          matchPrefix: '/profile',
        ),
      ];
    case AppRole.employee:
    case null:
      return [
        ShellTab(
          path: '/',
          label: l10n.home,
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
        ),
        ShellTab(
          path: '/notifications',
          label: l10n.notifications,
          icon: Icons.notifications_outlined,
          selectedIcon: Icons.notifications,
          matchPrefix: '/notifications',
        ),
        ShellTab(
          path: '/requests',
          label: l10n.requests,
          icon: Icons.assignment_outlined,
          selectedIcon: Icons.assignment,
          matchPrefix: '/requests',
        ),
        ShellTab(
          path: '/profile',
          label: l10n.profile,
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          matchPrefix: '/profile',
        ),
      ];
  }
}

int selectedTabIndex(String location, List<ShellTab> tabs) {
  for (var i = 0; i < tabs.length; i++) {
    final tab = tabs[i];
    final prefix = tab.matchPrefix;
    if (prefix != null && location.startsWith(prefix)) {
      return i;
    }
    if (tab.path == '/' && (location == '/' || location.isEmpty)) {
      return i;
    }
  }
  return 0;
}
