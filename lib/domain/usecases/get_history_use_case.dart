import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/history_repository.dart';
import 'package:radio_app/domain/usecases/use_case.dart';

/// Returns the recently played station history.
final class GetHistoryUseCase implements UseCase<List<RadioStation>, NoParams> {
  /// Creates a history retrieval use case.
  const GetHistoryUseCase(this._repository);

  final HistoryRepository _repository;

  /// Reads the current recently played history through the repository.
  @override
  Future<Result<List<RadioStation>, Failure>> call(NoParams params) {
    return _repository.getHistory();
  }
}
