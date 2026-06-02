import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/core/network/network_exception.dart';
import 'package:radio_app/data/datasources/remote/remote_station_data_source.dart';
import 'package:radio_app/data/datasources/remote/station_sort.dart';
import 'package:radio_app/data/repositories/station_repository_impl.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';

void main() {
  group('StationRepositoryImpl', () {
    group('searchStations', () {
      test('delegates query and filters to the remote data source', () async {
        final stations = [_station(stationUuid: 'search-result')];
        final remote = _FakeRemoteStationDataSource(searchResult: stations);
        final repository = StationRepositoryImpl(remote);

        final result = await repository.searchStations(
          query: 'jazz',
          countryCode: 'DE',
          tag: 'swing',
          limit: 25,
          offset: 50,
        );

        expect(result, isA<Success<List<RadioStation>, Failure>>());
        expect(
          (result as Success<List<RadioStation>, Failure>).value,
          stations,
        );
        expect(remote.lastSearchQuery, 'jazz');
        expect(remote.lastSearchCountryCode, 'DE');
        expect(remote.lastSearchTag, 'swing');
        expect(remote.lastSearchLimit, 25);
        expect(remote.lastSearchOffset, 50);
      });

      test('returns Success with an empty list for zero results', () async {
        final remote = _FakeRemoteStationDataSource(searchResult: const []);
        final repository = StationRepositoryImpl(remote);

        final result = await repository.searchStations(query: 'none');

        expect(result, isA<Success<List<RadioStation>, Failure>>());
        expect(
          (result as Success<List<RadioStation>, Failure>).value,
          isEmpty,
        );
      });

      test('maps a NetworkException to a FailureResult', () async {
        const failure = SocketFailure();
        final remote = _FakeRemoteStationDataSource(
          searchError: const NetworkException(failure),
        );
        final repository = StationRepositoryImpl(remote);

        final result = await repository.searchStations(query: 'jazz');

        expect(result, isA<FailureResult<List<RadioStation>, Failure>>());
        expect(
          (result as FailureResult<List<RadioStation>, Failure>).failure,
          failure,
        );
      });
    });

    group('loadPopularStations', () {
      test('searches by click count with pagination (ADR-0027)', () async {
        final stations = [_station(stationUuid: 'popular-1')];
        final remote = _FakeRemoteStationDataSource(searchResult: stations);
        final repository = StationRepositoryImpl(remote);

        final result = await repository.loadPopularStations(
          limit: 15,
          offset: 30,
        );

        expect(result, isA<Success<List<RadioStation>, Failure>>());
        expect(
          (result as Success<List<RadioStation>, Failure>).value,
          stations,
        );
        expect(remote.lastSearchSort, StationSort.clickCount);
        expect(remote.lastSearchLimit, 15);
        expect(remote.lastSearchOffset, 30);
        expect(remote.lastSearchQuery, isNull);
        expect(remote.lastSearchCountryCode, isNull);
        expect(remote.lastSearchTag, isNull);
      });

      test('maps a NetworkException to a FailureResult', () async {
        const failure = MirrorFailure();
        final remote = _FakeRemoteStationDataSource(
          searchError: const NetworkException(failure),
        );
        final repository = StationRepositoryImpl(remote);

        final result = await repository.loadPopularStations();

        expect(result, isA<FailureResult<List<RadioStation>, Failure>>());
        expect(
          (result as FailureResult<List<RadioStation>, Failure>).failure,
          failure,
        );
      });
    });

    group('getStationByUuid', () {
      test('returns the matching station from a byuuid lookup', () async {
        final station = _station(stationUuid: 'uuid-1');
        final remote = _FakeRemoteStationDataSource(byUuidsResult: [station]);
        final repository = StationRepositoryImpl(remote);

        final result = await repository.getStationByUuid('uuid-1');

        expect(result, isA<Success<RadioStation?, Failure>>());
        expect(
          (result as Success<RadioStation?, Failure>).value,
          station,
        );
        expect(remote.lastByUuids, ['uuid-1']);
      });

      test('returns Success(null) when no station matches', () async {
        final remote = _FakeRemoteStationDataSource(byUuidsResult: const []);
        final repository = StationRepositoryImpl(remote);

        final result = await repository.getStationByUuid('missing');

        expect(result, isA<Success<RadioStation?, Failure>>());
        expect((result as Success<RadioStation?, Failure>).value, isNull);
      });

      test('maps a NetworkException to a FailureResult', () async {
        const failure = ConnectionTimeoutFailure();
        final remote = _FakeRemoteStationDataSource(
          byUuidsError: const NetworkException(failure),
        );
        final repository = StationRepositoryImpl(remote);

        final result = await repository.getStationByUuid('uuid-1');

        expect(result, isA<FailureResult<RadioStation?, Failure>>());
        expect(
          (result as FailureResult<RadioStation?, Failure>).failure,
          failure,
        );
      });
    });

    group('cancelPendingRequests', () {
      test('cancels the remote search and returns Success', () async {
        final remote = _FakeRemoteStationDataSource();
        final repository = StationRepositoryImpl(remote);

        final result = await repository.cancelPendingRequests();

        expect(result, isA<Success<void, Failure>>());
        expect(remote.cancelSearchCallCount, 1);
      });
    });
  });
}

class _FakeRemoteStationDataSource implements RemoteStationDataSource {
  _FakeRemoteStationDataSource({
    List<RadioStation>? searchResult,
    List<RadioStation>? byUuidsResult,
    this.searchError,
    this.byUuidsError,
  }) : searchResult = searchResult ?? const [],
       byUuidsResult = byUuidsResult ?? const [];

  final List<RadioStation> searchResult;
  final List<RadioStation> byUuidsResult;
  final NetworkException? searchError;
  final NetworkException? byUuidsError;

  String? lastSearchQuery;
  String? lastSearchCountryCode;
  String? lastSearchTag;
  StationSort? lastSearchSort;
  int? lastSearchLimit;
  int? lastSearchOffset;
  List<String>? lastByUuids;
  int cancelSearchCallCount = 0;

  @override
  Future<List<RadioStation>> searchStations({
    String? query,
    String? countryCode,
    String? tag,
    StationSort sort = StationSort.clickCount,
    int limit = 30,
    int offset = 0,
  }) async {
    lastSearchQuery = query;
    lastSearchCountryCode = countryCode;
    lastSearchTag = tag;
    lastSearchSort = sort;
    lastSearchLimit = limit;
    lastSearchOffset = offset;
    final error = searchError;
    if (error != null) {
      throw error;
    }
    return searchResult;
  }

  @override
  Future<List<RadioStation>> getPopularStations({
    StationSort sort = StationSort.clickCount,
    int limit = 30,
  }) async {
    final error = searchError;
    if (error != null) {
      throw error;
    }
    return searchResult;
  }

  @override
  Future<List<RadioStation>> getStationsByUuids(List<String> uuids) async {
    lastByUuids = uuids;
    final error = byUuidsError;
    if (error != null) {
      throw error;
    }
    return byUuidsResult;
  }

  @override
  void cancelSearch() {
    cancelSearchCallCount++;
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
