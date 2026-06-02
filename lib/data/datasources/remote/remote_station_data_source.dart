import 'package:dio/dio.dart';
import 'package:radio_app/core/network/network_error_mapper.dart';
import 'package:radio_app/core/network/network_exception.dart';
import 'package:radio_app/data/models/station_dto.dart';
import 'package:radio_app/domain/entities/radio_station.dart';

/// Remote data source for stations (Radio Browser `/json/stations/*`).
abstract interface class RemoteStationDataSource {
  /// Searches stations via `/json/stations/search` (per `API_SPEC.md` §5.1).
  Future<List<RadioStation>> searchStations({
    String? query,
    String? countryCode,
    String? tag,
    int limit,
    int offset,
  });

  /// Fetches popular stations via the search endpoint ordered by clickcount
  /// (per `API_SPEC.md` §5.2 / ADR-0027).
  Future<List<RadioStation>> getPopularStations({int limit});

  /// Fetches stations by their `stationuuid`s via `/json/stations/byuuid`
  /// (per `API_SPEC.md` §5.6).
  Future<List<RadioStation>> getStationsByUuids(List<String> uuids);
}

/// Dio-based [RemoteStationDataSource].
class DioRemoteStationDataSource implements RemoteStationDataSource {
  /// Creates the data source over a configured Dio client (per ADR-0039).
  DioRemoteStationDataSource(this._dio);

  final Dio _dio;

  @override
  Future<List<RadioStation>> searchStations({
    String? query,
    String? countryCode,
    String? tag,
    int limit = 30,
    int offset = 0,
  }) {
    return _getStations('/json/stations/search', <String, dynamic>{
      'hidebroken': true,
      'order': 'clickcount',
      'reverse': true,
      'limit': limit,
      'offset': offset,
      if (query != null) 'name': query,
      if (countryCode != null) 'countrycode': countryCode,
      if (tag != null) 'tag': tag,
    });
  }

  @override
  Future<List<RadioStation>> getPopularStations({int limit = 30}) {
    return _getStations('/json/stations/search', <String, dynamic>{
      'hidebroken': true,
      'order': 'clickcount',
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

  /// Performs a GET returning a station list, mapping Dio errors through
  /// [mapDioException] and skipping malformed entries (per `API_SPEC.md` §4).
  Future<List<RadioStation>> _getStations(
    String path,
    Map<String, dynamic> queryParameters,
  ) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        path,
        queryParameters: queryParameters,
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
