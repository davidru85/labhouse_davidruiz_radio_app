import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/l10n/app_localizations.dart';
import 'package:radio_app/presentation/blocs/connectivity/connectivity_bloc.dart';
import 'package:radio_app/presentation/blocs/stations/stations_bloc.dart';
import 'package:radio_app/presentation/screens/stations_screen.dart';
import 'package:radio_app/presentation/widgets/station_artwork.dart';

class _MockStationsBloc extends MockBloc<StationsEvent, StationsState>
    implements StationsBloc {}

class _MockConnectivityBloc
    extends MockBloc<ConnectivityEvent, ConnectivityState>
    implements ConnectivityBloc {}

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

/// Slice 3 — station rows show artwork (DESIGN.md §1).
void main() {
  late _MockStationsBloc bloc;
  late _MockConnectivityBloc connectivityBloc;

  setUp(() {
    bloc = _MockStationsBloc();
    connectivityBloc = _MockConnectivityBloc();
    when(() => connectivityBloc.state).thenReturn(const ConnectivityOnline());
    when(() => bloc.state).thenReturn(
      StationsState(
        status: StationsStatus.success,
        stations: [_station('a'), _station('b')],
      ),
    );
  });

  Widget harness(TargetPlatform platform) => MaterialApp(
    theme: ThemeData(platform: platform),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: MultiBlocProvider(
      providers: [
        BlocProvider<StationsBloc>.value(value: bloc),
        BlocProvider<ConnectivityBloc>.value(value: connectivityBloc),
      ],
      child: const StationsScreen(),
    ),
  );

  testWidgets('renders 64dp Material artwork on each row', (tester) async {
    await tester.pumpWidget(harness(TargetPlatform.android));

    final artworks = tester.widgetList<StationArtwork>(
      find.byType(StationArtwork),
    );
    expect(artworks, hasLength(2));
    for (final artwork in artworks) {
      expect(artwork.size, 64);
      expect(artwork.useCupertino, isFalse);
    }
  });

  testWidgets('renders 64dp Cupertino artwork on each row', (tester) async {
    await tester.pumpWidget(harness(TargetPlatform.iOS));

    final artworks = tester.widgetList<StationArtwork>(
      find.byType(StationArtwork),
    );
    expect(artworks, hasLength(2));
    for (final artwork in artworks) {
      expect(artwork.size, 64);
      expect(artwork.useCupertino, isTrue);
    }
    // The favicon is null, so each row shows the native Cupertino fallback.
    expect(
      find.byIcon(CupertinoIcons.antenna_radiowaves_left_right),
      findsNWidgets(2),
    );
  });
}
