import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/history_repository.dart';
import 'package:radio_app/domain/usecases/use_case.dart';

/// Clears the recently played station history.
final class ClearHistoryUseCase implements UseCase<void, NoParams> {
  /// Creates a history clearing use case.
  const ClearHistoryUseCase(this._repository);

  final HistoryRepository _repository;

  /// Removes all recently played history through the repository.
  @override
  Future<Result<void, Failure>> call(NoParams params) {
    return _repository.clearHistory();
  }
}
