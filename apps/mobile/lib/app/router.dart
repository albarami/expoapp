import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/app_user.dart';
import '../core/auth/session_controller.dart';
import '../core/providers.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../l10n/app_localizations.dart';
import '../shared/widgets/foundation_placeholder_screen.dart';
import 'app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

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
    initialLocation: '/login',
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(sessionControllerProvider);
      final loggingIn = state.matchedLocation == '/login';
      final loc = state.matchedLocation;

      if (session.status == SessionStatus.unknown) {
        return null;
      }

      if (!session.isAuthenticated) {
        return loggingIn ? null : '/login';
      }

      if (loggingIn) {
        return '/';
      }

      final user = session.user;
      if (user != null && !_isAllowed(user.role, loc)) {
        return '/';
      }

      return null;
    },
    routes: [
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
            builder: (context, state) {
              final l10n = AppLocalizations.of(context);
              return FoundationPlaceholderScreen(title: l10n.dashboard);
            },
          ),
          GoRoute(
            path: '/notifications',
            name: 'notifications',
            builder: (context, state) {
              final l10n = AppLocalizations.of(context);
              return FoundationPlaceholderScreen(title: l10n.notifications);
            },
            routes: [
              GoRoute(
                path: ':id',
                name: 'notification-detail',
                builder: (context, state) {
                  final l10n = AppLocalizations.of(context);
                  return FoundationPlaceholderScreen(
                    title: l10n.notifications,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/admin/notifications/create',
            name: 'create-notification',
            builder: (context, state) {
              final l10n = AppLocalizations.of(context);
              return FoundationPlaceholderScreen(
                title: l10n.createNotification,
              );
            },
          ),
          GoRoute(
            path: '/requests',
            name: 'requests',
            builder: (context, state) {
              final l10n = AppLocalizations.of(context);
              return FoundationPlaceholderScreen(title: l10n.requests);
            },
            routes: [
              GoRoute(
                path: 'new',
                name: 'request-new',
                builder: (context, state) {
                  final l10n = AppLocalizations.of(context);
                  return FoundationPlaceholderScreen(
                    title: l10n.newAccessRequest,
                  );
                },
              ),
              GoRoute(
                path: ':id',
                name: 'request-detail',
                builder: (context, state) {
                  final l10n = AppLocalizations.of(context);
                  return FoundationPlaceholderScreen(title: l10n.requests);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/approvals',
            name: 'approvals',
            builder: (context, state) {
              final l10n = AppLocalizations.of(context);
              return FoundationPlaceholderScreen(title: l10n.approvals);
            },
          ),
          GoRoute(
            path: '/audit',
            name: 'audit',
            builder: (context, state) {
              final l10n = AppLocalizations.of(context);
              return FoundationPlaceholderScreen(title: l10n.auditLogs);
            },
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfilePlaceholderScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) {
              final l10n = AppLocalizations.of(context);
              return FoundationPlaceholderScreen(title: l10n.settings);
            },
          ),
        ],
      ),
    ],
  );
});

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
    final tabs = _tabsFor(user?.role, l10n);
    final selected = _selectedIndex(location, tabs);
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

class _ShellTab {
  const _ShellTab({
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

List<_ShellTab> _tabsFor(AppRole? role, AppLocalizations l10n) {
  switch (role) {
    case AppRole.manager:
      return [
        _ShellTab(
          path: '/',
          label: l10n.home,
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
        ),
        _ShellTab(
          path: '/notifications',
          label: l10n.notifications,
          icon: Icons.notifications_outlined,
          selectedIcon: Icons.notifications,
          matchPrefix: '/notifications',
        ),
        _ShellTab(
          path: '/requests',
          label: l10n.requests,
          icon: Icons.assignment_outlined,
          selectedIcon: Icons.assignment,
          matchPrefix: '/requests',
        ),
        _ShellTab(
          path: '/approvals',
          label: l10n.approvals,
          icon: Icons.fact_check_outlined,
          selectedIcon: Icons.fact_check,
          matchPrefix: '/approvals',
        ),
        _ShellTab(
          path: '/profile',
          label: l10n.profile,
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          matchPrefix: '/profile',
        ),
      ];
    case AppRole.securityAdmin:
      return [
        _ShellTab(
          path: '/',
          label: l10n.home,
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
        ),
        _ShellTab(
          path: '/notifications',
          label: l10n.notifications,
          icon: Icons.notifications_outlined,
          selectedIcon: Icons.notifications,
          matchPrefix: '/notifications',
        ),
        _ShellTab(
          path: '/approvals',
          label: l10n.security,
          icon: Icons.security_outlined,
          selectedIcon: Icons.security,
          matchPrefix: '/approvals',
        ),
        _ShellTab(
          path: '/audit',
          label: l10n.auditLogs,
          icon: Icons.history_outlined,
          selectedIcon: Icons.history,
          matchPrefix: '/audit',
        ),
        _ShellTab(
          path: '/profile',
          label: l10n.profile,
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          matchPrefix: '/profile',
        ),
      ];
    case AppRole.systemAdmin:
      return [
        _ShellTab(
          path: '/',
          label: l10n.home,
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
        ),
        _ShellTab(
          path: '/notifications',
          label: l10n.notifications,
          icon: Icons.notifications_outlined,
          selectedIcon: Icons.notifications,
          matchPrefix: '/notifications',
        ),
        _ShellTab(
          path: '/admin/notifications/create',
          label: l10n.create,
          icon: Icons.add_circle_outline,
          selectedIcon: Icons.add_circle,
          matchPrefix: '/admin',
        ),
        _ShellTab(
          path: '/audit',
          label: l10n.auditLogs,
          icon: Icons.history_outlined,
          selectedIcon: Icons.history,
          matchPrefix: '/audit',
        ),
        _ShellTab(
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
        _ShellTab(
          path: '/',
          label: l10n.home,
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
        ),
        _ShellTab(
          path: '/notifications',
          label: l10n.notifications,
          icon: Icons.notifications_outlined,
          selectedIcon: Icons.notifications,
          matchPrefix: '/notifications',
        ),
        _ShellTab(
          path: '/requests',
          label: l10n.requests,
          icon: Icons.assignment_outlined,
          selectedIcon: Icons.assignment,
          matchPrefix: '/requests',
        ),
        _ShellTab(
          path: '/profile',
          label: l10n.profile,
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          matchPrefix: '/profile',
        ),
      ];
  }
}

int _selectedIndex(String location, List<_ShellTab> tabs) {
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
