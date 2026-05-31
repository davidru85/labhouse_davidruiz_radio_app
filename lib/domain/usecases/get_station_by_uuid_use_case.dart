import 'package:equatable/equatable.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/station_repository.dart';
import 'package:radio_app/domain/usecases/use_case.dart';

/// Loads a station by its stable Radio Browser station UUID.
final class GetStationByUuidUseCase
    implements UseCase<RadioStation?, GetStationByUuidParams> {
  /// Creates a station lookup use case.
  const GetStationByUuidUseCase(this._repository);

  final StationRepository _repository;

  /// Loads the station identified by [params].
  @override
  Future<Result<RadioStation?, Failure>> call(GetStationByUuidParams params) {
    return _repository.getStationByUuid(params.stationUuid);
  }
}

/// Parameters for [GetStationByUuidUseCase].
final class GetStationByUuidParams extends Equatable {
  /// Creates station lookup parameters.
  const GetStationByUuidParams({required this.stationUuid});

  /// Stable Radio Browser station UUID.
  final String stationUuid;

  @override
  List<Object> get props => [stationUuid];
}
