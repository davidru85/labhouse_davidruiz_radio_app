import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:radio_app/l10n/app_localizations.dart';
import 'package:radio_app/presentation/blocs/stations/stations_bloc.dart';

/// Stand-in [StationsBloc] for routing tests that only exercise navigation.
class _FakeStationsBloc extends MockBloc<StationsEvent, StationsState>
    implements StationsBloc {}

/// Wraps [router] in a `MaterialApp.router` configured with the app
/// localizations and a stand-in [StationsBloc] ancestor.
///
/// The real screens now consume `AppLocalizations` and `StationsBloc`, while
/// the concrete shell BLoC wiring is deferred to Phase 9 Step 3. This harness
/// supplies those dependencies so routing tests can keep asserting purely on
/// route → screen mapping.
Widget buildRouterHarness(GoRouter router) {
  final stationsBloc = _FakeStationsBloc();
  whenListen(
    stationsBloc,
    const Stream<StationsState>.empty(),
    initialState: const StationsState(),
  );
  return MaterialApp.router(
    routerConfig: router,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => BlocProvider<StationsBloc>.value(
      value: stationsBloc,
      child: child ?? const SizedBox.shrink(),
    ),
  );
}
