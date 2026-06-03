import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:radio_app/domain/entities/now_playing_info.dart';
import 'package:radio_app/l10n/app_localizations.dart';
import 'package:radio_app/presentation/blocs/connectivity/connectivity_bloc.dart';
import 'package:radio_app/presentation/blocs/radio_player/radio_player_bloc.dart';
import 'package:radio_app/presentation/blocs/stations/stations_bloc.dart';
import 'package:radio_app/presentation/screens/full_player_screen.dart';
import 'package:radio_app/presentation/screens/stations_screen.dart';

import '../../support/shell_chrome_harness.dart';

class _FakeStationsBloc extends MockBloc<StationsEvent, StationsState>
    implements StationsBloc {}

class _FakeRadioPlayerBloc extends MockBloc<RadioPlayerEvent, RadioPlayerState>
    implements RadioPlayerBloc {}

class _FakeConnectivityBloc
    extends MockBloc<ConnectivityEvent, ConnectivityState>
    implements ConnectivityBloc {}

void main() {
  setUpAll(() {
    registerFallbackValue(buildStation('fallback'));
    registerFallbackValue(const RadioPlayerStopRequested());
  });

  group('Play-on-tap from the stations list (Step 5 wiring)', () {
    testWidgets('tapping a station row requests playback of that station', (
      tester,
    ) async {
      final station = buildStation('Jazz FM');
      final stationsBloc = _FakeStationsBloc();
      whenListen(
        stationsBloc,
        const Stream<StationsState>.empty(),
        initialState: StationsState(
          status: StationsStatus.success,
          stations: [station],
        ),
      );
      final playerBloc = _FakeRadioPlayerBloc();
      whenListen(
        playerBloc,
        const Stream<RadioPlayerState>.empty(),
        initialState: const RadioPlayerInitial(),
      );
      final connectivityBloc = _FakeConnectivityBloc();
      whenListen(
        connectivityBloc,
        const Stream<ConnectivityState>.empty(),
        initialState: const ConnectivityOnline(),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MultiBlocProvider(
            providers: [
              BlocProvider<StationsBloc>.value(value: stationsBloc),
              BlocProvider<RadioPlayerBloc>.value(value: playerBloc),
              BlocProvider<ConnectivityBloc>.value(value: connectivityBloc),
            ],
            child: const StationsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Jazz FM'));
      await tester.pump();

      verify(() => playerBloc.add(RadioPlayerPlayRequested(station))).called(1);
    });
  });

  group('FullPlayerScreen (sub-tasks 9.7 / 9.12)', () {
    late _FakeRadioPlayerBloc playerBloc;

    setUp(() => playerBloc = _FakeRadioPlayerBloc());

    Widget host() => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<RadioPlayerBloc>.value(
        value: playerBloc,
        child: const FullPlayerScreen(),
      ),
    );

    void seed(RadioPlayerState state) => whenListen(
      playerBloc,
      const Stream<RadioPlayerState>.empty(),
      initialState: state,
    );

    testWidgets('renders the now-playing track and artist when present', (
      tester,
    ) async {
      seed(
        RadioPlayerPlaying(
          buildStation('Jazz FM'),
          const NowPlayingInfo(
            raw: 'Daft Punk - Around the World',
            artist: 'Daft Punk',
            track: 'Around the World',
          ),
        ),
      );

      await tester.pumpWidget(host());
      await tester.pumpAndSettle();

      expect(find.text('Around the World'), findsOneWidget);
      expect(find.text('Daft Punk'), findsOneWidget);
    });

    testWidgets('falls back to the station name when no now-playing metadata', (
      tester,
    ) async {
      seed(RadioPlayerPlaying(buildStation('Jazz FM'), null));

      await tester.pumpWidget(host());
      await tester.pumpAndSettle();

      expect(find.text('Jazz FM'), findsOneWidget);
    });

    testWidgets('toggling the control while playing requests a pause', (
      tester,
    ) async {
      seed(RadioPlayerPlaying(buildStation('Jazz FM'), null));

      await tester.pumpWidget(host());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.pause));
      await tester.pump();

      verify(() => playerBloc.add(const RadioPlayerPauseRequested())).called(1);
    });

    testWidgets('toggling the control while paused resumes playback', (
      tester,
    ) async {
      final station = buildStation('Jazz FM');
      seed(RadioPlayerPaused(station));

      await tester.pumpWidget(host());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();

      verify(() => playerBloc.add(RadioPlayerPlayRequested(station))).called(1);
    });

    testWidgets('renders a progress indicator while buffering', (tester) async {
      seed(RadioPlayerBuffering(buildStation('Jazz FM')));

      await tester.pumpWidget(host());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('exposes a collapse control to dismiss the player', (
      tester,
    ) async {
      seed(RadioPlayerPlaying(buildStation('Jazz FM'), null));

      await tester.pumpWidget(host());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.expand_more), findsOneWidget);
    });
  });
}
