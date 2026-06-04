import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/l10n/app_localizations.dart';
import 'package:radio_app/presentation/blocs/radio_player/radio_player_bloc.dart';
import 'package:radio_app/presentation/widgets/live_now_indicator.dart';
import 'package:radio_app/presentation/widgets/mini_player.dart';

class _FakeRadioPlayerBloc extends MockBloc<RadioPlayerEvent, RadioPlayerState>
    implements RadioPlayerBloc {}

RadioStation _station() => const RadioStation(
  stationUuid: 'uuid',
  name: 'Jazz FM',
  streamUrl: 'https://example.com/s',
  resolvedStreamUrl: 'https://example.com/s/resolved',
  favicon: null,
  homepage: null,
  tags: '',
  tagList: [],
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

/// Slice 4 — mini-player "Live Now" dot + Favorites progress bar (DESIGN.md
/// §Mini-Player).
void main() {
  late _FakeRadioPlayerBloc bloc;

  setUp(() => bloc = _FakeRadioPlayerBloc());

  Widget host({bool showProgress = false}) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: BlocProvider<RadioPlayerBloc>.value(
        value: bloc,
        child: MiniPlayerWidget(showProgress: showProgress),
      ),
    ),
  );

  void seed(RadioPlayerState state) => whenListen(
    bloc,
    const Stream<RadioPlayerState>.empty(),
    initialState: state,
  );

  testWidgets('shows the Live Now dot while playing', (tester) async {
    seed(RadioPlayerPlaying(_station(), null));

    await tester.pumpWidget(host());
    await tester.pump();

    expect(find.byType(LiveNowIndicator), findsOneWidget);
  });

  testWidgets('hides the Live Now dot while buffering', (tester) async {
    seed(RadioPlayerBuffering(_station()));

    await tester.pumpWidget(host());
    await tester.pump();

    expect(find.byType(LiveNowIndicator), findsNothing);
  });

  testWidgets('shows a progress bar only when asked (Favorites)', (
    tester,
  ) async {
    seed(RadioPlayerPlaying(_station(), null));

    await tester.pumpWidget(host());
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsNothing);

    await tester.pumpWidget(host(showProgress: true));
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });
}
