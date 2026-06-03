import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/domain/entities/now_playing_info.dart';
import 'package:radio_app/presentation/utils/now_playing_label.dart';

import '../../support/shell_chrome_harness.dart';

void main() {
  final station = buildStation('Jazz FM');

  group('nowPlayingLabel (per ADR-0012 UI projection)', () {
    test('returns "artist - track" when both are present', () {
      const info = NowPlayingInfo(
        raw: 'Daft Punk - Around the World',
        artist: 'Daft Punk',
        track: 'Around the World',
      );

      expect(nowPlayingLabel(station, info), 'Daft Punk - Around the World');
    });

    test('falls back to the station name when metadata is null', () {
      expect(nowPlayingLabel(station, null), 'Jazz FM');
    });

    test(
      'falls back to the station name for raw-only/unparseable metadata',
      () {
        const info = NowPlayingInfo(raw: 'some unparseable stream title');

        expect(nowPlayingLabel(station, info), 'Jazz FM');
      },
    );

    test('falls back to the station name when only the track is present', () {
      const info = NowPlayingInfo(
        raw: 'Around the World',
        track: 'Around the World',
      );

      expect(nowPlayingLabel(station, info), 'Jazz FM');
    });

    test('falls back to the station name when only the artist is present', () {
      const info = NowPlayingInfo(raw: 'Daft Punk', artist: 'Daft Punk');

      expect(nowPlayingLabel(station, info), 'Jazz FM');
    });
  });
}
