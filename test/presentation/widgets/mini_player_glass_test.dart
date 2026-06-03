import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/l10n/app_localizations.dart';
import 'package:radio_app/presentation/blocs/radio_player/radio_player_bloc.dart';
import 'package:radio_app/presentation/widgets/glass_surface.dart';
import 'package:radio_app/presentation/widgets/mini_player.dart';

class _FakeRadioPlayerBloc extends MockBloc<RadioPlayerEvent, RadioPlayerState>
    implements RadioPlayerBloc {}

RadioStation _station(String name) => RadioStation(
  stationUuid: 'uuid-$name',
  name: name,
  streamUrl: 'https://example.com/$name',
  resolvedStreamUrl: 'https://example.com/$name/resolved',
  favicon: null,
  homepage: null,
  tags: '',
  tagList: const [],
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

/// Slice 2b — the mini-player is a glass card (DESIGN.md §Mini-Player).
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

  void seed(RadioPlayerState state) => whenListen(
    bloc,
    const Stream<RadioPlayerState>.empty(),
    initialState: state,
  );

  testWidgets('renders the active bar inside a GlassSurface', (tester) async {
    seed(RadioPlayerPlaying(_station('Jazz FM'), null));

    await tester.pumpWidget(host());
    // The Live Now dot pulses indefinitely, so settle finite animations with
    // an explicit pump rather than pumpAndSettle (which would time out).
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Jazz FM'), findsOneWidget);
    expect(find.byType(GlassSurface), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(GlassSurface),
        matching: find.text('Jazz FM'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows no glass card while idle', (tester) async {
    seed(const RadioPlayerInitial());

    await tester.pumpWidget(host());
    await tester.pumpAndSettle();

    expect(find.byType(GlassSurface), findsNothing);
  });
}
