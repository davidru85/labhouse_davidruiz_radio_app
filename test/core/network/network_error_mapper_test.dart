import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/network/network_error_mapper.dart';
import 'package:radio_app/domain/failures/failure.dart';

void main() {
  final options = RequestOptions(path: '/json/tags');

  DioException dioError(
    DioExceptionType type, {
    int? statusCode,
    Object? error,
  }) {
    return DioException(
      requestOptions: options,
      type: type,
      error: error,
      response: statusCode == null
          ? null
          : Response<dynamic>(requestOptions: options, statusCode: statusCode),
    );
  }

  group('mapDioException', () {
    test('maps connection/receive/send timeouts to a timeout failure', () {
      expect(
        mapDioException(dioError(DioExceptionType.connectionTimeout)),
        isA<ConnectionTimeoutFailure>(),
      );
      expect(
        mapDioException(dioError(DioExceptionType.receiveTimeout)),
        isA<ConnectionTimeoutFailure>(),
      );
      expect(
        mapDioException(dioError(DioExceptionType.sendTimeout)),
        isA<ConnectionTimeoutFailure>(),
      );
    });

    test('maps a connection error to a socket failure', () {
      expect(
        mapDioException(dioError(DioExceptionType.connectionError)),
        isA<SocketFailure>(),
      );
    });

    test('maps a 5xx response to a server failure', () {
      expect(
        mapDioException(
          dioError(DioExceptionType.badResponse, statusCode: 503),
        ),
        isA<ServerFailure>(),
      );
    });

    test('maps a 422 response to a validation failure', () {
      expect(
        mapDioException(
          dioError(DioExceptionType.badResponse, statusCode: 422),
        ),
        isA<ValidationErrorFailure>(),
      );
    });

    test('maps 401 and 403 responses to an unauthorized failure', () {
      expect(
        mapDioException(
          dioError(DioExceptionType.badResponse, statusCode: 401),
        ),
        isA<UnauthorizedFailure>(),
      );
      expect(
        mapDioException(
          dioError(DioExceptionType.badResponse, statusCode: 403),
        ),
        isA<UnauthorizedFailure>(),
      );
    });

    test('maps an exhausted failover to a mirror failure', () {
      expect(
        mapDioException(
          dioError(
            DioExceptionType.connectionError,
            error: const MirrorFailoverExhausted(),
          ),
        ),
        isA<MirrorFailure>(),
      );
    });
  });
}
