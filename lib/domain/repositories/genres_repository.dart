import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/genre.dart';
import 'package:radio_app/domain/failures/failure.dart';

/// Domain contract for station genre metadata.
// ignore: one_member_abstracts
abstract interface class GenresRepository {
  /// Loads genres with an optional maximum [limit].
  Future<Result<List<Genre>, Failure>> getGenres({int limit = 50});
}
