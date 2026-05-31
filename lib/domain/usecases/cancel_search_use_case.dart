import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/station_repository.dart';
import 'package:radio_app/domain/usecases/use_case.dart';

/// Cancels in-flight station search requests.
final class CancelSearchUseCase implements UseCase<void, NoParams> {
  /// Creates a search cancellation use case.
  const CancelSearchUseCase(this._repository);

  final StationRepository _repository;

  /// Cancels pending station search requests.
  @override
  Future<Result<void, Failure>> call(NoParams params) {
    return _repository.cancelPendingRequests();
  }
}
