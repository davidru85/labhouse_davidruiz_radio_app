import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/data/datasources/remote/connectivity_data_source.dart';
import 'package:radio_app/data/repositories/connectivity_repository_impl.dart';
import 'package:radio_app/domain/failures/failure.dart';

void main() {
  group('ConnectivityRepositoryImpl', () {
    test('connectivityStream forwards the data source online status', () {
      final controller = StreamController<bool>();
      addTearDown(controller.close);
      final dataSource = _FakeConnectivityDataSource(stream: controller.stream);
      final repository = ConnectivityRepositoryImpl(dataSource);

      expectLater(
        repository.connectivityStream,
        emitsInOrder(<bool>[true, false]),
      );
      controller
        ..add(true)
        ..add(false);
    });

    test('checkConnectivity returns the current online status', () async {
      final dataSource = _FakeConnectivityDataSource(online: true);
      final repository = ConnectivityRepositoryImpl(dataSource);

      final result = await repository.checkConnectivity();

      expect(result, isA<Success<bool, Failure>>());
      expect((result as Success<bool, Failure>).value, isTrue);
    });

    test('checkConnectivity maps a probe error to SocketFailure', () async {
      final dataSource = _FakeConnectivityDataSource(throwOnCheck: true);
      final repository = ConnectivityRepositoryImpl(dataSource);

      final result = await repository.checkConnectivity();

      expect(result, isA<FailureResult<bool, Failure>>());
      expect(
        (result as FailureResult<bool, Failure>).failure,
        isA<SocketFailure>(),
      );
    });
  });
}

class _FakeConnectivityDataSource implements ConnectivityDataSource {
  _FakeConnectivityDataSource({
    Stream<bool>? stream,
    this.online = false,
    this.throwOnCheck = false,
  }) : _stream = stream ?? const Stream<bool>.empty();

  final Stream<bool> _stream;
  final bool online;
  final bool throwOnCheck;

  @override
  Stream<bool> get onlineStatusStream => _stream;

  @override
  Future<bool> isOnline() async {
    if (throwOnCheck) {
      throw Exception('connectivity probe failed');
    }
    return online;
  }
}
