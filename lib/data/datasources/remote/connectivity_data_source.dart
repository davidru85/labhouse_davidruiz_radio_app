import 'package:connectivity_plus/connectivity_plus.dart';

/// Device connectivity data source — a thin wrapper over `connectivity_plus`
/// exposing online status as booleans for the repository layer (per ADR-0013).
///
/// The device is considered online when at least one active transport is
/// present (any [ConnectivityResult] other than [ConnectivityResult.none]).
abstract interface class ConnectivityDataSource {
  /// Emits `true` when the device is online and `false` when offline.
  Stream<bool> get onlineStatusStream;

  /// Resolves the current online status.
  Future<bool> isOnline();
}

/// `connectivity_plus`-backed [ConnectivityDataSource].
class ConnectivityPlusDataSource implements ConnectivityDataSource {
  /// Creates the data source over a [Connectivity] instance.
  ConnectivityPlusDataSource(this._connectivity);

  final Connectivity _connectivity;

  @override
  Stream<bool> get onlineStatusStream =>
      _connectivity.onConnectivityChanged.map(_isOnline);

  @override
  Future<bool> isOnline() async =>
      _isOnline(await _connectivity.checkConnectivity());

  /// Online when at least one active transport is present (any result other
  /// than [ConnectivityResult.none]).
  bool _isOnline(List<ConnectivityResult> results) => results.any(
    (ConnectivityResult result) => result != ConnectivityResult.none,
  );
}
