import 'package:dio/dio.dart';
import 'package:radio_app/domain/failures/failure.dart';

/// Sentinel tagged onto a propagated [DioException] by the mirror failover
/// interceptor when every mirror attempt is exhausted (per ADR-0039).
///
/// It lets [mapDioException] distinguish an exhausted failover from an
/// ordinary connection error. It is neither a [Failure] nor an [Exception]
/// and never reaches the domain layer; the domain value is [MirrorFailure].
class MirrorFailoverExhausted {
  /// Creates the sentinel.
  const MirrorFailoverExhausted();
}

/// Maps a [DioException] to a domain [Failure] (per ADR-0039).
Failure mapDioException(DioException exception) {
  if (exception.error is MirrorFailoverExhausted) {
    return const MirrorFailure();
  }

  switch (exception.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const ConnectionTimeoutFailure();
    case DioExceptionType.connectionError:
      return const SocketFailure();
    case DioExceptionType.badResponse:
      return _mapStatusCode(exception.response?.statusCode);
    case DioExceptionType.cancel:
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      return const SocketFailure();
  }
}

Failure _mapStatusCode(int? statusCode) {
  if (statusCode == 422) {
    return const ValidationErrorFailure();
  }
  if (statusCode == 401 || statusCode == 403) {
    return const UnauthorizedFailure();
  }
  // 5xx and any other non-2xx fall back to a generic server failure: the
  // failure set has no dedicated client-error variant (per ADR-0039).
  return const ServerFailure();
}
