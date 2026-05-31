import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/station_repository.dart';
import 'package:radio_app/domain/usecases/load_popular_stations_use_case.dart';

void main() {
  group('LoadPopularStationsUseCase', () {
    test('delegates pagination params to repository', () async {
      final stations = [_station(stationUuid: 'popular-result')];
      final repository = _FakeStationRepository(
        popularResult: Success<List<RadioStation>, Failure>(stations),
      );
      final useCase = LoadPopularStationsUseCase(repository);

      final result = await useCase(
        const LoadPopularStationsParams(limit: 10, offset: 20),
      );

      expect(result, isA<Success<List<RadioStation>, Failure>>());
      expect((result as Success<List<RadioStation>, Failure>).value, stations);
      expect(repository.lastPopularLimit, 10);
      expect(repository.lastPopularOffset, 20);
    });

    test('uses default pagination params', () async {
      final repository = _FakeStationRepository();
      final useCase = LoadPopularStationsUseCase(repository);

      await useCase(const LoadPopularStationsParams());

      expect(repository.lastPopularLimit, 30);
      expect(repository.lastPopularOffset, 0);
    });

    test('preserves empty successful results', () async {
      final repository = _FakeStationRepository(
        popularResult: const Success<List<RadioStation>, Failure>([]),
      );
      final useCase = LoadPopularStationsUseCase(repository);

      final result = await useCase(const LoadPopularStationsParams());

      expect(result, isA<Success<List<RadioStation>, Failure>>());
      expect((result as Success<List<RadioStation>, Failure>).value, isEmpty);
    });

    test('forwards repository failures', () async {
      const failure = ServerFailure('unavailable');
      final repository = _FakeStationRepository(
        popularResult: const FailureResult<List<RadioStation>, Failure>(
          failure,
        ),
      );
      final useCase = LoadPopularStationsUseCase(repository);

      final result = await useCase(const LoadPopularStationsParams());

      expect(result, isA<FailureResult<List<RadioStation>, Failure>>());
      expect(
        (result as FailureResult<List<RadioStation>, Failure>).failure,
        failure,
      );
    });
  });
}

class _FakeStationRepository implements StationRepository {
  _FakeStationRepository({Result<List<RadioStation>, Failure>? popularResult})
    : popularResult =
          popularResult ?? const Success<List<RadioStation>, Failure>([]);

  final Result<List<RadioStation>, Failure> popularResult;
  int? lastPopularLimit;
  int? lastPopularOffset;

  @override
  Future<Result<List<RadioStation>, Failure>> loadPopularStations({
    int limit = 30,
    int offset = 0,
  }) async {
    lastPopularLimit = limit;
    lastPopularOffset = offset;

    return popularResult;
  }

  @override
  Future<Result<void, Failure>> cancelPendingRequests() async {
    return const Success<void, Failure>(null);
  }

  @override
  Future<Result<List<RadioStation>, Failure>> searchStations({
    String? query,
    String? countryCode,
    String? tag,
    int limit = 30,
    int offset = 0,
  }) async {
    return const Success<List<RadioStation>, Failure>([]);
  }

  @override
  Future<Result<RadioStation?, Failure>> getStationByUuid(
    String stationUuid,
  ) async {
    return const Success<RadioStation?, Failure>(null);
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
