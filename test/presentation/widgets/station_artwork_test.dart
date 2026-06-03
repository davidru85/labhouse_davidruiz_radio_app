import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/presentation/widgets/station_artwork.dart';

/// Slice 3 — Station artwork via cached_network_image (DESIGN.md, ADR-0018).
RadioStation _station({String? favicon}) => RadioStation(
  stationUuid: 'uuid',
  name: 'Jazz FM',
  streamUrl: 'https://example.com/s',
  resolvedStreamUrl: 'https://example.com/s/resolved',
  favicon: favicon,
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

void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('loads the favicon through CachedNetworkImage when present', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        StationArtwork(
          station: _station(favicon: 'https://img.example.com/jazz.png'),
          size: 64,
        ),
      ),
    );

    final image = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    expect(image.imageUrl, 'https://img.example.com/jazz.png');
    expect(image.fit, BoxFit.cover);
  });

  testWidgets('shows the Material fallback icon when there is no favicon', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(StationArtwork(station: _station(), size: 64)),
    );

    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(find.byIcon(Icons.radio), findsOneWidget);
  });

  testWidgets('shows the Cupertino fallback icon when there is no favicon', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(StationArtwork(station: _station(), size: 64, useCupertino: true)),
    );

    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(
      find.byIcon(CupertinoIcons.antenna_radiowaves_left_right),
      findsOneWidget,
    );
  });

  testWidgets('treats a blank favicon as missing', (tester) async {
    await tester.pumpWidget(
      host(StationArtwork(station: _station(favicon: '   '), size: 64)),
    );

    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(find.byIcon(Icons.radio), findsOneWidget);
  });

  testWidgets('clips the artwork to a rounded shape', (tester) async {
    await tester.pumpWidget(
      host(StationArtwork(station: _station(), size: 64)),
    );

    expect(find.byType(ClipRRect), findsWidgets);
  });
}
