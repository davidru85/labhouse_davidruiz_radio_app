import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/presentation/routing/app_router.dart';
import 'package:radio_app/presentation/screens/favorites_screen.dart';
import 'package:radio_app/presentation/screens/stations_screen.dart';

import '../../support/shell_chrome_harness.dart';

void main() {
  group('App shell tab navigation (sub-task 9.9)', () {
    testWidgets('renders a Material BottomNavigationBar with two destinations '
        'on Android', (tester) async {
      final harness = buildShellChromeHarness(routerFactory: createAppRouter);

      await tester.pumpWidget(harness.widget);
      await tester.pumpAndSettle();

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      final bar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      expect(bar.items, hasLength(2));
    });

    testWidgets('renders a CupertinoTabBar on iOS', (tester) async {
      final harness = buildShellChromeHarness(
        routerFactory: createAppRouter,
        platform: TargetPlatform.iOS,
      );

      await tester.pumpWidget(harness.widget);
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoTabBar), findsOneWidget);
    });

    testWidgets('tapping the second tab switches the visible branch to '
        'Favorites', (tester) async {
      final harness = buildShellChromeHarness(routerFactory: createAppRouter);

      await tester.pumpWidget(harness.widget);
      await tester.pumpAndSettle();

      // Starts on the Stations branch.
      expect(find.byType(StationsScreen), findsOneWidget);

      final bar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );
      // Drive the tab bar's own callback to switch branches.
      bar.onTap!(1);
      await tester.pumpAndSettle();

      expect(find.byType(FavoritesScreen), findsOneWidget);
    });
  });
}
