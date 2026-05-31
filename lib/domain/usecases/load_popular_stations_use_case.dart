import 'package:equatable/equatable.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/station_repository.dart';
import 'package:radio_app/domain/usecases/use_case.dart';

/// Loads popular stations through the station repository.
final class LoadPopularStationsUseCase
    implements UseCase<List<RadioStation>, LoadPopularStationsParams> {
  /// Creates a popular stations use case.
  const LoadPopularStationsUseCase(this._repository);

  final StationRepository _repository;

  /// Loads popular stations with [params].
  @override
  Future<Result<List<RadioStation>, Failure>> call(
    LoadPopularStationsParams params,
  ) {
    return _repository.loadPopularStations(
      limit: params.limit,
      offset: params.offset,
    );
  }
}

/// Parameters for [LoadPopularStationsUseCase].
final class LoadPopularStationsParams extends Equatable {
  /// Creates popular station loading parameters.
  const LoadPopularStationsParams({this.limit = 30, this.offset = 0});

  /// Maximum number of stations requested.
  final int limit;

  /// Result offset for pagination.
  final int offset;

  @override
  List<Object> get props => [limit, offset];
}
