import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/l10n/app_localizations.dart';
import 'package:radio_app/presentation/blocs/radio_player/radio_player_bloc.dart';
import 'package:radio_app/presentation/widgets/mini_player.dart';
import 'package:radio_app/presentation/widgets/station_artwork.dart';

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

/// Slice 3 — the mini-player shows compact artwork (DESIGN.md §Mini-Player).
void main() {
  late _FakeRadioPlayerBloc bloc;

  setUp(() => bloc = _FakeRadioPlayerBloc());

  Widget host() => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: BlocProvider<RadioPlayerBloc>.value(
        value: bloc,
        child: const MiniPlayerWidget(),
      ),
    ),
  );

  testWidgets('shows artwork while a station is playing', (tester) async {
    whenListen(
      bloc,
      const Stream<RadioPlayerState>.empty(),
      initialState: RadioPlayerPlaying(_station(), null),
    );

    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(find.byType(StationArtwork), findsOneWidget);
  });
}
