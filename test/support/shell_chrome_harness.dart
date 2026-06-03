import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/l10n/app_localizations.dart';
import 'package:radio_app/presentation/blocs/connectivity/connectivity_bloc.dart';
import 'package:radio_app/presentation/blocs/favorites/favorites_bloc.dart';
import 'package:radio_app/presentation/blocs/radio_player/radio_player_bloc.dart';
import 'package:radio_app/presentation/blocs/stations/stations_bloc.dart';

/// Stand-in [StationsBloc] for shell-chrome tests.
class FakeStationsBloc extends MockBloc<StationsEvent, StationsState>
    implements StationsBloc {}

/// Stand-in [FavoritesBloc] for shell-chrome tests.
class FakeFavoritesBloc extends MockBloc<FavoritesEvent, FavoritesState>
    implements FavoritesBloc {}

/// Stand-in [RadioPlayerBloc] driving the mini-player in shell-chrome tests.
class FakeRadioPlayerBloc extends MockBloc<RadioPlayerEvent, RadioPlayerState>
    implements RadioPlayerBloc {}

/// Stand-in [ConnectivityBloc] driving the offline banner in shell-chrome
/// tests.
class FakeConnectivityBloc
    extends MockBloc<ConnectivityEvent, ConnectivityState>
    implements ConnectivityBloc {}

/// Builds a [RadioStation] fixture for shell-chrome tests.
RadioStation buildStation(String name) => RadioStation(
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

/// Bundles a built shell harness: the [GoRouter] under test, the host widget,
/// and the fake BLoCs so tests can drive states and assert navigation.
class ShellChromeHarness {
  /// Creates a shell-chrome harness bundle.
  ShellChromeHarness({
    required this.router,
    required this.widget,
    required this.player,
    required this.connectivity,
    required this.stations,
    required this.favorites,
  });

  /// The router under test.
  final GoRouter router;

  /// The pumpable host widget wrapping [router].
  final Widget widget;

  /// The root player bloc (drives the mini-player).
  final FakeRadioPlayerBloc player;

  /// The connectivity bloc (drives the offline banner).
  final FakeConnectivityBloc connectivity;

  /// The shell-scoped stations bloc.
  final FakeStationsBloc stations;

  /// The shell-scoped favorites bloc.
  final FakeFavoritesBloc favorites;
}

/// Builds the full app shell chrome under the app router with stand-in BLoCs,
/// so Step 4 tests (9.7–9.10) can exercise the mini-player navigation, the
/// bottom-to-top player transition, the tab bar, and the offline banner.
///
/// [platform] selects the Material (Android) or Cupertino (iOS) presentation.
/// State streams default to empty (steady initial state); pass an explicit
/// stream to drive transitions (e.g. the back-online banner).
ShellChromeHarness buildShellChromeHarness({
  required GoRouter Function({
    GlobalKey<NavigatorState>? navigatorKey,
    Widget Function(BuildContext, Widget)? shellScopeBuilder,
  })
  routerFactory,
  RadioPlayerState playerState = const RadioPlayerInitial(),
  Stream<RadioPlayerState>? playerStream,
  ConnectivityState connectivityState = const ConnectivityOnline(),
  Stream<ConnectivityState>? connectivityStream,
  TargetPlatform platform = TargetPlatform.android,
}) {
  final stations = FakeStationsBloc();
  whenListen(
    stations,
    const Stream<StationsState>.empty(),
    initialState: const StationsState(),
  );
  final favorites = FakeFavoritesBloc();
  whenListen(
    favorites,
    const Stream<FavoritesState>.empty(),
    initialState: const FavoritesLoadSuccess([]),
  );
  final player = FakeRadioPlayerBloc();
  whenListen(
    player,
    playerStream ?? const Stream<RadioPlayerState>.empty(),
    initialState: playerState,
  );
  final connectivity = FakeConnectivityBloc();
  whenListen(
    connectivity,
    connectivityStream ?? const Stream<ConnectivityState>.empty(),
    initialState: connectivityState,
  );

  final router = routerFactory(
    shellScopeBuilder: (context, child) => MultiBlocProvider(
      providers: [
        BlocProvider<StationsBloc>.value(value: stations),
        BlocProvider<FavoritesBloc>.value(value: favorites),
      ],
      child: child,
    ),
  );

  final widget = MaterialApp.router(
    theme: ThemeData(platform: platform),
    routerConfig: router,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MultiBlocProvider(
      providers: [
        BlocProvider<RadioPlayerBloc>.value(value: player),
        BlocProvider<ConnectivityBloc>.value(value: connectivity),
      ],
      child: child ?? const SizedBox.shrink(),
    ),
  );

  return ShellChromeHarness(
    router: router,
    widget: widget,
    player: player,
    connectivity: connectivity,
    stations: stations,
    favorites: favorites,
  );
}
