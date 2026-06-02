import 'package:dio/dio.dart';
import 'package:radio_app/core/network/network_error_mapper.dart';
import 'package:radio_app/core/network/network_exception.dart';
import 'package:radio_app/data/datasources/remote/station_sort.dart';
import 'package:radio_app/data/models/station_dto.dart';
import 'package:radio_app/domain/entities/radio_station.dart';

/// Remote data source for stations (Radio Browser `/json/stations/*`).
abstract interface class RemoteStationDataSource {
  /// Searches stations via `/json/stations/search` (per `API_SPEC.md` §5.1).
  ///
  /// [sort] selects the `order` parameter (per ADR-0027).
  Future<List<RadioStation>> searchStations({
    String? query,
    String? countryCode,
    String? tag,
    StationSort sort,
    int limit,
    int offset,
  });

  /// Fetches popular stations via the search endpoint ordered by [sort]
  /// (per `API_SPEC.md` §5.2 / ADR-0027).
  Future<List<RadioStation>> getPopularStations({StationSort sort, int limit});

  /// Fetches stations by their `stationuuid`s via `/json/stations/byuuid`
  /// (per `API_SPEC.md` §5.6).
  Future<List<RadioStation>> getStationsByUuids(List<String> uuids);

  /// Cancels any in-flight search request (per ADR-0014).
  void cancelSearch();
}

/// Dio-based [RemoteStationDataSource].
class DioRemoteStationDataSource implements RemoteStationDataSource {
  /// Creates the data source over a configured Dio client (per ADR-0039).
  DioRemoteStationDataSource(this._dio);

  final Dio _dio;

  /// Token for the active search; cancelled on supersession or [cancelSearch].
  CancelToken? _searchCancelToken;

  @override
  Future<List<RadioStation>> searchStations({
    String? query,
    String? countryCode,
    String? tag,
    StationSort sort = StationSort.clickCount,
    int limit = 30,
    int offset = 0,
  }) {
    final cancelToken = _supersedeSearch();
    return _getStations('/json/stations/search', <String, dynamic>{
      'hidebroken': true,
      'order': sort.apiValue,
      'reverse': true,
      'limit': limit,
      'offset': offset,
      if (query != null) 'name': query,
      if (countryCode != null) 'countrycode': countryCode,
      if (tag != null) 'tag': tag,
    }, cancelToken: cancelToken);
  }

  @override
  Future<List<RadioStation>> getPopularStations({
    StationSort sort = StationSort.clickCount,
    int limit = 30,
  }) {
    return _getStations('/json/stations/search', <String, dynamic>{
      'hidebroken': true,
      'order': sort.apiValue,
      'reverse': true,
      'limit': limit,
    });
  }

  @override
  Future<List<RadioStation>> getStationsByUuids(List<String> uuids) {
    if (uuids.isEmpty) {
      return Future<List<RadioStation>>.value(const <RadioStation>[]);
    }
    return _getStations('/json/stations/byuuid', <String, dynamic>{
      'uuid': uuids.join(','),
    });
  }

  @override
  void cancelSearch() {
    _searchCancelToken?.cancel();
    _searchCancelToken = null;
  }

  /// Cancels the previous in-flight search and returns a fresh token for the
  /// new one, so stale responses cannot supersede newer ones (per ADR-0014).
  CancelToken _supersedeSearch() {
    _searchCancelToken?.cancel();
    return _searchCancelToken = CancelToken();
  }

  /// Performs a GET returning a station list, mapping Dio errors through
  /// [mapDioException] and skipping malformed entries (per `API_SPEC.md` §4).
  Future<List<RadioStation>> _getStations(
    String path,
    Map<String, dynamic> queryParameters, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      final data = response.data ?? const <dynamic>[];
      final stations = <RadioStation>[];
      for (final dynamic item in data) {
        final station = _tryParse(item);
        if (station != null) {
          stations.add(station);
        }
      }
      return stations;
    } on DioException catch (exception) {
      throw NetworkException(mapDioException(exception));
    }
  }

  /// Parses a single station entry, skipping malformed or non-map items so
  /// partial payloads degrade gracefully (per `API_SPEC.md` §4).
  RadioStation? _tryParse(dynamic item) {
    if (item is! Map<String, dynamic> ||
        item['stationuuid'] is! String ||
        item['name'] is! String ||
        item['url'] is! String ||
        item['url_resolved'] is! String ||
        item['country'] is! String ||
        item['countrycode'] is! String) {
      return null;
    }
    return StationDto.fromJson(item).toEntity();
  }
}
