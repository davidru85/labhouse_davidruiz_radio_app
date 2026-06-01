import 'package:equatable/equatable.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/history_repository.dart';
import 'package:radio_app/domain/usecases/use_case.dart';

/// Adds a station to the recently played history.
final class AddToHistoryUseCase implements UseCase<void, AddToHistoryParams> {
  /// Creates a history insertion use case.
  const AddToHistoryUseCase(this._repository);

  final HistoryRepository _repository;

  /// Records the [params] station as recently played.
  @override
  Future<Result<void, Failure>> call(AddToHistoryParams params) {
    return _repository.addToHistory(params.station);
  }
}

/// Parameters for [AddToHistoryUseCase].
final class AddToHistoryParams extends Equatable {
  /// Creates history insertion parameters.
  const AddToHistoryParams({required this.station});

  /// Station added to recently played history.
  final RadioStation station;

  @override
  List<Object> get props => [station];
}
