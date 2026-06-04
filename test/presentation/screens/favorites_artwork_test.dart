import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/l10n/app_localizations.dart';
import 'package:radio_app/presentation/blocs/favorites/favorites_bloc.dart';
import 'package:radio_app/presentation/screens/favorites_screen.dart';
import 'package:radio_app/presentation/widgets/station_artwork.dart';

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

/// Slice 3 — favorite cards show square artwork (DESIGN.md §2).
void main() {
  late _MockFavoritesBloc bloc;

  setUp(() {
    bloc = _MockFavoritesBloc();
    when(
      () => bloc.state,
    ).thenReturn(FavoritesLoadSuccess([_station('a'), _station('b')]));
  });

  Widget harness(TargetPlatform platform) => MaterialApp(
    theme: ThemeData(platform: platform),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<FavoritesBloc>.value(
      value: bloc,
      child: const FavoritesScreen(),
    ),
  );

  testWidgets('renders artwork on each favorite card', (tester) async {
    await tester.pumpWidget(harness(TargetPlatform.android));

    expect(find.byType(StationArtwork), findsNWidgets(2));
  });
}
