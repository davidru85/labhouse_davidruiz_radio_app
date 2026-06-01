import 'package:hive_ce/hive.dart';
import 'package:radio_app/domain/entities/genre.dart';

part 'genre_hive_model.g.dart';

/// Hive persistence model for a cached [Genre] (per ADR-0037, `typeId` 1).
@HiveType(typeId: 1)
class GenreHiveModel {
  /// Creates a Hive persistence model.
  GenreHiveModel({required this.name, required this.stationCount});

  /// Projects a domain [genre] into its persistence model.
  factory GenreHiveModel.fromEntity(Genre genre) {
    return GenreHiveModel(name: genre.name, stationCount: genre.stationCount);
  }

  /// Genre or tag name.
  @HiveField(0)
  final String name;

  /// Optional number of stations associated with this genre.
  @HiveField(1)
  final int? stationCount;

  /// Rebuilds the domain entity from the persisted model.
  Genre toEntity() => Genre(name: name, stationCount: stationCount);
}
