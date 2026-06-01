import 'package:hive_ce/hive.dart';
import 'package:radio_app/data/models/station_hive_model.dart';
import 'package:radio_app/domain/entities/radio_station.dart';

/// Local persistence boundary for recently played history (per ADR-0037).
///
/// Exposes domain entities and preserves insertion order. The 50-item cap,
/// FIFO eviction and move-to-top on replay are the repository's
/// responsibility (ADR-0021), not this data source's.
abstract interface class LocalHistoryDataSource {
  /// Returns the persisted history in insertion order.
  Future<List<RadioStation>> getHistory();

  /// Persists [station], keyed by its `stationUuid`.
  Future<void> addToHistory(RadioStation station);

  /// Removes the entry identified by [stationUuid].
  Future<void> removeFromHistory(String stationUuid);

  /// Clears the whole history.
  Future<void> clearHistory();
}

/// Hive-backed [LocalHistoryDataSource] over the `history` box.
class HiveLocalHistoryDataSource implements LocalHistoryDataSource {
  /// Creates the data source over an already-open Hive box.
  HiveLocalHistoryDataSource(this._box);

  final Box<StationHiveModel> _box;

  @override
  Future<List<RadioStation>> getHistory() async {
    return _box.values
        .map((StationHiveModel model) => model.toEntity())
        .toList();
  }

  @override
  Future<void> addToHistory(RadioStation station) {
    return _box.put(station.stationUuid, StationHiveModel.fromEntity(station));
  }

  @override
  Future<void> removeFromHistory(String stationUuid) {
    return _box.delete(stationUuid);
  }

  @override
  Future<void> clearHistory() async {
    await _box.clear();
  }
}
