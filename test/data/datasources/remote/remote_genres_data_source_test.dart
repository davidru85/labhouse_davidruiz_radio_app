import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/network/network_exception.dart';
import 'package:radio_app/data/datasources/remote/remote_genres_data_source.dart';
import 'package:radio_app/domain/entities/genre.dart';
import 'package:radio_app/domain/failures/failure.dart';

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter({this.body = '[]', this.statusCode = 200, this.fail = false});

  final String body;
  final int statusCode;
  final bool fail;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
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

RemoteGenresDataSource _dataSource(_StubAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://de1.api.radio-browser.info'))
    ..httpClientAdapter = adapter;
  return DioRemoteGenresDataSource(dio);
}

void main() {
  group('DioRemoteGenresDataSource', () {
    test('parses /json/tags into domain genres', () async {
      final dataSource = _dataSource(
        _StubAdapter(
          body:
              '[{"name":"jazz","stationcount":12},'
              '{"name":"rock","stationcount":34}]',
        ),
      );

      final genres = await dataSource.getGenres();

      expect(genres, const <Genre>[
        Genre(name: 'jazz', stationCount: 12),
        Genre(name: 'rock', stationCount: 34),
      ]);
    });

    test('returns an empty list for an empty payload', () async {
      final dataSource = _dataSource(_StubAdapter());

      expect(await dataSource.getGenres(), isEmpty);
    });

    test('skips non-map entries and keeps the valid genres', () async {
      final dataSource = _dataSource(
        _StubAdapter(
          body:
              '[{"name":"jazz","stationcount":12},42,'
              '{"name":"rock","stationcount":34}]',
        ),
      );

      expect(await dataSource.getGenres(), const <Genre>[
        Genre(name: 'jazz', stationCount: 12),
        Genre(name: 'rock', stationCount: 34),
      ]);
    });

    test('skips entries missing the required name field', () async {
      final dataSource = _dataSource(
        _StubAdapter(
          body: '[{"stationcount":5},{"name":"rock","stationcount":34}]',
        ),
      );

      expect(await dataSource.getGenres(), const <Genre>[
        Genre(name: 'rock', stationCount: 34),
      ]);
    });

    test('throws NetworkException(ServerFailure) on a 5xx', () async {
      final dataSource = _dataSource(_StubAdapter(statusCode: 503));

      await expectLater(
        dataSource.getGenres(),
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
        final dataSource = _dataSource(_StubAdapter(fail: true));

        await expectLater(
          dataSource.getGenres(),
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
