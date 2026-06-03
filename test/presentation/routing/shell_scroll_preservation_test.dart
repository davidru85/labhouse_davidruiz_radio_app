import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/l10n/app_localizations.dart';
import 'package:radio_app/presentation/blocs/connectivity/connectivity_bloc.dart';
import 'package:radio_app/presentation/blocs/favorites/favorites_bloc.dart';
import 'package:radio_app/presentation/blocs/radio_player/radio_player_bloc.dart';
import 'package:radio_app/presentation/blocs/stations/stations_bloc.dart';
import 'package:radio_app/presentation/routing/app_router.dart';

class _FakeStationsBloc extends MockBloc<StationsEvent, StationsState>
    implements StationsBloc {}

class _FakeFavoritesBloc extends MockBloc<FavoritesEvent, FavoritesState>
    implements FavoritesBloc {}

class _FakeRadioPlayerBloc extends MockBloc<RadioPlayerEvent, RadioPlayerState>
    implements RadioPlayerBloc {}

class _FakeConnectivityBloc
    extends MockBloc<ConnectivityEvent, ConnectivityState>
    implements ConnectivityBloc {}

RadioStation _station(int i) => RadioStation(
  stationUuid: 'uuid-$i',
  name: 'Station $i',
  streamUrl: 'https://example.com/$i',
  resolvedStreamUrl: 'https://example.com/$i/resolved',
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

void main() {
  group('Shell scroll preservation across tabs (sub-task 9.4)', () {
    testWidgets('the stations list keeps its scroll offset after switching '
        'to favorites and back', (tester) async {
      final stations = List.generate(40, _station);
      final stationsBloc = _FakeStationsBloc();
      whenListen(
        stationsBloc,
        const Stream<StationsState>.empty(),
        initialState: StationsState(
          status: StationsStatus.success,
          stations: stations,
        ),
      );
      final favoritesBloc = _FakeFavoritesBloc();
      whenListen(
        favoritesBloc,
        const Stream<FavoritesState>.empty(),
        initialState: const FavoritesLoadSuccess([]),
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

      final router = createAppRouter(
        shellScopeBuilder: (context, child) => MultiBlocProvider(
          providers: [
            BlocProvider<StationsBloc>.value(value: stationsBloc),
            BlocProvider<FavoritesBloc>.value(value: favoritesBloc),
            BlocProvider<RadioPlayerBloc>.value(value: playerBloc),
            BlocProvider<ConnectivityBloc>.value(value: connectivityBloc),
          ],
          child: child,
        ),
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );
      await tester.pumpAndSettle();

      // The top of the list is visible initially. (Favorites uses a GridView,
      // so ListView uniquely identifies the stations list.)
      expect(find.text('Station 0'), findsOneWidget);

      // Scroll the stations list well past the first viewport so the top rows
      // leave the (lazy) ListView.builder viewport.
      await tester.drag(find.byType(ListView), const Offset(0, -1500));
      await tester.pumpAndSettle();
      expect(find.text('Station 0'), findsNothing);

      // Switch to the favorites tab and back.
      router.go('/favorites');
      await tester.pumpAndSettle();
      router.go('/stations');
      await tester.pumpAndSettle();

      // Scroll offset must survive the tab round-trip: the top row stays
      // scrolled away rather than resetting to the start.
      expect(find.text('Station 0'), findsNothing);
    });
  });
}
