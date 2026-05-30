import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/utils/icy_metadata_parser.dart';
import 'package:radio_app/domain/entities/now_playing_info.dart';

void main() {
  group('parseIcyMetadata', () {
    test('parses artist and track from the first separator', () {
      final info = parseIcyMetadata('Artist - Track - Live Version');

      expect(info.raw, 'Artist - Track - Live Version');
      expect(info.artist, 'Artist');
      expect(info.track, 'Track - Live Version');
    });

    test('trims parsed artist and track values', () {
      final info = parseIcyMetadata('  Artist  -  Track  ');

      expect(info.artist, 'Artist');
      expect(info.track, 'Track');
    });

    test('preserves raw metadata when no separator exists', () {
      final info = parseIcyMetadata('Unstructured live metadata');

      expect(info.raw, 'Unstructured live metadata');
      expect(info.artist, isNull);
      expect(info.track, isNull);
    });

    test('normalizes null and empty metadata to an empty entity', () {
      expect(parseIcyMetadata(null), equals(const NowPlayingInfo()));
      expect(parseIcyMetadata(''), equals(const NowPlayingInfo()));
    });
  });
}
