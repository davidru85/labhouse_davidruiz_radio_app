import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/data/models/genre_hive_model.dart';
import 'package:radio_app/domain/entities/genre.dart';

void main() {
  group('GenreHiveModel', () {
    test('round-trips a genre with a station count', () {
      const genre = Genre(name: 'jazz', stationCount: 120);

      final restored = GenreHiveModel.fromEntity(genre).toEntity();

      expect(restored, genre);
    });

    test('round-trips a genre whose station count is null', () {
      const genre = Genre(name: 'ambient', stationCount: null);

      final restored = GenreHiveModel.fromEntity(genre).toEntity();

      expect(restored, genre);
      expect(restored.stationCount, isNull);
    });

    test('round-trips a genre with an empty name', () {
      const genre = Genre(name: '', stationCount: 0);

      final restored = GenreHiveModel.fromEntity(genre).toEntity();

      expect(restored, genre);
    });
  });
}
