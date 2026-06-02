import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/data/datasources/local/local_history_data_source.dart';
import 'package:radio_app/data/repositories/history_repository_impl.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';

void main() {
  group('HistoryRepositoryImpl', () {
    test('getHistory returns the persisted history', () async {
      final stations = [_station('a'), _station('b')];
      final local = _FakeLocalHistoryDataSource(initial: stations);
      final repository = HistoryRepositoryImpl(local);

      final result = await repository.getHistory();

      expect(result, isA<Success<List<RadioStation>, Failure>>());
      expect((result as Success<List<RadioStation>, Failure>).value, stations);
    });

    test('getHistory maps a storage error to '
        'StorageReadWriteFailure', () async {
      final local = _FakeLocalHistoryDataSource(throwOnGet: true);
      final repository = HistoryRepositoryImpl(local);

      final result = await repository.getHistory();

      expect(result, isA<FailureResult<List<RadioStation>, Failure>>());
      expect(
        (result as FailureResult<List<RadioStation>, Failure>).failure,
        isA<StorageReadWriteFailure>(),
      );
    });

    test('addToHistory persists the station and emits the updated '
        'history', () async {
      final local = _FakeLocalHistoryDataSource();
      final repository = HistoryRepositoryImpl(local);
      final station = _station('a');

      final emission = expectLater(repository.historyStream, emits([station]));
      final result = await repository.addToHistory(station);

      expect(result, isA<Success<void, Failure>>());
      expect(local.stations, [station]);
      await emission;
    });

    test('addToHistory evicts the oldest entry when at the 50-item '
        'cap (FIFO)', () async {
      final initial = [for (var i = 0; i < 50; i++) _station('s$i')];
      final local = _FakeLocalHistoryDataSource(initial: initial);
      final repository = HistoryRepositoryImpl(local);
      final fresh = _station('new');

      await repository.addToHistory(fresh);

      expect(local.stations.length, 50);
      expect(local.stations.first, initial[1]);
      expect(local.stations.last, fresh);
    });

    test('addToHistory moves an existing station to the newest position '
        'instead of duplicating it', () async {
      final initial = [_station('a'), _station('b'), _station('c')];
      final local = _FakeLocalHistoryDataSource(initial: initial);
      final repository = HistoryRepositoryImpl(local);

      await repository.addToHistory(_station('a'));

      expect(local.stations.map((s) => s.stationUuid).toList(), [
        'b',
        'c',
        'a',
      ]);
    });

    test(
      'addToHistory maps a storage error to StorageReadWriteFailure',
      () async {
        final local = _FakeLocalHistoryDataSource(throwOnAdd: true);
        final repository = HistoryRepositoryImpl(local);

        final result = await repository.addToHistory(_station('a'));

        expect(result, isA<FailureResult<void, Failure>>());
        expect(
          (result as FailureResult<void, Failure>).failure,
          isA<StorageReadWriteFailure>(),
        );
      },
    );

    test('clearHistory clears storage and emits an empty history', () async {
      final local = _FakeLocalHistoryDataSource(initial: [_station('a')]);
      final repository = HistoryRepositoryImpl(local);

      final emission = expectLater(
        repository.historyStream,
        emits(<RadioStation>[]),
      );
      final result = await repository.clearHistory();

      expect(result, isA<Success<void, Failure>>());
      expect(local.stations, isEmpty);
      await emission;
    });
  });
}

/// In-memory fake mirroring Hive `put` semantics: re-adding an existing key
/// updates in place (no reorder); the repository owns move-to-top and FIFO.
class _FakeLocalHistoryDataSource implements LocalHistoryDataSource {
  _FakeLocalHistoryDataSource({
    List<RadioStation>? initial,
    this.throwOnGet = false,
    this.throwOnAdd = false,
  }) : stations = [...?initial];

  final bool throwOnGet;
  final bool throwOnAdd;
  final List<RadioStation> stations;

  @override
  Future<List<RadioStation>> getHistory() async {
    if (throwOnGet) {
      throw Exception('hive read error');
    }
    return List.of(stations);
  }

  @override
  Future<void> addToHistory(RadioStation station) async {
    if (throwOnAdd) {
      throw Exception('hive write error');
    }
    final index = stations.indexWhere(
      (s) => s.stationUuid == station.stationUuid,
    );
    if (index >= 0) {
      stations[index] = station;
    } else {
      stations.add(station);
    }
  }

  @override
  Future<void> removeFromHistory(String stationUuid) async {
    stations.removeWhere((s) => s.stationUuid == stationUuid);
  }

  @override
  Future<void> clearHistory() async {
    stations.clear();
  }
}

RadioStation _station(String uuid) => RadioStation(
  stationUuid: uuid,
  name: 'Station $uuid',
  streamUrl: 'https://example.com/$uuid',
  resolvedStreamUrl: 'https://example.com/$uuid/resolved',
  favicon: null,
  homepage: null,
  tags: '',
  tagList: const [],
  country: 'Germany',
  countryCode: 'DE',
  language: null,
  codec: null,
  bitrate: null,
  votes: 0,
  clickCount: 0,
  lastCheckOk: true,
  isHLS: false,
);
