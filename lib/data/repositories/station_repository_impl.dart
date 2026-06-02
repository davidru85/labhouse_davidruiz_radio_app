import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/core/network/network_exception.dart';
import 'package:radio_app/data/datasources/remote/remote_station_data_source.dart';
import 'package:radio_app/data/datasources/remote/station_sort.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/station_repository.dart';

/// [StationRepository] backed by a [RemoteStationDataSource] (per ADR-0027/0039).
class StationRepositoryImpl implements StationRepository {
  /// Creates the repository over a remote station data source.
  StationRepositoryImpl(this._remote);

  final RemoteStationDataSource _remote;

  @override
  Future<Result<List<RadioStation>, Failure>> searchStations({
    String? query,
    String? countryCode,
    String? tag,
    int limit = 30,
    int offset = 0,
  }) {
    return _guard(
      () => _remote.searchStations(
        query: query,
        countryCode: countryCode,
        tag: tag,
        limit: limit,
        offset: offset,
      ),
    );
  }

  @override
  Future<Result<List<RadioStation>, Failure>> loadPopularStations({
    int limit = 30,
    int offset = 0,
  }) {
    // Popular sections reuse the search endpoint ordered by click count, which
    // grants pagination for free (per ADR-0027).
    return _guard(
      () => _remote.searchStations(
        sort: StationSort.clickCount,
        limit: limit,
        offset: offset,
      ),
    );
  }

  @override
  Future<Result<RadioStation?, Failure>> getStationByUuid(String stationUuid) {
    return _guard(() async {
      final stations = await _remote.getStationsByUuids([stationUuid]);
      return stations.isEmpty ? null : stations.first;
    });
  }

  @override
  Future<Result<void, Failure>> cancelPendingRequests() async {
    _remote.cancelSearch();
    return const Success<void, Failure>(null);
  }

  /// Runs [operation], wrapping its value in [Success] and mapping any
  /// [NetworkException] from the data layer to a [FailureResult]
  /// (per ADR-0039).
  Future<Result<T, Failure>> _guard<T>(Future<T> Function() operation) async {
    try {
      return Success<T, Failure>(await operation());
    } on NetworkException catch (exception) {
      return FailureResult<T, Failure>(exception.failure);
    }
  }
}
