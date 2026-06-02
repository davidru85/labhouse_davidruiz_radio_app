import 'dart:async';

import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/data/datasources/local/local_history_data_source.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/history_repository.dart';

/// [HistoryRepository] backed by local persistence, enforcing the 50-item
/// cap with FIFO eviction and move-to-top on replay (per ADR-0021).
class HistoryRepositoryImpl implements HistoryRepository {
  /// Creates the repository over the local history data source.
  HistoryRepositoryImpl(this._local);

  /// Maximum number of stations retained in history (per ADR-0021).
  static const int maxItems = 50;

  final LocalHistoryDataSource _local;

  final StreamController<List<RadioStation>> _historyController =
      StreamController<List<RadioStation>>.broadcast();

  @override
  Stream<List<RadioStation>> get historyStream => _historyController.stream;

  @override
  Future<Result<List<RadioStation>, Failure>> getHistory() {
    return _guard(_local.getHistory);
  }

  @override
  Future<Result<void, Failure>> addToHistory(RadioStation station) {
    return _guard(() async {
      final current = await _local.getHistory();
      final isPresent = current.any(
        (entry) => entry.stationUuid == station.stationUuid,
      );
      if (isPresent) {
        // Re-adding promotes the entry to the newest position: Hive `put`
        // updates an existing key in place, so remove it first (per ADR-0021).
        await _local.removeFromHistory(station.stationUuid);
      } else if (current.length >= maxItems) {
        // FIFO eviction: drop the oldest entry before appending the new one.
        await _local.removeFromHistory(current.first.stationUuid);
      }
      await _local.addToHistory(station);
      await _emitHistory();
    });
  }

  @override
  Future<Result<void, Failure>> clearHistory() {
    return _guard(() async {
      await _local.clearHistory();
      await _emitHistory();
    });
  }

  /// Reads the current history and pushes it onto [historyStream].
  Future<void> _emitHistory() async {
    _historyController.add(await _local.getHistory());
  }

  /// Runs [operation], wrapping its value in [Success] and mapping any
  /// local-storage error to a [StorageReadWriteFailure].
  Future<Result<T, Failure>> _guard<T>(Future<T> Function() operation) async {
    try {
      return Success<T, Failure>(await operation());
    } on Object catch (error) {
      return FailureResult<T, Failure>(
        StorageReadWriteFailure(error.toString()),
      );
    }
  }
}
