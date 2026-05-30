import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/constants/mirrors.dart';
import 'package:radio_app/core/network/dio_client.dart';

void main() {
  group('Mirrors Constants', () {
    test('should define the 4 default HTTPS API mirrors exactly', () {
      expect(defaultApiMirrors, hasLength(4));
      expect(
        defaultApiMirrors,
        containsAll([
          'https://de1.api.radio-browser.info',
          'https://at1.api.radio-browser.info',
          'https://nl1.api.radio-browser.info',
          'https://fr1.api.radio-browser.info',
        ]),
      );
    });
  });

  group('DioClient', () {
    test('should configure connect and receive/read timeouts correctly', () {
      final dio = DioClient.create();

      expect(dio.options.connectTimeout, equals(const Duration(seconds: 30)));
      expect(dio.options.receiveTimeout, equals(const Duration(seconds: 60)));
    });

    test('should configure required headers correctly', () {
      final dio = DioClient.create();

      expect(
        dio.options.headers['Content-Type'],
        equals('application/json; charset=utf-8'),
      );
      expect(dio.options.headers['User-Agent'], equals('RadioApp/1.0'));
    });
  });
}
