import 'package:radio_app/domain/repositories/connectivity_repository.dart';
import 'package:radio_app/domain/usecases/use_case.dart';

/// Watches network connectivity changes for the presentation layer.
final class WatchConnectivityUseCase implements StreamUseCase<bool, NoParams> {
  /// Creates a connectivity watch use case.
  const WatchConnectivityUseCase(this._repository);

  final ConnectivityRepository _repository;

  /// Relays online status changes from the repository (per ADR-0013).
  @override
  Stream<bool> call(NoParams params) {
    return _repository.connectivityStream;
  }
}
