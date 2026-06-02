import 'package:dio/dio.dart';
import 'package:radio_app/core/network/network_error_mapper.dart';
import 'package:radio_app/data/datasources/local/mirror_cache_data_source.dart';

/// Dio interceptor implementing Radio Browser mirror failover (per ADR-0039,
/// `API_SPEC.md` §2).
///
/// On a retriable error it rotates to the next mirror and re-dispatches,
/// capped at 2 attempts per mirror and 6 total. On success against a mirror
/// other than the cached one it writes the working mirror back. When the
/// caps are reached it tags the propagated [DioException] with a
/// [MirrorFailoverExhausted] sentinel so the error mapper yields a
/// `MirrorFailure`.
class MirrorFailoverInterceptor extends Interceptor {
  /// Creates the interceptor over the [dio] it is attached to.
  MirrorFailoverInterceptor({
    required Dio dio,
    required MirrorCacheDataSource cache,
    required List<String> mirrors,
    required String? cachedHost,
  }) : _dio = dio,
       _cache = cache,
       _mirrors = mirrors,
       _cachedHost = cachedHost;

  static const int _maxTotalAttempts = 6;
  static const int _attemptsPerMirror = 2;
  static const String _attemptKey = 'mirror_failover_attempt';

  final Dio _dio;
  final MirrorCacheDataSource _cache;
  final List<String> _mirrors;
  final String? _cachedHost;

  /// Hard ceiling on total attempts. With round-robin rotation a mirror is
  /// hit `ceil(total / N)` times, so capping the total at the smaller of the
  /// global 6-attempt limit and `_attemptsPerMirror * N` is what enforces the
  /// "≤ 2 attempts per mirror" cap — it holds for the 4-mirror whitelist and
  /// stays correct if the list ever shrinks.
  int get _maxAttempts =>
      _maxTotalAttempts < _attemptsPerMirror * _mirrors.length
      ? _maxTotalAttempts
      : _attemptsPerMirror * _mirrors.length;

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _writeBackIfChanged(response.requestOptions.uri.host);
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_isRetriable(err)) {
      handler.next(err);
      return;
    }

    final options = err.requestOptions;
    final attempt = (options.extra[_attemptKey] as int?) ?? 1;
    final nextAttempt = attempt + 1;

    if (nextAttempt > _maxAttempts) {
      handler.reject(err.copyWith(error: const MirrorFailoverExhausted()));
      return;
    }

    // Round-robin rotation (ADR-0039 §"Failover rotation"): every retriable
    // failure moves the request to the NEXT mirror immediately. Attempt `k`
    // targets mirror `(k - 1) % N`, so the rotation only re-uses a mirror
    // after every other mirror has been tried once.
    final mirrorIndex = (nextAttempt - 1) % _mirrors.length;

    options
      ..baseUrl = _mirrors[mirrorIndex]
      ..extra[_attemptKey] = nextAttempt;

    try {
      final response = await _dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.reject(e);
    }
  }

  bool _isRetriable(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        return (err.response?.statusCode ?? 0) >= 500;
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return false;
    }
  }

  void _writeBackIfChanged(String host) {
    if (host.isEmpty || host == _cachedHost) {
      return;
    }
    // Best-effort: a write-back failure must not fail the request. The call
    // is issued synchronously; `.ignore()` drops async errors and the
    // try/catch drops a synchronous throw.
    try {
      _cache.setLastKnownMirror(host).ignore();
    } on Object {
      // Swallowed on purpose: persistence is best-effort (ADR-0039).
    }
  }
}
