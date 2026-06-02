import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/network/network_exception.dart';
import 'package:radio_app/data/datasources/remote/remote_countries_data_source.dart';
import 'package:radio_app/domain/entities/country.dart';
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

RemoteCountriesDataSource _dataSource(_StubAdapter adapter) {
  final dio = Dio(BaseOptions(baseUrl: 'https://de1.api.radio-browser.info'))
    ..httpClientAdapter = adapter;
  return DioRemoteCountriesDataSource(dio);
}

void main() {
  group('DioRemoteCountriesDataSource', () {
    test('parses /json/countrycodes into domain countries', () async {
      final dataSource = _dataSource(
        _StubAdapter(
          body: '[{"name":"ES","stationcount":540},'
              '{"name":"FR","stationcount":320}]',
        ),
      );

      final countries = await dataSource.getCountries();

      // The ISO code is kept as both code and name (localized later).
      expect(countries, const <Country>[
        Country(name: 'ES', countryCode: 'ES', stationCount: 540),
        Country(name: 'FR', countryCode: 'FR', stationCount: 320),
      ]);
    });

    test('returns an empty list for an empty payload', () async {
      final dataSource = _dataSource(_StubAdapter());

      expect(await dataSource.getCountries(), isEmpty);
    });

    test('throws NetworkException(ServerFailure) on a 5xx', () async {
      final dataSource = _dataSource(_StubAdapter(statusCode: 503));

      await expectLater(
        dataSource.getCountries(),
        throwsA(
          isA<NetworkException>().having(
            (NetworkException e) => e.failure,
            'failure',
            isA<ServerFailure>(),
          ),
        ),
      );
    });

    test('throws NetworkException(SocketFailure) on a connection error',
        () async {
      final dataSource = _dataSource(_StubAdapter(fail: true));

      await expectLater(
        dataSource.getCountries(),
        throwsA(
          isA<NetworkException>().having(
            (NetworkException e) => e.failure,
            'failure',
            isA<SocketFailure>(),
          ),
        ),
      );
    });
  });
}
