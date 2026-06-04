import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/l10n/app_localizations.dart';
import 'package:radio_app/presentation/blocs/favorites/favorites_bloc.dart';
import 'package:radio_app/presentation/screens/favorites_screen.dart';
import 'package:radio_app/presentation/widgets/glass_surface.dart';

class _MockFavoritesBloc extends MockBloc<FavoritesEvent, FavoritesState>
    implements FavoritesBloc {}

RadioStation _station(String uuid) => RadioStation(
  stationUuid: uuid,
  name: 'Station $uuid',
  streamUrl: 'https://example.com/$uuid',
  resolvedStreamUrl: 'https://example.com/$uuid/resolved',
  favicon: null,
  homepage: null,
  tags: 'Jazz',
  tagList: const ['Jazz'],
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

/// Slice 4 (B2) — the favorite toggle sits on a blurred translucent chip
/// (DESIGN.md §Cards / §2).
void main() {
  testWidgets('each favorite toggle sits on a glass chip', (tester) async {
    final bloc = _MockFavoritesBloc();
    when(
      () => bloc.state,
    ).thenReturn(FavoritesLoadSuccess([_station('a'), _station('b')]));

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

    // One glass chip behind the heart on each of the two cards. (Scope to the
    // hearts so the glass app bar's own GlassSurface is not counted.)
    expect(
      find.ancestor(
        of: find.byIcon(Icons.favorite),
        matching: find.byType(GlassSurface),
      ),
      findsNWidgets(2),
    );
  });
}
