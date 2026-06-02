import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/country.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/countries_repository.dart';
import 'package:radio_app/domain/usecases/load_countries_use_case.dart';
import 'package:radio_app/presentation/blocs/countries/countries_bloc.dart';

// Use cases are `final` (unmockable outside their library): mock the repository
// contract and build the real use case, keeping the BLoC use-case-only
// (ARCHITECTURE.md §"Dependency Rule").
class _MockCountriesRepository extends Mock implements CountriesRepository {}

void main() {
  late _MockCountriesRepository repository;

  setUp(() {
    repository = _MockCountriesRepository();
  });

  CountriesBloc build() => CountriesBloc(LoadCountriesUseCase(repository));

  group('CountriesBloc', () {
    const countries = [
      Country(name: 'Germany', countryCode: 'DE', stationCount: 500),
      Country(name: 'France', countryCode: 'FR', stationCount: 300),
    ];

    blocTest<CountriesBloc, CountriesState>(
      'emits [loading, success] with the loaded countries on CountriesStarted',
      setUp: () => when(repository.getCountries).thenAnswer(
        (_) async => const Success<List<Country>, Failure>(countries),
      ),
      build: build,
      act: (bloc) => bloc.add(const CountriesStarted()),
      expect: () => const [
        CountriesLoadInProgress(),
        CountriesLoadSuccess(countries),
      ],
    );

    blocTest<CountriesBloc, CountriesState>(
      'emits [loading, success] with an empty list when no countries exist',
      setUp: () => when(
        repository.getCountries,
      ).thenAnswer((_) async => const Success<List<Country>, Failure>([])),
      build: build,
      act: (bloc) => bloc.add(const CountriesStarted()),
      expect: () => const [CountriesLoadInProgress(), CountriesLoadSuccess([])],
    );

    blocTest<CountriesBloc, CountriesState>(
      'emits [loading, failure] when loading countries fails',
      setUp: () => when(repository.getCountries).thenAnswer(
        (_) async =>
            const FailureResult<List<Country>, Failure>(ServerFailure()),
      ),
      build: build,
      act: (bloc) => bloc.add(const CountriesStarted()),
      expect: () => [
        const CountriesLoadInProgress(),
        isA<CountriesLoadFailure>(),
      ],
    );
  });
}
