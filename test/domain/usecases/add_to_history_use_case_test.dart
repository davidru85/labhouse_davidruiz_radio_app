import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/history_repository.dart';
import 'package:radio_app/domain/usecases/add_to_history_use_case.dart';

void main() {
  group('AddToHistoryUseCase', () {
    test('delegates the station to the repository', () async {
      final station = _station(stationUuid: 'station-uuid');
      final repository = _FakeHistoryRepository(
        addResult: const Success<void, Failure>(null),
      );
      final useCase = AddToHistoryUseCase(repository);

      final result = await useCase(AddToHistoryParams(station: station));

      expect(result, isA<Success<void, Failure>>());
      expect(repository.addedStation, station);
    });

    test('forwards repository failures', () async {
      const failure = StorageReadWriteFailure('write error');
      final station = _station(stationUuid: 'station-uuid');
      final repository = _FakeHistoryRepository(
        addResult: const FailureResult<void, Failure>(failure),
      );
      final useCase = AddToHistoryUseCase(repository);

      final result = await useCase(AddToHistoryParams(station: station));

      expect(result, isA<FailureResult<void, Failure>>());
      expect((result as FailureResult<void, Failure>).failure, failure);
      expect(repository.addedStation, station);
    });
  });
}

class _FakeHistoryRepository implements HistoryRepository {
  _FakeHistoryRepository({required this.addResult});

  final Result<void, Failure> addResult;
  RadioStation? addedStation;

  @override
  Stream<List<RadioStation>> get historyStream =>
      const Stream<List<RadioStation>>.empty();

  @override
  Future<Result<List<RadioStation>, Failure>> getHistory() async {
    return const Success<List<RadioStation>, Failure>(<RadioStation>[]);
  }

  @override
  Future<Result<void, Failure>> addToHistory(RadioStation station) async {
    addedStation = station;

    return addResult;
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
