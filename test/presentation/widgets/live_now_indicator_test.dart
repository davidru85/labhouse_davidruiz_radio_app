import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/presentation/theme/app_colors.dart';
import 'package:radio_app/presentation/widgets/live_now_indicator.dart';

/// Slice 4 — "Live Now" indicator (DESIGN.md §Mini-Player / §3).
void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('renders a playback-accent dot', (tester) async {
    await tester.pumpWidget(host(const LiveNowIndicator()));
    await tester.pump();

    final dot = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(LiveNowIndicator),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final decoration = dot.decoration as BoxDecoration;
    expect(decoration.color, AppColors.playbackAccent);
    expect(decoration.shape, BoxShape.circle);
  });

  testWidgets('pulses via an opacity animation', (tester) async {
    await tester.pumpWidget(host(const LiveNowIndicator()));
    await tester.pump();

    expect(
      find.descendant(
        of: find.byType(LiveNowIndicator),
        matching: find.byType(FadeTransition),
      ),
      findsOneWidget,
    );
  });

  testWidgets('optionally shows a label beside the dot', (tester) async {
    await tester.pumpWidget(host(const LiveNowIndicator(label: 'Live')));
    await tester.pump();

    expect(find.text('Live'), findsOneWidget);
  });
}
