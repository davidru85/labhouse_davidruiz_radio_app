import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/presentation/routing/app_router.dart';
import 'package:radio_app/presentation/widgets/glass_surface.dart';

import '../../support/shell_chrome_harness.dart';

/// Slice 2b — the shell tab bar is a translucent glass bar
/// (DESIGN.md §Bottom navigation).
void main() {
  testWidgets('wraps the bottom tab bar in a GlassSurface', (tester) async {
    final harness = buildShellChromeHarness(routerFactory: createAppRouter);

    await tester.pumpWidget(harness.widget);
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(GlassSurface),
        matching: find.byType(BottomNavigationBar),
      ),
      findsOneWidget,
    );
  });
}
