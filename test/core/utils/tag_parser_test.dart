import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/utils/tag_parser.dart';

void main() {
  group('parseTags', () {
    test('returns an empty list for null input', () {
      expect(parseTags(null), isEmpty);
    });

    test('returns an empty list for empty input', () {
      expect(parseTags(''), isEmpty);
    });

    test('returns an empty list for whitespace-only input', () {
      expect(parseTags('   '), isEmpty);
    });

    test('splits a comma-separated list', () {
      expect(parseTags('jazz,blues'), <String>['jazz', 'blues']);
    });

    test('trims surrounding whitespace from each tag', () {
      expect(parseTags(' jazz ,  blues '), <String>['jazz', 'blues']);
    });

    test('drops empty segments between separators', () {
      expect(parseTags('jazz,,blues,'), <String>['jazz', 'blues']);
    });

    test('deduplicates tags, preserving first-seen order', () {
      expect(parseTags('jazz,blues,jazz'), <String>['jazz', 'blues']);
    });
  });
}
