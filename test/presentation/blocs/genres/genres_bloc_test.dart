import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/genre.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/genres_repository.dart';
import 'package:radio_app/domain/usecases/load_genres_use_case.dart';
import 'package:radio_app/presentation/blocs/genres/genres_bloc.dart';

// Use cases are `final` (unmockable outside their library): mock the repository
// contract and build the real use case, keeping the BLoC use-case-only
// (ARCHITECTURE.md §"Dependency Rule").
class _MockGenresRepository extends Mock implements GenresRepository {}

void main() {
  late _MockGenresRepository repository;

  setUp(() {
    repository = _MockGenresRepository();
  });

  GenresBloc build() => GenresBloc(LoadGenresUseCase(repository));

  group('GenresBloc', () {
    const genres = [
      Genre(name: 'rock', stationCount: 120),
      Genre(name: 'jazz', stationCount: 80),
    ];

    blocTest<GenresBloc, GenresState>(
      'emits [loading, success] with the loaded genres on GenresStarted',
      setUp: () => when(
        () => repository.getGenres(limit: any(named: 'limit')),
      ).thenAnswer((_) async => const Success<List<Genre>, Failure>(genres)),
      build: build,
      act: (bloc) => bloc.add(const GenresStarted()),
      expect: () => const [GenresLoadInProgress(), GenresLoadSuccess(genres)],
    );

    blocTest<GenresBloc, GenresState>(
      'emits [loading, success] with an empty list when no genres exist',
      setUp: () => when(
        () => repository.getGenres(limit: any(named: 'limit')),
      ).thenAnswer((_) async => const Success<List<Genre>, Failure>([])),
      build: build,
      act: (bloc) => bloc.add(const GenresStarted()),
      expect: () => const [GenresLoadInProgress(), GenresLoadSuccess([])],
    );

    blocTest<GenresBloc, GenresState>(
      'emits [loading, failure] when loading genres fails',
      setUp: () => when(() => repository.getGenres(limit: any(named: 'limit')))
          .thenAnswer(
            (_) async =>
                const FailureResult<List<Genre>, Failure>(ServerFailure()),
          ),
      build: build,
      act: (bloc) => bloc.add(const GenresStarted()),
      expect: () => [const GenresLoadInProgress(), isA<GenresLoadFailure>()],
    );
  });
}
