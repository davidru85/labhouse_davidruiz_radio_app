import 'package:hive_ce/hive.dart';
import 'package:radio_app/data/models/genre_hive_model.dart';
import 'package:radio_app/domain/entities/genre.dart';

/// Local cache boundary for filter genres (per ADR-0037).
///
/// Exposes domain entities; the [GenreHiveModel] persistence type never
/// crosses this boundary.
abstract interface class LocalGenresDataSource {
  /// Returns the cached genres.
  Future<List<Genre>> getCachedGenres();

  /// Replaces the whole cache with [genres].
  Future<void> cacheGenres(List<Genre> genres);
}

/// Hive-backed [LocalGenresDataSource] over the `genres` box.
class HiveLocalGenresDataSource implements LocalGenresDataSource {
  /// Creates the data source over an already-open Hive box.
  HiveLocalGenresDataSource(this._box);

  final Box<GenreHiveModel> _box;

  @override
  Future<List<Genre>> getCachedGenres() async {
    return _box.values.map((GenreHiveModel model) => model.toEntity()).toList();
  }

  @override
  Future<void> cacheGenres(List<Genre> genres) async {
    await _box.clear();
    await _box.putAll(<String, GenreHiveModel>{
      for (final Genre genre in genres)
        genre.name: GenreHiveModel.fromEntity(genre),
    });
  }
}
