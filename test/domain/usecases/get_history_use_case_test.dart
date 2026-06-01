import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/history_repository.dart';
import 'package:radio_app/domain/usecases/get_history_use_case.dart';
import 'package:radio_app/domain/usecases/use_case.dart';

void main() {
  group('GetHistoryUseCase', () {
    test('returns the recently played history from the repository', () async {
      final station = _station(stationUuid: 'station-uuid');
      final repository = _FakeHistoryRepository(
        historyResult: Success<List<RadioStation>, Failure>(<RadioStation>[
          station,
        ]),
      );
      final useCase = GetHistoryUseCase(repository);

      final result = await useCase(const NoParams());

      expect(result, isA<Success<List<RadioStation>, Failure>>());
      expect((result as Success<List<RadioStation>, Failure>).value, [station]);
    });

    test('preserves empty successful results', () async {
      final repository = _FakeHistoryRepository(
        historyResult: const Success<List<RadioStation>, Failure>(
          <RadioStation>[],
        ),
      );
      final useCase = GetHistoryUseCase(repository);

      final result = await useCase(const NoParams());

      expect(result, isA<Success<List<RadioStation>, Failure>>());
      expect((result as Success<List<RadioStation>, Failure>).value, isEmpty);
    });

    test('forwards repository failures', () async {
      const failure = StorageReadWriteFailure('read error');
      final repository = _FakeHistoryRepository(
        historyResult: const FailureResult<List<RadioStation>, Failure>(
          failure,
        ),
      );
      final useCase = GetHistoryUseCase(repository);

      final result = await useCase(const NoParams());

      expect(result, isA<FailureResult<List<RadioStation>, Failure>>());
      expect(
        (result as FailureResult<List<RadioStation>, Failure>).failure,
        failure,
      );
    });
  });
}

class _FakeHistoryRepository implements HistoryRepository {
  _FakeHistoryRepository({required this.historyResult});

  final Result<List<RadioStation>, Failure> historyResult;

  @override
  Stream<List<RadioStation>> get historyStream =>
      const Stream<List<RadioStation>>.empty();

  @override
  Future<Result<List<RadioStation>, Failure>> getHistory() async {
    return historyResult;
  }

  @override
  Future<Result<void, Failure>> addToHistory(RadioStation station) async {
    return const Success<void, Failure>(null);
  }

  @override
  Future<Result<void, Failure>> clearHistory() async {
    return const Success<void, Failure>(null);
  }
}

RadioStation _station({required String stationUuid}) {
  return RadioStation(
    stationUuid: stationUuid,
    name: 'Jazz FM',
    streamUrl: 'http://example.com/stream',
    resolvedStreamUrl: 'https://example.com/stream',
    favicon: null,
    homepage: null,
    tags: 'jazz,swing',
    tagList: const ['jazz', 'swing'],
    country: 'Germany',
    countryCode: 'DE',
    language: 'german',
    codec: 'MP3',
    bitrate: 128,
    votes: 10,
    clickCount: 20,
    lastCheckOk: true,
    isHLS: false,
  );
}
