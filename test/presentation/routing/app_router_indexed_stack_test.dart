import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:radio_app/presentation/routing/app_router.dart';
import 'package:radio_app/presentation/screens/favorites_screen.dart';
import 'package:radio_app/presentation/screens/stations_screen.dart';
import 'package:radio_app/presentation/widgets/app_shell.dart';

import '../../support/router_test_harness.dart';

void main() {
  group('createAppRouter — IndexedStack shell (sub-task 9.3)', () {
    late GoRouter router;

    setUp(() {
      router = createAppRouter();
    });

    testWidgets('shell hosts an IndexedStack so every tab branch is built '
        'up front', (tester) async {
      await tester.pumpWidget(buildRouterHarness(router));
      await tester.pumpAndSettle();

      // The StatefulShellRoute.indexedStack builds all branch navigators
      // eagerly inside a single IndexedStack owned by the shell.
      expect(find.byType(AppShell), findsOneWidget);
      expect(find.byType(IndexedStack), findsOneWidget);
    });

    testWidgets('both tab screens stay alive in the tree while on /stations', (
      tester,
    ) async {
      await tester.pumpWidget(buildRouterHarness(router));
      await tester.pumpAndSettle();

      // StationsScreen is the visible branch...
      expect(find.byType(StationsScreen), findsOneWidget);
      // ...and FavoritesScreen is kept alive offstage by the IndexedStack,
      // rather than being torn down like a plain ShellRoute child swap.
      expect(find.byType(FavoritesScreen, skipOffstage: false), findsOneWidget);
    });

    testWidgets('both tab screens stay alive in the tree while on /favorites', (
      tester,
    ) async {
      await tester.pumpWidget(buildRouterHarness(router));
      await tester.pumpAndSettle();

      router.go('/favorites');
      await tester.pumpAndSettle();

      expect(find.byType(FavoritesScreen), findsOneWidget);
      expect(find.byType(StationsScreen, skipOffstage: false), findsOneWidget);
    });
  });
}
