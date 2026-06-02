import 'package:radio_app/domain/failures/failure.dart';

/// Exception that carries a mapped domain [Failure] across the
/// data-source -> repository boundary (per ADR-0039).
///
/// Remote data sources catch `DioException`, map it via `mapDioException`,
/// and throw this so Phase 6 repositories can convert it to a `Result`
/// without `DioException` leaking out of the data layer.
class NetworkException implements Exception {
  /// Creates a network exception wrapping [failure].
  const NetworkException(this.failure);

  /// The mapped domain failure.
  final Failure failure;
}
