import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:radio_app/presentation/routing/app_router.dart';
import 'package:radio_app/presentation/screens/favorites_screen.dart';
import 'package:radio_app/presentation/screens/full_player_screen.dart';
import 'package:radio_app/presentation/screens/stations_screen.dart';
import 'package:radio_app/presentation/widgets/app_shell.dart';

void main() {
  group('createAppRouter', () {
    late GoRouter router;

    setUp(() {
      router = createAppRouter();
    });

    testWidgets('initial location is /stations and renders StationsScreen '
        'inside AppShell', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(find.byType(StationsScreen), findsOneWidget);
      expect(find.byType(AppShell), findsOneWidget);
    });

    testWidgets(
      'navigating to /favorites renders FavoritesScreen inside AppShell',
      (tester) async {
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        router.go('/favorites');
        await tester.pumpAndSettle();

        expect(find.byType(FavoritesScreen), findsOneWidget);
        expect(find.byType(AppShell), findsOneWidget);
      },
    );

    testWidgets('navigating to /player renders FullPlayerScreen '
        'without AppShell', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      router.go('/player');
      await tester.pumpAndSettle();

      expect(find.byType(FullPlayerScreen), findsOneWidget);
      expect(find.byType(AppShell), findsNothing);
    });

    testWidgets('navigating back from /player to /stations restores AppShell', (
      tester,
    ) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      router.go('/player');
      await tester.pumpAndSettle();

      router.go('/stations');
      await tester.pumpAndSettle();

      expect(find.byType(StationsScreen), findsOneWidget);
      expect(find.byType(AppShell), findsOneWidget);
      expect(find.byType(FullPlayerScreen), findsNothing);
    });
  });
}
