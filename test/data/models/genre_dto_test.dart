import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/data/models/genre_dto.dart';

void main() {
  group('GenreDto', () {
    test('maps name and stationcount to a domain genre', () {
      final genre = GenreDto.fromJson(<String, dynamic>{
        'name': 'jazz',
        'stationcount': 120,
      }).toEntity();

      expect(genre.name, 'jazz');
      expect(genre.stationCount, 120);
    });

    test('maps an absent stationcount to null', () {
      final genre = GenreDto.fromJson(<String, dynamic>{
        'name': 'ambient',
      }).toEntity();

      expect(genre.name, 'ambient');
      expect(genre.stationCount, isNull);
    });
  });
}
