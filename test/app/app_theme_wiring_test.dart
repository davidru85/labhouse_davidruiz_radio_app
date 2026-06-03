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
import 'package:radio_app/presentation/theme/app_colors.dart';

class _FakeStationsBloc extends MockBloc<StationsEvent, StationsState>
    implements StationsBloc {}

class _FakeFavoritesBloc extends MockBloc<FavoritesEvent, FavoritesState>
    implements FavoritesBloc {}

class _FakeRadioPlayerBloc extends MockBloc<RadioPlayerEvent, RadioPlayerState>
    implements RadioPlayerBloc {}

class _FakeConnectivityBloc
    extends MockBloc<ConnectivityEvent, ConnectivityState>
    implements ConnectivityBloc {}

/// Slice 2a — the root app adopts the dark brand theme (ADR-0042).
void main() {
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

  testWidgets('MyApp applies the dark brand theme', (tester) async {
    await tester.pumpWidget(
      MyApp(router: buildScopedRouter(), createPlayerBloc: () => playerBloc),
    );
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(app.darkTheme, isNotNull);
    expect(app.darkTheme!.brightness, Brightness.dark);
    expect(app.darkTheme!.colorScheme.primary, AppColors.primary);
  });
}
