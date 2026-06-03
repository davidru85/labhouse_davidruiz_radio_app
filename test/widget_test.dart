import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
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
  testWidgets('App loads successfully into the shell', (tester) async {
    final stationsBloc = _FakeStationsBloc();
    whenListen(
      stationsBloc,
      const Stream<StationsState>.empty(),
      initialState: const StationsState(),
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

    await tester.pumpWidget(
      MyApp(
        router: createAppRouter(
          shellScopeBuilder: (context, child) => MultiBlocProvider(
            providers: [
              BlocProvider<StationsBloc>.value(value: stationsBloc),
              BlocProvider<FavoritesBloc>.value(value: favoritesBloc),
              BlocProvider<ConnectivityBloc>.value(value: connectivityBloc),
            ],
            child: child,
          ),
        ),
        createPlayerBloc: () => playerBloc,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(StationsScreen), findsOneWidget);
  });
}
