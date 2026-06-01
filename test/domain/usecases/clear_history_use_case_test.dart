import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/history_repository.dart';
import 'package:radio_app/domain/usecases/clear_history_use_case.dart';
import 'package:radio_app/domain/usecases/use_case.dart';

void main() {
  group('ClearHistoryUseCase', () {
    test('delegates clearing to the repository', () async {
      final repository = _FakeHistoryRepository(
        clearResult: const Success<void, Failure>(null),
      );
      final useCase = ClearHistoryUseCase(repository);

      final result = await useCase(const NoParams());

      expect(result, isA<Success<void, Failure>>());
      expect(repository.clearCalls, 1);
    });

    test('forwards repository failures', () async {
      const failure = StorageReadWriteFailure('clear error');
      final repository = _FakeHistoryRepository(
        clearResult: const FailureResult<void, Failure>(failure),
      );
      final useCase = ClearHistoryUseCase(repository);

      final result = await useCase(const NoParams());

      expect(result, isA<FailureResult<void, Failure>>());
      expect((result as FailureResult<void, Failure>).failure, failure);
      expect(repository.clearCalls, 1);
    });
  });
}

class _FakeHistoryRepository implements HistoryRepository {
  _FakeHistoryRepository({required this.clearResult});

  final Result<void, Failure> clearResult;
  int clearCalls = 0;

  @override
  Stream<List<RadioStation>> get historyStream =>
      const Stream<List<RadioStation>>.empty();

  @override
  Future<Result<List<RadioStation>, Failure>> getHistory() async {
    return const Success<List<RadioStation>, Failure>(<RadioStation>[]);
  }

  @override
  Future<Result<void, Failure>> addToHistory(RadioStation station) async {
    return const Success<void, Failure>(null);
  }

  @override
  Future<Result<void, Failure>> clearHistory() async {
    clearCalls++;

    return clearResult;
  }
}
