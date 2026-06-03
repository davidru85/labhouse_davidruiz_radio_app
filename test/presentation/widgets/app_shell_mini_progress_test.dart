import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/presentation/blocs/radio_player/radio_player_bloc.dart';
import 'package:radio_app/presentation/routing/app_router.dart';
import 'package:radio_app/presentation/widgets/mini_player.dart';

import '../../support/shell_chrome_harness.dart';

/// Slice 4 — the mini-player progress bar appears on Favorites only
/// (DESIGN.md §Mini-Player).
void main() {
  testWidgets('no mini-player progress bar on the Stations tab', (
    tester,
  ) async {
    final harness = buildShellChromeHarness(
      routerFactory: createAppRouter,
      playerState: RadioPlayerPlaying(buildStation('Jazz FM'), null),
    );

    await tester.pumpWidget(harness.widget);
    await tester.pump();

    final miniPlayer = tester.widget<MiniPlayerWidget>(
      find.byType(MiniPlayerWidget),
    );
    expect(miniPlayer.showProgress, isFalse);
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('shows the mini-player progress bar on the Favorites tab', (
    tester,
  ) async {
    final harness = buildShellChromeHarness(
      routerFactory: createAppRouter,
      playerState: RadioPlayerPlaying(buildStation('Jazz FM'), null),
    );

    await tester.pumpWidget(harness.widget);
    await tester.pump();

    // Switch to the Favorites branch. (Avoid pumpAndSettle: the Live Now dot
    // and the indeterminate progress bar animate indefinitely.)
    final bar = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    bar.onTap!(1);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final miniPlayer = tester.widget<MiniPlayerWidget>(
      find.byType(MiniPlayerWidget),
    );
    expect(miniPlayer.showProgress, isTrue);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });
}
