import 'package:flutter/material.dart';

/// Persistent shell that wraps tab-based screens.
///
/// In Phase 9 this will evolve into the full AppShell with bottom navigation,
/// mini-player, and an IndexedStack. For now it is a minimal passthrough.
class AppShell extends StatelessWidget {
  /// Creates an instance of [AppShell] with the navigated [child].
  const AppShell({required this.child, super.key});

  /// The widget corresponding to the current route.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: child);
  }
}
