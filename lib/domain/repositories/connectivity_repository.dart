import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/failures/failure.dart';

/// Domain contract for network connectivity state.
abstract interface class ConnectivityRepository {
  /// Emits online status changes.
  Stream<bool> get connectivityStream;

  /// Checks whether the device currently has network connectivity.
  Future<Result<bool, Failure>> checkConnectivity();
}
