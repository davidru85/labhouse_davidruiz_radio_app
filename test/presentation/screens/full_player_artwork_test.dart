import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/l10n/app_localizations.dart';
import 'package:radio_app/presentation/blocs/radio_player/radio_player_bloc.dart';
import 'package:radio_app/presentation/screens/full_player_screen.dart';
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

/// Slices 3–4 (combined) — the full player shows its hero artwork; the
/// large-artwork sizing is the Slice 4 polish (DESIGN.md §3).
void main() {
  Widget harness(TargetPlatform platform, RadioPlayerState state) {
    final bloc = _FakeRadioPlayerBloc();
    whenListen(
      bloc,
      const Stream<RadioPlayerState>.empty(),
      initialState: state,
    );
    return MaterialApp(
      theme: ThemeData(platform: platform),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<RadioPlayerBloc>.value(
        value: bloc,
        child: const FullPlayerScreen(),
      ),
    );
  }

  testWidgets('renders the hero artwork on Android', (tester) async {
    await tester.pumpWidget(
      harness(TargetPlatform.android, RadioPlayerPlaying(_station(), null)),
    );
    await tester.pump();

    expect(find.byType(StationArtwork), findsOneWidget);
  });

  testWidgets('renders the hero artwork on iOS', (tester) async {
    await tester.pumpWidget(
      harness(TargetPlatform.iOS, RadioPlayerPlaying(_station(), null)),
    );
    await tester.pump();

    expect(find.byType(StationArtwork), findsOneWidget);
  });
}
