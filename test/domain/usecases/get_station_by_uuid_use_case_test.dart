import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/station_repository.dart';
import 'package:radio_app/domain/usecases/get_station_by_uuid_use_case.dart';

void main() {
  group('GetStationByUuidUseCase', () {
    test('delegates stationuuid lookup to repository', () async {
      final station = _station(stationUuid: 'station-uuid');
      final repository = _FakeStationRepository(
        stationResult: Success<RadioStation?, Failure>(station),
      );
      final useCase = GetStationByUuidUseCase(repository);

      final result = await useCase(
        const GetStationByUuidParams(stationUuid: 'station-uuid'),
      );

      expect(result, isA<Success<RadioStation?, Failure>>());
      expect((result as Success<RadioStation?, Failure>).value, station);
      expect(repository.lastStationUuid, 'station-uuid');
    });

    test('preserves a successful null result for missing stations', () async {
      final repository = _FakeStationRepository(
        stationResult: const Success<RadioStation?, Failure>(null),
      );
      final useCase = GetStationByUuidUseCase(repository);

      final result = await useCase(
        const GetStationByUuidParams(stationUuid: 'missing-uuid'),
      );

      expect(result, isA<Success<RadioStation?, Failure>>());
      expect((result as Success<RadioStation?, Failure>).value, isNull);
      expect(repository.lastStationUuid, 'missing-uuid');
    });

    test('forwards repository failures', () async {
      const failure = ServerFailure('unavailable');
      final repository = _FakeStationRepository(
        stationResult: const FailureResult<RadioStation?, Failure>(failure),
      );
      final useCase = GetStationByUuidUseCase(repository);

      final result = await useCase(
        const GetStationByUuidParams(stationUuid: 'station-uuid'),
      );

      expect(result, isA<FailureResult<RadioStation?, Failure>>());
      expect(
        (result as FailureResult<RadioStation?, Failure>).failure,
        failure,
      );
      expect(repository.lastStationUuid, 'station-uuid');
    });
  });
}

class _FakeStationRepository implements StationRepository {
  _FakeStationRepository({required this.stationResult});

  final Result<RadioStation?, Failure> stationResult;
  String? lastStationUuid;

  @override
  Future<Result<RadioStation?, Failure>> getStationByUuid(
    String stationUuid,
  ) async {
    lastStationUuid = stationUuid;

    return stationResult;
  }

  @override
  Future<Result<void, Failure>> cancelPendingRequests() async {
    return const Success<void, Failure>(null);
  }

  @override
  Future<Result<List<RadioStation>, Failure>> loadPopularStations({
    int limit = 30,
    int offset = 0,
  }) async {
    return const Success<List<RadioStation>, Failure>([]);
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
