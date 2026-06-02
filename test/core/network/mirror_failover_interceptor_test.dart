import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:radio_app/core/constants/mirrors.dart';
import 'package:radio_app/core/network/mirror_failover_interceptor.dart';
import 'package:radio_app/core/network/network_error_mapper.dart';
import 'package:radio_app/data/datasources/local/mirror_cache_data_source.dart';

class _MockMirrorCache extends Mock implements MirrorCacheDataSource {}

/// Fake adapter returning a programmed status code per mirror host.
/// A status of -1 simulates a connection error.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.statusByHost);

  final Map<String, int> statusByHost;
  final List<String> hostsTried = <String>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final host = options.uri.host;
    hostsTried.add(host);
    final status = statusByHost[host] ?? 500;
    if (status == -1) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'fake connection error',
      );
    }
    return ResponseBody.fromString(
      '[]',
      status,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Dio _dioWith(
  _FakeAdapter adapter,
  MirrorCacheDataSource cache, {
  String? cachedHost,
}) {
  final dio = Dio(BaseOptions(baseUrl: defaultApiMirrors.first))
    ..httpClientAdapter = adapter;
  dio.interceptors.add(
    MirrorFailoverInterceptor(
      dio: dio,
      cache: cache,
      mirrors: defaultApiMirrors,
      cachedHost: cachedHost,
    ),
  );
  return dio;
}

void main() {
  late _MockMirrorCache cache;

  setUp(() {
    cache = _MockMirrorCache();
    when(() => cache.setLastKnownMirror(any())).thenAnswer((_) async {});
  });

  group('MirrorFailoverInterceptor', () {
    test(
      'returns the response without failover on first-mirror success',
      () async {
        final adapter = _FakeAdapter(<String, int>{
          'de1.api.radio-browser.info': 200,
        });
        final dio = _dioWith(
          adapter,
          cache,
          cachedHost: 'de1.api.radio-browser.info',
        );

        final response = await dio.get<dynamic>('/json/tags');

        expect(response.statusCode, 200);
        expect(adapter.hostsTried, <String>['de1.api.radio-browser.info']);
        verifyNever(() => cache.setLastKnownMirror(any()));
      },
    );

    test(
      'rotates to the next mirror on a 5xx and returns its response',
      () async {
        final adapter = _FakeAdapter(<String, int>{
          'de1.api.radio-browser.info': 500,
          'at1.api.radio-browser.info': 200,
        });
        final dio = _dioWith(
          adapter,
          cache,
          cachedHost: 'de1.api.radio-browser.info',
        );

        final response = await dio.get<dynamic>('/json/tags');

        expect(response.statusCode, 200);
        expect(adapter.hostsTried.last, 'at1.api.radio-browser.info');
        verify(
          () => cache.setLastKnownMirror('at1.api.radio-browser.info'),
        ).called(1);
      },
    );

    test(
      'swallows a cache write-back failure on a successful rotation',
      () async {
        // ADR-0039 — mirror write-back is best effort: a cache write failure
        // MUST NOT fail an otherwise successful retried response.
        when(
          () => cache.setLastKnownMirror(any()),
        ).thenThrow(Exception('cache write failed'));
        final adapter = _FakeAdapter(<String, int>{
          'de1.api.radio-browser.info': 500,
          'at1.api.radio-browser.info': 200,
        });
        final dio = _dioWith(
          adapter,
          cache,
          cachedHost: 'de1.api.radio-browser.info',
        );

        final response = await dio.get<dynamic>('/json/tags');

        expect(response.statusCode, 200);
        expect(adapter.hostsTried.last, 'at1.api.radio-browser.info');
        verify(
          () => cache.setLastKnownMirror('at1.api.radio-browser.info'),
        ).called(1);
      },
    );

    test('rotates on a connection error too', () async {
      final adapter = _FakeAdapter(<String, int>{
        'de1.api.radio-browser.info': -1,
        'at1.api.radio-browser.info': 200,
      });
      final dio = _dioWith(
        adapter,
        cache,
        cachedHost: 'de1.api.radio-browser.info',
      );

      final response = await dio.get<dynamic>('/json/tags');

      expect(response.statusCode, 200);
      expect(adapter.hostsTried.last, 'at1.api.radio-browser.info');
    });

    test(
      'switches to the next mirror on each retriable failure (no repeat)',
      () async {
        // ADR-0039 §"Failover rotation": a retriable failure switches the
        // request to the NEXT mirror immediately. An implementation that
        // retried the failed mirror first would surface here as a duplicated
        // leading host in the attempted sequence.
        final adapter = _FakeAdapter(<String, int>{
          'de1.api.radio-browser.info': 500,
          'at1.api.radio-browser.info': 500,
          'nl1.api.radio-browser.info': 200,
        });
        final dio = _dioWith(
          adapter,
          cache,
          cachedHost: 'de1.api.radio-browser.info',
        );

        final response = await dio.get<dynamic>('/json/tags');

        expect(response.statusCode, 200);
        expect(adapter.hostsTried, <String>[
          'de1.api.radio-browser.info',
          'at1.api.radio-browser.info',
          'nl1.api.radio-browser.info',
        ]);
      },
    );

    test('seeds the cache on an uncached first-mirror success', () async {
      // N2 / ADR-0039 — with no cached host, a successful first response
      // seeds the cache with the working mirror's bare host.
      final adapter = _FakeAdapter(<String, int>{
        'de1.api.radio-browser.info': 200,
      });
      final dio = _dioWith(adapter, cache);

      final response = await dio.get<dynamic>('/json/tags');

      expect(response.statusCode, 200);
      expect(adapter.hostsTried, <String>['de1.api.radio-browser.info']);
      verify(
        () => cache.setLastKnownMirror('de1.api.radio-browser.info'),
      ).called(1);
    });

    test('tags an exhausted failover and caps at 6 total attempts', () async {
      final adapter = _FakeAdapter(<String, int>{
        'de1.api.radio-browser.info': 500,
        'at1.api.radio-browser.info': 500,
        'nl1.api.radio-browser.info': 500,
        'fr1.api.radio-browser.info': 500,
      });
      final dio = _dioWith(
        adapter,
        cache,
        cachedHost: 'de1.api.radio-browser.info',
      );

      await expectLater(
        dio.get<dynamic>('/json/tags'),
        throwsA(
          isA<DioException>().having(
            (DioException e) => e.error,
            'error',
            isA<MirrorFailoverExhausted>(),
          ),
        ),
      );
      // API_SPEC §2 — at most 6 total attempts, rotating round-robin across
      // the whitelist and only wrapping back after every mirror is tried.
      expect(adapter.hostsTried, <String>[
        'de1.api.radio-browser.info',
        'at1.api.radio-browser.info',
        'nl1.api.radio-browser.info',
        'fr1.api.radio-browser.info',
        'de1.api.radio-browser.info',
        'at1.api.radio-browser.info',
      ]);
      expect(adapter.hostsTried, hasLength(6));
      // ...and at most 2 attempts per mirror (per-mirror cap). A faulty
      // implementation that retries the same host 6 times would still hit
      // 6 total attempts, so the per-host cap must be asserted explicitly.
      final attemptsPerHost = <String, int>{};
      for (final host in adapter.hostsTried) {
        attemptsPerHost[host] = (attemptsPerHost[host] ?? 0) + 1;
      }
      expect(
        attemptsPerHost.values,
        everyElement(lessThanOrEqualTo(2)),
        reason: 'each mirror is tried at most twice',
      );
      // Rotation must spread attempts across distinct mirrors, not hammer one.
      expect(attemptsPerHost.keys, hasLength(greaterThanOrEqualTo(3)));
    });

    test('does not retry on a non-retriable 4xx', () async {
      final adapter = _FakeAdapter(<String, int>{
        'de1.api.radio-browser.info': 404,
      });
      final dio = _dioWith(
        adapter,
        cache,
        cachedHost: 'de1.api.radio-browser.info',
      );

      await expectLater(
        dio.get<dynamic>('/json/tags'),
        throwsA(isA<DioException>()),
      );
      expect(adapter.hostsTried, <String>['de1.api.radio-browser.info']);
    });
  });
}
