import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/data/datasources/remote/connectivity_data_source.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/connectivity_repository.dart';

/// [ConnectivityRepository] backed by a [ConnectivityDataSource] over
/// `connectivity_plus` (per ADR-0013).
class ConnectivityRepositoryImpl implements ConnectivityRepository {
  /// Creates the repository over the connectivity data source.
  ConnectivityRepositoryImpl(this._dataSource);

  final ConnectivityDataSource _dataSource;

  @override
  Stream<bool> get connectivityStream => _dataSource.onlineStatusStream;

  @override
  Future<Result<bool, Failure>> checkConnectivity() async {
    try {
      return Success<bool, Failure>(await _dataSource.isOnline());
    } on Object catch (error) {
      return FailureResult<bool, Failure>(SocketFailure(error.toString()));
    }
  }
}
