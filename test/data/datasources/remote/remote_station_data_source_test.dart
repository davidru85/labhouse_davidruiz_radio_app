import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/network/network_exception.dart';
import 'package:radio_app/data/datasources/remote/remote_station_data_source.dart';
import 'package:radio_app/domain/failures/failure.dart';

const _stationJson =
    '[{"stationuuid":"uuid-1","name":"Jazz FM", '
    '"url":"https://example.com/raw", '
    '"url_resolved":"https://example.com/resolved", '
    '"tags":"jazz,blues","country":"Spain","countrycode":"ES", '
    '"votes":42,"clickcount":7,"lastcheckok":1,"hls":0}]';

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter({
    this.body = '[]',
    this.statusCode = 200,
    this.fail = false,
  });

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

({RemoteStationDataSource dataSource, _RecordingAdapter adapter}) _build({
  String body = '[]',
  int statusCode = 200,
  bool fail = false,
}) {
  final adapter = _RecordingAdapter(
    body: body,
    statusCode: statusCode,
    fail: fail,
  );
  final dio = Dio(BaseOptions(baseUrl: 'https://de1.api.radio-browser.info'))
    ..httpClientAdapter = adapter;
  return (dataSource: DioRemoteStationDataSource(dio), adapter: adapter);
}

void main() {
  group('DioRemoteStationDataSource', () {
    group('searchStations', () {
      test('parses the search results into domain stations', () async {
        final harness = _build(body: _stationJson);

        final stations = await harness.dataSource.searchStations(query: 'jazz');

        expect(stations.single.stationUuid, 'uuid-1');
        expect(stations.single.tagList, <String>['jazz', 'blues']);
      });

      test('targets /json/stations/search with the required params', () async {
        final harness = _build(body: _stationJson);

        await harness.dataSource.searchStations(
          query: 'jazz',
          countryCode: 'ES',
          tag: 'blues',
          limit: 15,
          offset: 30,
        );

        final request = harness.adapter.lastRequest!;
        expect(request.path, '/json/stations/search');
        expect(request.queryParameters['hidebroken'], true);
        expect(request.queryParameters['name'], 'jazz');
        expect(request.queryParameters['countrycode'], 'ES');
        expect(request.queryParameters['tag'], 'blues');
        expect(request.queryParameters['limit'], 15);
        expect(request.queryParameters['offset'], 30);
      });

      test('returns an empty list for an empty payload', () async {
        final harness = _build();

        expect(await harness.dataSource.searchStations(), isEmpty);
      });

      test('throws NetworkException on a 5xx', () async {
        final harness = _build(statusCode: 503);

        await expectLater(
          harness.dataSource.searchStations(),
          throwsA(
            isA<NetworkException>().having(
              (NetworkException e) => e.failure,
              'failure',
              isA<ServerFailure>(),
            ),
          ),
        );
      });
    });

    group('getPopularStations', () {
      test('targets the search endpoint ordered by clickcount', () async {
        final harness = _build(body: _stationJson);

        final stations = await harness.dataSource.getPopularStations(limit: 10);

        final request = harness.adapter.lastRequest!;
        expect(request.path, '/json/stations/search');
        expect(request.queryParameters['order'], 'clickcount');
        expect(request.queryParameters['reverse'], true);
        expect(request.queryParameters['hidebroken'], true);
        expect(request.queryParameters['limit'], 10);
        expect(stations.single.stationUuid, 'uuid-1');
      });
    });

    group('getStationsByUuids', () {
      test('targets /json/stations/byuuid with a comma-joined uuid', () async {
        final harness = _build(body: _stationJson);

        await harness.dataSource.getStationsByUuids(<String>['a', 'b']);

        final request = harness.adapter.lastRequest!;
        expect(request.path, '/json/stations/byuuid');
        expect(request.queryParameters['uuid'], 'a,b');
      });

      test('returns an empty list when given no uuids', () async {
        final harness = _build(body: _stationJson);

        expect(
          await harness.dataSource.getStationsByUuids(const <String>[]),
          isEmpty,
        );
      });
    });
  });
}
