import 'package:radio_app/domain/entities/genre.dart';

/// Data-layer model for a Radio Browser tag/genre JSON payload.
class GenreDto {
  /// Creates a genre DTO.
  GenreDto({required this.name, required this.stationCount});

  /// Parses a Radio Browser `/json/tags` JSON object.
  factory GenreDto.fromJson(Map<String, dynamic> json) {
    return GenreDto(
      name: json['name'] as String,
      stationCount: json['stationcount'] as int?,
    );
  }

  /// Raw `name`.
  final String name;

  /// Raw `stationcount`.
  final int? stationCount;

  /// Maps this DTO to a domain [Genre].
  Genre toEntity() => Genre(name: name, stationCount: stationCount);
}
