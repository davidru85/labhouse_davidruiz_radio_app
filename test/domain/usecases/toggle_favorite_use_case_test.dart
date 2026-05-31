import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/favorites_repository.dart';
import 'package:radio_app/domain/usecases/toggle_favorite_use_case.dart';

void main() {
  group('ToggleFavoriteUseCase', () {
    test('adds the station when it is not already a favorite', () async {
      final station = _station(stationUuid: 'station-uuid');
      final repository = _FakeFavoritesRepository(
        favoritesResult: const Success<List<RadioStation>, Failure>(
          <RadioStation>[],
        ),
      );
      final useCase = ToggleFavoriteUseCase(repository);

      final result = await useCase(ToggleFavoriteParams(station: station));

      expect(result, isA<Success<bool, Failure>>());
      expect((result as Success<bool, Failure>).value, isTrue);
      expect(repository.addedStation, station);
      expect(repository.removedStationUuid, isNull);
    });

    test('removes the station when it is already a favorite', () async {
      final station = _station(stationUuid: 'station-uuid');
      final repository = _FakeFavoritesRepository(
        favoritesResult: Success<List<RadioStation>, Failure>(<RadioStation>[
          station,
        ]),
      );
      final useCase = ToggleFavoriteUseCase(repository);

      final result = await useCase(ToggleFavoriteParams(station: station));

      expect(result, isA<Success<bool, Failure>>());
      expect((result as Success<bool, Failure>).value, isFalse);
      expect(repository.removedStationUuid, 'station-uuid');
      expect(repository.addedStation, isNull);
    });

    test('forwards a failure raised while reading current favorites', () async {
      const failure = StorageReadWriteFailure('unavailable');
      final repository = _FakeFavoritesRepository(
        favoritesResult: const FailureResult<List<RadioStation>, Failure>(
          failure,
        ),
      );
      final useCase = ToggleFavoriteUseCase(repository);

      final result = await useCase(
        ToggleFavoriteParams(station: _station(stationUuid: 'station-uuid')),
      );

      expect(result, isA<FailureResult<bool, Failure>>());
      expect((result as FailureResult<bool, Failure>).failure, failure);
      expect(repository.addedStation, isNull);
      expect(repository.removedStationUuid, isNull);
    });

    test('forwards a failure raised while adding the favorite', () async {
      const failure = StorageReadWriteFailure('write error');
      final station = _station(stationUuid: 'station-uuid');
      final repository = _FakeFavoritesRepository(
        favoritesResult: const Success<List<RadioStation>, Failure>(
          <RadioStation>[],
        ),
        mutationResult: const FailureResult<void, Failure>(failure),
      );
      final useCase = ToggleFavoriteUseCase(repository);

      final result = await useCase(ToggleFavoriteParams(station: station));

      expect(result, isA<FailureResult<bool, Failure>>());
      expect((result as FailureResult<bool, Failure>).failure, failure);
      expect(repository.addedStation, station);
    });

    test('forwards a failure raised while removing the favorite', () async {
      const failure = StorageReadWriteFailure('write error');
      final station = _station(stationUuid: 'station-uuid');
      final repository = _FakeFavoritesRepository(
        favoritesResult: Success<List<RadioStation>, Failure>(<RadioStation>[
          station,
        ]),
        mutationResult: const FailureResult<void, Failure>(failure),
      );
      final useCase = ToggleFavoriteUseCase(repository);

      final result = await useCase(ToggleFavoriteParams(station: station));

      expect(result, isA<FailureResult<bool, Failure>>());
      expect((result as FailureResult<bool, Failure>).failure, failure);
      expect(repository.removedStationUuid, 'station-uuid');
    });
  });
}

class _FakeFavoritesRepository implements FavoritesRepository {
  _FakeFavoritesRepository({
    required this.favoritesResult,
    this.mutationResult = const Success<void, Failure>(null),
  });

  final Result<List<RadioStation>, Failure> favoritesResult;
  final Result<void, Failure> mutationResult;

  RadioStation? addedStation;
  String? removedStationUuid;

  @override
  Stream<List<RadioStation>> get favoritesStream =>
      const Stream<List<RadioStation>>.empty();

  @override
  Future<Result<List<RadioStation>, Failure>> getFavorites() async {
    return favoritesResult;
  }

  @override
  Future<Result<void, Failure>> addFavorite(RadioStation station) async {
    addedStation = station;

    return mutationResult;
  }

  @override
  Future<Result<void, Failure>> removeFavorite(String stationUuid) async {
    removedStationUuid = stationUuid;

    return mutationResult;
  }

  @override
  Future<Result<void, Failure>> synchronizeFavorites() async {
    return const Success<void, Failure>(null);
  }
}

RadioStation _station({required String stationUuid}) {
  return RadioStation(
    stationUuid: stationUuid,
    name: 'Jazz FM',
    streamUrl: 'http://example.com/stream',
    resolvedStreamUrl: 'https://example.com/stream',
    favicon: null,
    homepage: null,
    tags: 'jazz,swing',
    tagList: const ['jazz', 'swing'],
    country: 'Germany',
    countryCode: 'DE',
    language: 'german',
    codec: 'MP3',
    bitrate: 128,
    votes: 10,
    clickCount: 20,
    lastCheckOk: true,
    isHLS: false,
  );
}
