import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:radio_app/l10n/app_localizations.dart';
import 'package:radio_app/presentation/blocs/connectivity/connectivity_bloc.dart';
import 'package:radio_app/presentation/blocs/favorites/favorites_bloc.dart';
import 'package:radio_app/presentation/blocs/stations/stations_bloc.dart';
import 'package:radio_app/presentation/screens/favorites_screen.dart';
import 'package:radio_app/presentation/screens/stations_screen.dart';

class _MockStationsBloc extends MockBloc<StationsEvent, StationsState>
    implements StationsBloc {}

class _MockConnectivityBloc
    extends MockBloc<ConnectivityEvent, ConnectivityState>
    implements ConnectivityBloc {}

class _MockFavoritesBloc extends MockBloc<FavoritesEvent, FavoritesState>
    implements FavoritesBloc {}

/// Slice 4 (B2) — translucent glass app bars (DESIGN.md §Stations/§Favorites).
void main() {
  testWidgets('the Stations app bar blurs its backdrop on Material', (
    tester,
  ) async {
    final bloc = _MockStationsBloc();
    final connectivity = _MockConnectivityBloc();
    when(() => connectivity.state).thenReturn(const ConnectivityOnline());
    when(() => bloc.state).thenReturn(const StationsState());

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.android),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MultiBlocProvider(
          providers: [
            BlocProvider<StationsBloc>.value(value: bloc),
            BlocProvider<ConnectivityBloc>.value(value: connectivity),
          ],
          child: const StationsScreen(),
        ),
      ),
    );

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byType(BackdropFilter),
      ),
      findsOneWidget,
    );
  });

  testWidgets('the Favorites app bar blurs its backdrop on Material', (
    tester,
  ) async {
    final bloc = _MockFavoritesBloc();
    when(() => bloc.state).thenReturn(const FavoritesLoadSuccess([]));

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.android),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<FavoritesBloc>.value(
          value: bloc,
          child: const FavoritesScreen(),
        ),
      ),
    );

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byType(BackdropFilter),
      ),
      findsOneWidget,
    );
  });
}
