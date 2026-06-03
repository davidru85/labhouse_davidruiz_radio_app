import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:radio_app/l10n/app_localizations.dart';
import 'package:radio_app/presentation/blocs/connectivity/connectivity_bloc.dart';
import 'package:radio_app/presentation/blocs/favorites/favorites_bloc.dart';
import 'package:radio_app/presentation/blocs/radio_player/radio_player_bloc.dart';
import 'package:radio_app/presentation/blocs/stations/stations_bloc.dart';

/// Stand-in [StationsBloc] for routing tests that only exercise navigation.
class _FakeStationsBloc extends MockBloc<StationsEvent, StationsState>
    implements StationsBloc {}

/// Stand-in [FavoritesBloc] for routing tests that only exercise navigation.
class _FakeFavoritesBloc extends MockBloc<FavoritesEvent, FavoritesState>
    implements FavoritesBloc {}

/// Stand-in [RadioPlayerBloc] backing the shell mini-player in routing tests.
class _FakeRadioPlayerBloc extends MockBloc<RadioPlayerEvent, RadioPlayerState>
    implements RadioPlayerBloc {}

/// Stand-in [ConnectivityBloc] backing the shell offline banner in routing
/// tests.
class _FakeConnectivityBloc
    extends MockBloc<ConnectivityEvent, ConnectivityState>
    implements ConnectivityBloc {}

/// Wraps [router] in a `MaterialApp.router` configured with the app
/// localizations and stand-in shell BLoC ancestors.
///
/// The real screens now consume `AppLocalizations`, `StationsBloc` and
/// `FavoritesBloc`, while the concrete shell BLoC wiring is deferred to Phase 9
/// Step 3. This harness supplies those dependencies so routing tests can keep
/// asserting purely on route → screen mapping.
Widget buildRouterHarness(GoRouter router) {
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
    // A settled (non-loading) state so pumpAndSettle does not spin on the
    // loading indicator's animation.
    initialState: const FavoritesLoadSuccess([]),
  );
  // The routed shell now renders the mini-player and offline banner, which read
  // these blocs; idle/online steady states keep both visually inert so existing
  // route → screen assertions are unaffected.
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
  return MaterialApp.router(
    routerConfig: router,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MultiBlocProvider(
      providers: [
        BlocProvider<StationsBloc>.value(value: stationsBloc),
        BlocProvider<FavoritesBloc>.value(value: favoritesBloc),
        BlocProvider<RadioPlayerBloc>.value(value: playerBloc),
        BlocProvider<ConnectivityBloc>.value(value: connectivityBloc),
      ],
      child: child ?? const SizedBox.shrink(),
    ),
  );
}
