import 'package:flutter/material.dart';

/// Wraps the shell [child] in a BLoC scope owned by the routing shell.
///
/// The composition root supplies one of these so the shell can provide and
/// dispose its scoped BLoCs without the widget touching `GetIt` directly.
typedef ShellScopeBuilder = Widget Function(BuildContext context, Widget child);

/// Persistent shell that wraps tab-based screens.
///
/// In Phase 9 this will evolve into the full AppShell with bottom navigation,
/// mini-player, and an IndexedStack. For now it owns the BLoC scope shared by
/// its tabs (via [scopeBuilder]) and otherwise passes the route [child]
/// through.
class AppShell extends StatelessWidget {
  /// Creates an instance of [AppShell] with the navigated [child].
  const AppShell({required this.child, this.scopeBuilder, super.key});

  /// The widget corresponding to the current route.
  final Widget child;

  /// Builds the BLoC scope owned by the shell and shared across its tabs.
  ///
  /// When null the shell is a plain passthrough; the scope is disposed
  /// automatically when the shell leaves the widget tree.
  final ShellScopeBuilder? scopeBuilder;

  @override
  Widget build(BuildContext context) {
    final content = Scaffold(body: child);
    final builder = scopeBuilder;
    if (builder == null) {
      return content;
    }
    return builder(context, content);
  }
}
