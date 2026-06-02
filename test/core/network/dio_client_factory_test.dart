import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:radio_app/core/constants/mirrors.dart';
import 'package:radio_app/core/network/dio_client_factory.dart';
import 'package:radio_app/core/network/mirror_failover_interceptor.dart';
import 'package:radio_app/data/datasources/local/mirror_cache_data_source.dart';

class _MockMirrorCache extends Mock implements MirrorCacheDataSource {}

void main() {
  late _MockMirrorCache cache;

  setUp(() {
    cache = _MockMirrorCache();
  });

  group('DioClientFactory.create', () {
    test('uses the cached mirror as baseUrl when it is whitelisted', () async {
      when(
        cache.getLastKnownMirror,
      ).thenAnswer((_) async => 'nl1.api.radio-browser.info');

      final dio = await DioClientFactory.create(cache);

      expect(dio.options.baseUrl, 'https://nl1.api.radio-browser.info');
    });

    test('falls back to the first whitelist mirror when uncached', () async {
      when(cache.getLastKnownMirror).thenAnswer((_) async => null);

      final dio = await DioClientFactory.create(cache);

      expect(dio.options.baseUrl, defaultApiMirrors.first);
    });

    test('falls back when the cached host is not whitelisted', () async {
      when(
        cache.getLastKnownMirror,
      ).thenAnswer((_) async => 'evil.example.com');

      final dio = await DioClientFactory.create(cache);

      expect(dio.options.baseUrl, defaultApiMirrors.first);
    });

    test('attaches the mirror failover interceptor', () async {
      when(cache.getLastKnownMirror).thenAnswer((_) async => null);

      final dio = await DioClientFactory.create(cache);

      expect(
        dio.interceptors.whereType<MirrorFailoverInterceptor>(),
        isNotEmpty,
      );
    });

    test('preserves the required base headers and timeouts', () async {
      when(cache.getLastKnownMirror).thenAnswer((_) async => null);

      final dio = await DioClientFactory.create(cache);

      // API_SPEC §3 — required headers.
      expect(dio.options.headers['User-Agent'], 'RadioApp/1.0');
      expect(
        dio.options.headers['Content-Type'],
        'application/json; charset=utf-8',
      );
      // API_SPEC §4 — explicit request timeouts.
      expect(dio.options.connectTimeout, const Duration(seconds: 30));
      expect(dio.options.receiveTimeout, const Duration(seconds: 60));
    });
  });
}
