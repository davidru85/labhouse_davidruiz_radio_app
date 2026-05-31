import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/station_repository.dart';
import 'package:radio_app/domain/usecases/search_stations_use_case.dart';

void main() {
  group('SearchStationsUseCase', () {
    test('delegates search params to repository', () async {
      final stations = [_station(stationUuid: 'search-result')];
      final repository = _FakeStationRepository(
        searchResult: Success<List<RadioStation>, Failure>(stations),
      );
      final useCase = SearchStationsUseCase(repository);

      final result = await useCase(
        const SearchStationsParams(
          query: 'jazz',
          countryCode: 'DE',
          tag: 'swing',
          limit: 25,
          offset: 50,
        ),
      );

      expect(result, isA<Success<List<RadioStation>, Failure>>());
      expect((result as Success<List<RadioStation>, Failure>).value, stations);
      expect(repository.lastSearchQuery, 'jazz');
      expect(repository.lastSearchCountryCode, 'DE');
      expect(repository.lastSearchTag, 'swing');
      expect(repository.lastSearchLimit, 25);
      expect(repository.lastSearchOffset, 50);
    });

    test('uses default pagination params', () async {
      final repository = _FakeStationRepository();
      final useCase = SearchStationsUseCase(repository);

      await useCase(const SearchStationsParams(query: 'jazz'));

      expect(repository.lastSearchLimit, 30);
      expect(repository.lastSearchOffset, 0);
    });

    test('supports null query for filter-only searches', () async {
      final repository = _FakeStationRepository();
      final useCase = SearchStationsUseCase(repository);

      await useCase(
        const SearchStationsParams(query: null, countryCode: 'DE', tag: 'jazz'),
      );

      expect(repository.lastSearchQuery, isNull);
      expect(repository.lastSearchCountryCode, 'DE');
      expect(repository.lastSearchTag, 'jazz');
    });

    test('preserves empty successful results', () async {
      final repository = _FakeStationRepository(
        searchResult: const Success<List<RadioStation>, Failure>([]),
      );
      final useCase = SearchStationsUseCase(repository);

      final result = await useCase(const SearchStationsParams(query: 'none'));

      expect(result, isA<Success<List<RadioStation>, Failure>>());
      expect((result as Success<List<RadioStation>, Failure>).value, isEmpty);
    });

    test('forwards repository failures', () async {
      const failure = SocketFailure('offline');
      final repository = _FakeStationRepository(
        searchResult: const FailureResult<List<RadioStation>, Failure>(failure),
      );
      final useCase = SearchStationsUseCase(repository);

      final result = await useCase(const SearchStationsParams(query: 'jazz'));

      expect(result, isA<FailureResult<List<RadioStation>, Failure>>());
      expect(
        (result as FailureResult<List<RadioStation>, Failure>).failure,
        failure,
      );
    });
  });
}

class _FakeStationRepository implements StationRepository {
  _FakeStationRepository({Result<List<RadioStation>, Failure>? searchResult})
    : searchResult =
          searchResult ?? const Success<List<RadioStation>, Failure>([]);

  final Result<List<RadioStation>, Failure> searchResult;
  String? lastSearchQuery;
  String? lastSearchCountryCode;
  String? lastSearchTag;
  int? lastSearchLimit;
  int? lastSearchOffset;

  @override
  Future<Result<List<RadioStation>, Failure>> searchStations({
    String? query,
    String? countryCode,
    String? tag,
    int limit = 30,
    int offset = 0,
  }) async {
    lastSearchQuery = query;
    lastSearchCountryCode = countryCode;
    lastSearchTag = tag;
    lastSearchLimit = limit;
    lastSearchOffset = offset;

    return searchResult;
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
