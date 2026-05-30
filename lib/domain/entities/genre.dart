import 'package:equatable/equatable.dart';

/// Immutable domain representation of a station genre or tag.
final class Genre extends Equatable {
  /// Creates a genre domain entity.
  const Genre({required this.name, required this.stationCount});

  /// Genre or tag name.
  final String name;

  /// Optional number of stations associated with this genre.
  final int? stationCount;

  @override
  List<Object?> get props => [name, stationCount];
}
