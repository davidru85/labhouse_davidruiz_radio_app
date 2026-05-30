import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/utils/icy_metadata_parser.dart';

void main() {
  group('parseIcyMetadata', () {
    test('does not depend on domain entities', () {
      final source = File(
        'lib/core/utils/icy_metadata_parser.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('domain/')));
    });

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

    test('normalizes null and empty metadata to null fields', () {
      final nullInfo = parseIcyMetadata(null);
      final emptyInfo = parseIcyMetadata('');

      expect(nullInfo.raw, isNull);
      expect(nullInfo.artist, isNull);
      expect(nullInfo.track, isNull);
      expect(emptyInfo.raw, isNull);
      expect(emptyInfo.artist, isNull);
      expect(emptyInfo.track, isNull);
    });
  });
}
