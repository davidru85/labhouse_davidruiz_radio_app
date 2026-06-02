import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/favorites_repository.dart';
import 'package:radio_app/domain/usecases/get_favorites_use_case.dart';
import 'package:radio_app/domain/usecases/use_case.dart';

class _MockFavoritesRepository extends Mock implements FavoritesRepository {}

void main() {
  group('GetFavoritesUseCase', () {
    test('delegates to FavoritesRepository.getFavorites', () async {
      final repository = _MockFavoritesRepository();
      final stations = [_station('a'), _station('b')];
      when(
        repository.getFavorites,
      ).thenAnswer((_) async => Success<List<RadioStation>, Failure>(stations));
      final useCase = GetFavoritesUseCase(repository);

      final result = await useCase(const NoParams());

      expect(result, isA<Success<List<RadioStation>, Failure>>());
      expect((result as Success<List<RadioStation>, Failure>).value, stations);
      verify(repository.getFavorites).called(1);
    });
  });
}

RadioStation _station(String uuid) => RadioStation(
  stationUuid: uuid,
  name: 'Station $uuid',
  streamUrl: 'https://example.com/$uuid',
  resolvedStreamUrl: 'https://example.com/$uuid/resolved',
  favicon: null,
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
