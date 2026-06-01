import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/connectivity_repository.dart';
import 'package:radio_app/domain/usecases/use_case.dart';
import 'package:radio_app/domain/usecases/watch_connectivity_use_case.dart';

void main() {
  group('WatchConnectivityUseCase', () {
    test('relays connectivity changes from the repository', () {
      final repository = _FakeConnectivityRepository(
        stream: Stream<bool>.fromIterable([true, false, true]),
      );
      final useCase = WatchConnectivityUseCase(repository);

      expect(useCase(const NoParams()), emitsInOrder([true, false, true]));
    });

    test('relays the underlying stream completion', () {
      final repository = _FakeConnectivityRepository(
        stream: Stream<bool>.fromIterable([false]),
      );
      final useCase = WatchConnectivityUseCase(repository);

      expect(useCase(const NoParams()), emitsInOrder([false, emitsDone]));
    });
  });
}

class _FakeConnectivityRepository implements ConnectivityRepository {
  _FakeConnectivityRepository({required Stream<bool> stream})
    : _stream = stream;

  final Stream<bool> _stream;

  @override
  Stream<bool> get connectivityStream => _stream;

  @override
  Future<Result<bool, Failure>> checkConnectivity() async {
    return const Success<bool, Failure>(true);
  }
}
