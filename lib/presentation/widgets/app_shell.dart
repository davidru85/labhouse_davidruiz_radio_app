import 'package:flutter/material.dart';

/// AppShell que actúa como contenedor persistente (placeholder).
class AppShell extends StatelessWidget {
  /// Crea una instancia de [AppShell] con un [child] de navegación.
  const AppShell({required this.child, super.key});

  /// El widget hijo correspondiente a la ruta actual.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: child);
  }
}
