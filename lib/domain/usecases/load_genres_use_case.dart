import 'package:equatable/equatable.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/genre.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/genres_repository.dart';
import 'package:radio_app/domain/usecases/use_case.dart';

/// Loads station genres for filter metadata.
final class LoadGenresUseCase
    implements UseCase<List<Genre>, LoadGenresParams> {
  /// Creates a genres loading use case.
  const LoadGenresUseCase(this._repository);

  final GenresRepository _repository;

  /// Loads genres with [params].
  @override
  Future<Result<List<Genre>, Failure>> call(LoadGenresParams params) {
    return _repository.getGenres(limit: params.limit);
  }
}

/// Parameters for [LoadGenresUseCase].
final class LoadGenresParams extends Equatable {
  /// Creates genre loading parameters.
  const LoadGenresParams({this.limit = 50});

  /// Maximum number of genres requested.
  final int limit;

  @override
  List<Object> get props => [limit];
}
