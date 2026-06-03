import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/presentation/blocs/radio_player/radio_player_bloc.dart';
import 'package:radio_app/presentation/routing/app_router.dart';
import 'package:radio_app/presentation/screens/full_player_screen.dart';
import 'package:radio_app/presentation/widgets/mini_player.dart';

import '../../support/shell_chrome_harness.dart';

void main() {
  group('Full player navigation from the mini-player (sub-task 9.7)', () {
    testWidgets('the mini-player is mounted in the shell while a station '
        'is playing', (tester) async {
      final station = buildStation('Jazz FM');
      final harness = buildShellChromeHarness(
        routerFactory: createAppRouter,
        playerState: RadioPlayerPlaying(station, null),
      );

      await tester.pumpWidget(harness.widget);
      await tester.pumpAndSettle();

      // The shell hosts the mini-player above the tabs.
      expect(find.byType(MiniPlayerWidget), findsOneWidget);
      expect(find.text('Jazz FM'), findsOneWidget);
      // Still on the shell, not the full player yet.
      expect(find.byType(FullPlayerScreen), findsNothing);
    });

    testWidgets('tapping the mini-player navigates to the FullPlayerScreen', (
      tester,
    ) async {
      final station = buildStation('Jazz FM');
      final harness = buildShellChromeHarness(
        routerFactory: createAppRouter,
        playerState: RadioPlayerPlaying(station, null),
      );

      await tester.pumpWidget(harness.widget);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(MiniPlayerWidget));
      await tester.pumpAndSettle();

      expect(find.byType(FullPlayerScreen), findsOneWidget);
    });
  });

  group('Full player slide transition (sub-task 9.8)', () {
    testWidgets('the /player route enters with a bottom-to-top vertical '
        'slide', (tester) async {
      final station = buildStation('Jazz FM');
      final harness = buildShellChromeHarness(
        routerFactory: createAppRouter,
        playerState: RadioPlayerPlaying(station, null),
      );

      await tester.pumpWidget(harness.widget);
      await tester.pumpAndSettle();

      harness.router.go('/player');
      await tester.pump(); // start the route transition
      await tester.pump(const Duration(milliseconds: 50));

      // The incoming page is wrapped in a SlideTransition that begins below
      // the viewport (positive dy) and slides up to rest — a vertical,
      // bottom-to-top transition, not the default fade/horizontal one.
      final slideFinder = find.ancestor(
        of: find.byType(FullPlayerScreen),
        matching: find.byType(SlideTransition),
      );
      expect(slideFinder, findsWidgets);

      final slide = tester.widgetList<SlideTransition>(slideFinder).first;
      expect(
        slide.position.value.dy,
        greaterThan(0),
        reason: 'the full player should slide in from the bottom',
      );
      expect(slide.position.value.dx, 0);

      await tester.pumpAndSettle();
      expect(find.byType(FullPlayerScreen), findsOneWidget);
    });
  });
}
