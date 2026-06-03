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
      // The Live Now dot pulses indefinitely, so advance finite animations
      // (and route transitions) with an explicit pump rather than
      // pumpAndSettle, which would time out on the never-settling pulse.
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // The shell hosts the mini-player above the tabs.
      expect(find.byType(MiniPlayerWidget), findsOneWidget);
      expect(find.text('Jazz FM'), findsOneWidget);
      // Still on the shell, not the full player yet.
      expect(find.byType(FullPlayerScreen), findsNothing);
    });

    testWidgets('the interactive mini-player exposes a screen-reader label '
        '(per ADR-0006 / TECHNICAL_SPEC §10)', (tester) async {
      final station = buildStation('Jazz FM');
      final harness = buildShellChromeHarness(
        routerFactory: createAppRouter,
        playerState: RadioPlayerPlaying(station, null),
      );

      await tester.pumpWidget(harness.widget);
      // The Live Now dot pulses indefinitely, so advance finite animations
      // (and route transitions) with an explicit pump rather than
      // pumpAndSettle, which would time out on the never-settling pulse.
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.bySemanticsLabel(RegExp('Open player')), findsOneWidget);
    });

    testWidgets('the mini-player tap target meets the 48dp minimum touch '
        'size (per ADR-0006 / TECHNICAL_SPEC §10)', (tester) async {
      final station = buildStation('Jazz FM');
      final harness = buildShellChromeHarness(
        routerFactory: createAppRouter,
        playerState: RadioPlayerPlaying(station, null),
      );

      await tester.pumpWidget(harness.widget);
      // The Live Now dot pulses indefinitely, so advance finite animations
      // (and route transitions) with an explicit pump rather than
      // pumpAndSettle, which would time out on the never-settling pulse.
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      final inkWell = find.descendant(
        of: find.byType(MiniPlayerWidget),
        matching: find.byType(InkWell),
      );
      expect(tester.getSize(inkWell).height, greaterThanOrEqualTo(48));
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
      // The Live Now dot pulses indefinitely, so advance finite animations
      // (and route transitions) with an explicit pump rather than
      // pumpAndSettle, which would time out on the never-settling pulse.
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byType(MiniPlayerWidget));
      // The Live Now dot pulses indefinitely, so advance finite animations
      // (and route transitions) with an explicit pump rather than
      // pumpAndSettle, which would time out on the never-settling pulse.
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

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
      // The Live Now dot pulses indefinitely, so advance finite animations
      // (and route transitions) with an explicit pump rather than
      // pumpAndSettle, which would time out on the never-settling pulse.
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

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

      // The Live Now dot pulses indefinitely, so advance finite animations
      // (and route transitions) with an explicit pump rather than
      // pumpAndSettle, which would time out on the never-settling pulse.
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(FullPlayerScreen), findsOneWidget);
    });
  });
}
