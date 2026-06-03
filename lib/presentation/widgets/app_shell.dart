import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:radio_app/l10n/app_localizations.dart';
import 'package:radio_app/presentation/widgets/adaptive/platform_builder.dart';
import 'package:radio_app/presentation/widgets/mini_player.dart';
import 'package:radio_app/presentation/widgets/offline_banner.dart';

/// Wraps the shell [child] in a BLoC scope owned by the routing shell.
///
/// The composition root supplies one of these so the shell can provide and
/// dispose its scoped BLoCs without the widget touching `GetIt` directly.
typedef ShellScopeBuilder = Widget Function(BuildContext context, Widget child);

/// Persistent shell that wraps the tab-based screens.
///
/// When a [navigationShell] is supplied (the routed configuration) the shell
/// renders the full app chrome: a global [OfflineBanner], the tab content kept
/// alive in the `StatefulShellRoute` IndexedStack, a [MiniPlayerWidget] that
/// navigates to the full player on tap, and a platform-adaptive tab bar
/// (`BottomNavigationBar` on Android, `CupertinoTabBar` on iOS).
///
/// Without a [navigationShell] (the unit-test configuration) it is a plain
/// passthrough that just hosts the BLoC scope and renders [child].
class AppShell extends StatelessWidget {
  /// Creates an instance of [AppShell].
  ///
  /// Supply [navigationShell] for the routed (chrome) configuration; supply
  /// [child] for the plain passthrough configuration used by unit tests. At
  /// least one is expected.
  const AppShell({
    this.child,
    this.navigationShell,
    this.scopeBuilder,
    super.key,
  }) : assert(
         child != null || navigationShell != null,
         'AppShell needs either a navigationShell (chrome) or a child '
         '(passthrough).',
       );

  /// The passthrough body, used only when [navigationShell] is null.
  final Widget? child;

  /// The stateful shell driving tab branches, when running under the router.
  final StatefulNavigationShell? navigationShell;

  /// Builds the BLoC scope owned by the shell and shared across its tabs.
  ///
  /// When null the shell is a plain passthrough; the scope is disposed
  /// automatically when the shell leaves the widget tree.
  final ShellScopeBuilder? scopeBuilder;

  @override
  Widget build(BuildContext context) {
    final shell = navigationShell;
    final content = shell == null
        ? Scaffold(body: child ?? const SizedBox.shrink())
        : _ChromedShell(navigationShell: shell);
    final builder = scopeBuilder;
    if (builder == null) {
      return content;
    }
    return builder(context, content);
  }
}

/// The full app chrome around the tab content: offline banner, mini-player,
/// and the platform-adaptive tab bar.
class _ChromedShell extends StatelessWidget {
  const _ChromedShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      // Re-tapping the active tab pops it to its initial location.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: navigationShell),
          MiniPlayerWidget(onTap: () => context.go('/player')),
        ],
      ),
      bottomNavigationBar: PlatformBuilder(
        material: (context) => BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: _goBranch,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.radio),
              label: l10n.navStations,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.favorite),
              label: l10n.navFavorites,
            ),
          ],
        ),
        cupertino: (context) => CupertinoTabBar(
          currentIndex: navigationShell.currentIndex,
          onTap: _goBranch,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.antenna_radiowaves_left_right),
              label: l10n.navStations,
            ),
            BottomNavigationBarItem(
              icon: const Icon(CupertinoIcons.heart_fill),
              label: l10n.navFavorites,
            ),
          ],
        ),
      ),
    );
  }
}
