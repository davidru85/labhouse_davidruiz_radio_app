import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/network/network_exception.dart';
import 'package:radio_app/data/datasources/remote/remote_playback_url_data_source.dart';
import 'package:radio_app/domain/failures/failure.dart';

/// Adapter returning a programmed object body (or simulating a connection
/// error) and recording the dispatched request so the path can be asserted.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter({this.body = '{}', this.statusCode = 200, this.fail = false});

  final String body;
  final int statusCode;
  final bool fail;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    if (fail) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'fake',
      );
    }
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

RemotePlaybackUrlDataSource _dataSource(_StubAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://de1.api.radio-browser.info'))
    ..httpClientAdapter = adapter;
  return DioRemotePlaybackUrlDataSource(dio);
}

void main() {
  group('DioRemotePlaybackUrlDataSource', () {
    test(
      'calls /json/url/{stationuuid} and returns the resolved url',
      () async {
        // API_SPEC §5.3 — the endpoint registers the click and yields the
        // resolved click URL, which is preferred as the stream source.
        final adapter = _StubAdapter(
          body: '{"ok":"true","url":"https://stream.example/live"}',
        );

        final url = await _dataSource(adapter).resolvePlaybackUrl('uuid-123');

        expect(url, 'https://stream.example/live');
        expect(adapter.lastRequest?.uri.path, '/json/url/uuid-123');
      },
    );

    test('returns null when the endpoint reports ok:false', () async {
      // API_SPEC §5.3 — click registration may fail; the caller must be able
      // to fall back to the station URLs rather than fail playback.
      final adapter = _StubAdapter(
        body: '{"ok":"false","url":"https://stream.example/live"}',
      );

      expect(await _dataSource(adapter).resolvePlaybackUrl('uuid-123'), isNull);
    });

    test('returns null when the resolved url is empty', () async {
      final adapter = _StubAdapter(body: '{"ok":"true","url":""}');

      expect(await _dataSource(adapter).resolvePlaybackUrl('uuid-123'), isNull);
    });

    test('returns null when the url field is missing', () async {
      final adapter = _StubAdapter(body: '{"ok":"true"}');

      expect(await _dataSource(adapter).resolvePlaybackUrl('uuid-123'), isNull);
    });

    test('returns null for a malformed (non-object) payload', () async {
      // API_SPEC §4 — malformed payloads degrade gracefully.
      final adapter = _StubAdapter(body: '[]');

      expect(await _dataSource(adapter).resolvePlaybackUrl('uuid-123'), isNull);
    });

    test('throws NetworkException(ServerFailure) on a 5xx', () async {
      final adapter = _StubAdapter(statusCode: 503);

      await expectLater(
        _dataSource(adapter).resolvePlaybackUrl('uuid-123'),
        throwsA(
          isA<NetworkException>().having(
            (NetworkException e) => e.failure,
            'failure',
            isA<ServerFailure>(),
          ),
        ),
      );
    });

    test(
      'throws NetworkException(SocketFailure) on a connection error',
      () async {
        final adapter = _StubAdapter(fail: true);

        await expectLater(
          _dataSource(adapter).resolvePlaybackUrl('uuid-123'),
          throwsA(
            isA<NetworkException>().having(
              (NetworkException e) => e.failure,
              'failure',
              isA<SocketFailure>(),
            ),
          ),
        );
      },
    );
  });
}
