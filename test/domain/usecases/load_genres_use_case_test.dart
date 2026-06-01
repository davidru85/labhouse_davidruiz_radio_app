import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/genre.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/genres_repository.dart';
import 'package:radio_app/domain/usecases/load_genres_use_case.dart';

void main() {
  group('LoadGenresUseCase', () {
    test('delegates to the repository with the default limit', () async {
      const genres = [
        Genre(name: 'jazz', stationCount: 120),
        Genre(name: 'rock', stationCount: 340),
      ];
      final repository = _FakeGenresRepository(
        genresResult: const Success<List<Genre>, Failure>(genres),
      );
      final useCase = LoadGenresUseCase(repository);

      final result = await useCase(const LoadGenresParams());

      expect(result, isA<Success<List<Genre>, Failure>>());
      expect((result as Success<List<Genre>, Failure>).value, genres);
      expect(repository.lastLimit, 50);
    });

    test('forwards a custom limit to the repository', () async {
      final repository = _FakeGenresRepository(
        genresResult: const Success<List<Genre>, Failure>(<Genre>[]),
      );
      final useCase = LoadGenresUseCase(repository);

      await useCase(const LoadGenresParams(limit: 10));

      expect(repository.lastLimit, 10);
    });

    test('preserves empty successful results', () async {
      final repository = _FakeGenresRepository(
        genresResult: const Success<List<Genre>, Failure>(<Genre>[]),
      );
      final useCase = LoadGenresUseCase(repository);

      final result = await useCase(const LoadGenresParams());

      expect(result, isA<Success<List<Genre>, Failure>>());
      expect((result as Success<List<Genre>, Failure>).value, isEmpty);
    });

    test('forwards a boundary limit verbatim without clamping', () async {
      final repository = _FakeGenresRepository(
        genresResult: const Success<List<Genre>, Failure>(<Genre>[]),
      );
      final useCase = LoadGenresUseCase(repository);

      await useCase(const LoadGenresParams(limit: 0));

      expect(repository.lastLimit, 0);
    });

    test('forwards repository failures', () async {
      const failure = ServerFailure('unavailable');
      final repository = _FakeGenresRepository(
        genresResult: const FailureResult<List<Genre>, Failure>(failure),
      );
      final useCase = LoadGenresUseCase(repository);

      final result = await useCase(const LoadGenresParams());

      expect(result, isA<FailureResult<List<Genre>, Failure>>());
      expect((result as FailureResult<List<Genre>, Failure>).failure, failure);
    });
  });
}

class _FakeGenresRepository implements GenresRepository {
  _FakeGenresRepository({required this.genresResult});

  final Result<List<Genre>, Failure> genresResult;
  int? lastLimit;

  @override
  Future<Result<List<Genre>, Failure>> getGenres({int limit = 50}) async {
    lastLimit = limit;

    return genresResult;
  }
}
