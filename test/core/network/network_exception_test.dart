import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/network/network_exception.dart';
import 'package:radio_app/domain/failures/failure.dart';

void main() {
  group('NetworkException', () {
    test('is an Exception carrying the mapped failure', () {
      const failure = ServerFailure();

      const exception = NetworkException(failure);

      expect(exception, isA<Exception>());
      expect(exception.failure, same(failure));
    });
  });
}
