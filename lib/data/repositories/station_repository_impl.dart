import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/data/datasources/remote/remote_station_data_source.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/station_repository.dart';

/// [StationRepository] backed by a [RemoteStationDataSource] (per ADR-0027/0039).
class StationRepositoryImpl implements StationRepository {
  /// Creates the repository over a remote station data source.
  StationRepositoryImpl(this._remote);

  // ignore: unused_field
  final RemoteStationDataSource _remote;

  @override
  Future<Result<List<RadioStation>, Failure>> searchStations({
    String? query,
    String? countryCode,
    String? tag,
    int limit = 30,
    int offset = 0,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<List<RadioStation>, Failure>> loadPopularStations({
    int limit = 30,
    int offset = 0,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<RadioStation?, Failure>> getStationByUuid(String stationUuid) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void, Failure>> cancelPendingRequests() {
    throw UnimplementedError();
  }
}
