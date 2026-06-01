import 'package:hive_ce/hive.dart';
import 'package:radio_app/data/models/station_hive_model.dart';
import 'package:radio_app/domain/entities/radio_station.dart';

/// Local persistence boundary for favorite stations (per ADR-0037).
///
/// Exposes domain entities; the [StationHiveModel] persistence type never
/// crosses this boundary.
abstract interface class LocalFavoritesDataSource {
  /// Returns every persisted favorite.
  Future<List<RadioStation>> getFavorites();

  /// Persists [station] as a favorite, keyed by its `stationUuid`.
  Future<void> saveFavorite(RadioStation station);

  /// Removes the favorite identified by [stationUuid].
  Future<void> removeFavorite(String stationUuid);
}

/// Hive-backed [LocalFavoritesDataSource] over the `favorites` box.
class HiveLocalFavoritesDataSource implements LocalFavoritesDataSource {
  /// Creates the data source over an already-open Hive box.
  HiveLocalFavoritesDataSource(this._box);

  final Box<StationHiveModel> _box;

  @override
  Future<List<RadioStation>> getFavorites() async {
    return _box.values
        .map((StationHiveModel model) => model.toEntity())
        .toList();
  }

  @override
  Future<void> saveFavorite(RadioStation station) {
    return _box.put(station.stationUuid, StationHiveModel.fromEntity(station));
  }

  @override
  Future<void> removeFavorite(String stationUuid) {
    return _box.delete(stationUuid);
  }
}
