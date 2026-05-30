import 'package:dio/dio.dart';

/// A factory class responsible for creating and configuring
/// the baseline [Dio] client.
class DioClient {
  DioClient._();

  /// Creates a configured [Dio] HTTP client instance.
  ///
  /// The configurations are populated using compile-time variables:
  /// - `BASE_USER_AGENT` (defaults to 'RadioApp/1.0')
  /// - `API_CONNECT_TIMEOUT_SECONDS` (defaults to 30)
  /// - `API_READ_TIMEOUT_SECONDS` (defaults to 60)
  static Dio create() {
    const userAgent = String.fromEnvironment(
      'BASE_USER_AGENT',
      defaultValue: 'RadioApp/1.0',
    );

    final connectTimeoutSec =
        int.tryParse(
          const String.fromEnvironment('API_CONNECT_TIMEOUT_SECONDS'),
        ) ??
        30;

    final readTimeoutSec =
        int.tryParse(
          const String.fromEnvironment('API_READ_TIMEOUT_SECONDS'),
        ) ??
        60;

    final options = BaseOptions(
      connectTimeout: Duration(seconds: connectTimeoutSec),
      receiveTimeout: Duration(seconds: readTimeoutSec),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'User-Agent': userAgent,
      },
    );

    return Dio(options);
  }
}
