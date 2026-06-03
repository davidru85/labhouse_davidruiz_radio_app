import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:radio_app/presentation/screens/favorites_screen.dart';
import 'package:radio_app/presentation/screens/full_player_screen.dart';
import 'package:radio_app/presentation/screens/stations_screen.dart';
import 'package:radio_app/presentation/widgets/app_shell.dart';

/// Creates a new [GoRouter] for the application.
///
/// Using a factory avoids sharing a single stateful router across tests and
/// allows callers to inject a [navigatorKey] when needed (e.g. for testing).
///
/// [shellScopeBuilder] lets the composition root install the BLoC scope owned
/// by the shell; the shell disposes it when navigating to an out-of-shell
/// route such as `/player`.
GoRouter createAppRouter({
  GlobalKey<NavigatorState>? navigatorKey,
  ShellScopeBuilder? shellScopeBuilder,
}) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/stations',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(scopeBuilder: shellScopeBuilder, child: navigationShell),
        branches: [
          // Both branches preload so the IndexedStack mounts every tab up
          // front, keeping their navigators (and scroll state) alive from the
          // first frame rather than only after a tab is first visited.
          StatefulShellBranch(
            preload: true,
            routes: [
              GoRoute(
                path: '/stations',
                builder: (context, state) => const StationsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            preload: true,
            routes: [
              GoRoute(
                path: '/favorites',
                builder: (context, state) => const FavoritesScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/player',
        builder: (context, state) => const FullPlayerScreen(),
      ),
    ],
  );
}
