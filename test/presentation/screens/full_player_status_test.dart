import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/l10n/app_localizations.dart';
import 'package:radio_app/presentation/blocs/radio_player/radio_player_bloc.dart';
import 'package:radio_app/presentation/screens/full_player_screen.dart';

class _FakeRadioPlayerBloc extends MockBloc<RadioPlayerEvent, RadioPlayerState>
    implements RadioPlayerBloc {}

RadioStation _station() => const RadioStation(
  stationUuid: 'uuid',
  name: 'Jazz FM',
  streamUrl: 'https://example.com/s',
  resolvedStreamUrl: 'https://example.com/s/resolved',
  favicon: null,
  homepage: null,
  tags: 'Jazz',
  tagList: ['Jazz'],
  country: 'Germany',
  countryCode: 'DE',
  language: null,
  codec: null,
  bitrate: null,
  votes: 0,
  clickCount: 0,
  lastCheckOk: true,
  isHLS: false,
);

/// Slice 4 — the full player shows a Live/Buffering status line (DESIGN.md §3).
void main() {
  Widget harness(RadioPlayerState state) {
    final bloc = _FakeRadioPlayerBloc();
    whenListen(
      bloc,
      const Stream<RadioPlayerState>.empty(),
      initialState: state,
    );
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<RadioPlayerBloc>.value(
        value: bloc,
        child: const FullPlayerScreen(),
      ),
    );
  }

  AppLocalizations l10nOf(WidgetTester tester) =>
      AppLocalizations.of(tester.element(find.byType(FullPlayerScreen)));

  testWidgets('reads "Live" while playing', (tester) async {
    await tester.pumpWidget(harness(RadioPlayerPlaying(_station(), null)));
    await tester.pump();

    expect(find.text(l10nOf(tester).playerLiveStatus), findsOneWidget);
  });

  testWidgets('reads "Live" while paused', (tester) async {
    await tester.pumpWidget(harness(RadioPlayerPaused(_station())));
    await tester.pump();

    expect(find.text(l10nOf(tester).playerLiveStatus), findsOneWidget);
  });

  testWidgets('reads the buffering status while buffering', (tester) async {
    await tester.pumpWidget(harness(RadioPlayerBuffering(_station())));
    await tester.pump();

    expect(find.text(l10nOf(tester).playerBufferingStatus), findsOneWidget);
  });
}
