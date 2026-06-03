import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:radio_app/l10n/app_localizations.dart';
import 'package:radio_app/presentation/blocs/connectivity/connectivity_bloc.dart';
import 'package:radio_app/presentation/blocs/radio_player/radio_player_bloc.dart';
import 'package:radio_app/presentation/blocs/stations/stations_bloc.dart';
import 'package:radio_app/presentation/screens/stations_screen.dart';

class _FakeStationsBloc extends MockBloc<StationsEvent, StationsState>
    implements StationsBloc {}

class _FakeConnectivityBloc
    extends MockBloc<ConnectivityEvent, ConnectivityState>
    implements ConnectivityBloc {}

class _FakeRadioPlayerBloc extends MockBloc<RadioPlayerEvent, RadioPlayerState>
    implements RadioPlayerBloc {}

void main() {
  setUpAll(() => registerFallbackValue(const StationsSearchChanged('')));

  group('Stations screen offline copy + retry (sub-task 9.11, ADR-0013)', () {
    late _FakeStationsBloc stationsBloc;
    late _FakeConnectivityBloc connectivityBloc;
    late _FakeRadioPlayerBloc playerBloc;

    setUp(() {
      stationsBloc = _FakeStationsBloc();
      connectivityBloc = _FakeConnectivityBloc();
      playerBloc = _FakeRadioPlayerBloc();
      whenListen(
        playerBloc,
        const Stream<RadioPlayerState>.empty(),
        initialState: const RadioPlayerInitial(),
      );
    });

    Widget host() => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<StationsBloc>.value(value: stationsBloc),
          BlocProvider<ConnectivityBloc>.value(value: connectivityBloc),
          BlocProvider<RadioPlayerBloc>.value(value: playerBloc),
        ],
        child: const StationsScreen(),
      ),
    );

    testWidgets('shows offline copy + a retry affordance while offline', (
      tester,
    ) async {
      whenListen(
        stationsBloc,
        const Stream<StationsState>.empty(),
        initialState: const StationsState(query: 'jazz'),
      );
      whenListen(
        connectivityBloc,
        const Stream<ConnectivityState>.empty(),
        initialState: const ConnectivityOffline(),
      );

      await tester.pumpWidget(host());
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Connect to discover stations'),
        findsOneWidget,
      );
      expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
    });

    testWidgets('tapping retry re-runs the current query', (tester) async {
      whenListen(
        stationsBloc,
        const Stream<StationsState>.empty(),
        initialState: const StationsState(query: 'jazz'),
      );
      whenListen(
        connectivityBloc,
        const Stream<ConnectivityState>.empty(),
        initialState: const ConnectivityOffline(),
      );

      await tester.pumpWidget(host());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
      await tester.pump();

      verify(
        () => stationsBloc.add(const StationsSearchChanged('jazz')),
      ).called(1);
    });

    testWidgets('shows the normal list (no offline copy) while online', (
      tester,
    ) async {
      whenListen(
        stationsBloc,
        const Stream<StationsState>.empty(),
        initialState: const StationsState(),
      );
      whenListen(
        connectivityBloc,
        const Stream<ConnectivityState>.empty(),
        initialState: const ConnectivityOnline(),
      );

      await tester.pumpWidget(host());
      await tester.pumpAndSettle();

      expect(find.textContaining('Connect to discover stations'), findsNothing);
    });
  });
}
