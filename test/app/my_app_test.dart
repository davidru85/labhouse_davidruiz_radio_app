import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:radio_app/main.dart';
import 'package:radio_app/presentation/blocs/connectivity/connectivity_bloc.dart';
import 'package:radio_app/presentation/blocs/favorites/favorites_bloc.dart';
import 'package:radio_app/presentation/blocs/radio_player/radio_player_bloc.dart';
import 'package:radio_app/presentation/blocs/stations/stations_bloc.dart';
import 'package:radio_app/presentation/routing/app_router.dart';
import 'package:radio_app/presentation/screens/stations_screen.dart';

class _FakeStationsBloc extends MockBloc<StationsEvent, StationsState>
    implements StationsBloc {}

class _FakeFavoritesBloc extends MockBloc<FavoritesEvent, FavoritesState>
    implements FavoritesBloc {}

class _FakeRadioPlayerBloc extends MockBloc<RadioPlayerEvent, RadioPlayerState>
    implements RadioPlayerBloc {}

class _FakeConnectivityBloc
    extends MockBloc<ConnectivityEvent, ConnectivityState>
    implements ConnectivityBloc {}

void main() {
  group('MyApp', () {
    late _FakeStationsBloc stationsBloc;
    late _FakeFavoritesBloc favoritesBloc;
    late _FakeRadioPlayerBloc playerBloc;
    late _FakeConnectivityBloc connectivityBloc;

    setUp(() {
      stationsBloc = _FakeStationsBloc();
      whenListen(
        stationsBloc,
        const Stream<StationsState>.empty(),
        initialState: const StationsState(),
      );
      favoritesBloc = _FakeFavoritesBloc();
      whenListen(
        favoritesBloc,
        const Stream<FavoritesState>.empty(),
        initialState: const FavoritesLoadSuccess([]),
      );
      playerBloc = _FakeRadioPlayerBloc();
      whenListen(
        playerBloc,
        const Stream<RadioPlayerState>.empty(),
        initialState: const RadioPlayerInitial(),
      );
      connectivityBloc = _FakeConnectivityBloc();
      whenListen(
        connectivityBloc,
        const Stream<ConnectivityState>.empty(),
        initialState: const ConnectivityOnline(),
      );
    });

    /// A router whose shell scope provides the stand-in tab BLoCs, mirroring
    /// the production `shellScopeBuilder` wiring.
    GoRouter buildScopedRouter() => createAppRouter(
      shellScopeBuilder: (context, child) => MultiBlocProvider(
        providers: [
          BlocProvider<StationsBloc>.value(value: stationsBloc),
          BlocProvider<FavoritesBloc>.value(value: favoritesBloc),
          BlocProvider<ConnectivityBloc>.value(value: connectivityBloc),
        ],
        child: child,
      ),
    );

    testWidgets('wires MaterialApp.router and renders the shell, not the '
        'placeholder', (tester) async {
      await tester.pumpWidget(
        MyApp(router: buildScopedRouter(), createPlayerBloc: () => playerBloc),
      );
      await tester.pumpAndSettle();

      // The Phase 8 placeholder is gone; the real shell renders.
      expect(find.text('RadioApp Shell'), findsNothing);
      expect(find.byType(StationsScreen), findsOneWidget);

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.routerConfig, isNotNull);
    });

    testWidgets('provides a root RadioPlayerBloc above the routing shell', (
      tester,
    ) async {
      await tester.pumpWidget(
        MyApp(router: buildScopedRouter(), createPlayerBloc: () => playerBloc),
      );
      await tester.pumpAndSettle();

      final shellContext = tester.element(find.byType(StationsScreen));
      expect(shellContext.read<RadioPlayerBloc>(), same(playerBloc));
    });
  });
}
