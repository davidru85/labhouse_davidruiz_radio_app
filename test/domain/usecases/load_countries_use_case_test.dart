import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/country.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/countries_repository.dart';
import 'package:radio_app/domain/usecases/load_countries_use_case.dart';
import 'package:radio_app/domain/usecases/use_case.dart';

void main() {
  group('LoadCountriesUseCase', () {
    test('delegates country loading to the repository', () async {
      const countries = [
        Country(name: 'Germany', countryCode: 'DE', stationCount: 1200),
        Country(name: 'France', countryCode: 'FR', stationCount: 900),
      ];
      final repository = _FakeCountriesRepository(
        countriesResult: const Success<List<Country>, Failure>(countries),
      );
      final useCase = LoadCountriesUseCase(repository);

      final result = await useCase(const NoParams());

      expect(result, isA<Success<List<Country>, Failure>>());
      expect((result as Success<List<Country>, Failure>).value, countries);
      expect(repository.getCountriesCalls, 1);
    });

    test('preserves empty successful results', () async {
      final repository = _FakeCountriesRepository(
        countriesResult: const Success<List<Country>, Failure>(<Country>[]),
      );
      final useCase = LoadCountriesUseCase(repository);

      final result = await useCase(const NoParams());

      expect(result, isA<Success<List<Country>, Failure>>());
      expect((result as Success<List<Country>, Failure>).value, isEmpty);
    });

    test('forwards repository failures', () async {
      const failure = ServerFailure('unavailable');
      final repository = _FakeCountriesRepository(
        countriesResult: const FailureResult<List<Country>, Failure>(failure),
      );
      final useCase = LoadCountriesUseCase(repository);

      final result = await useCase(const NoParams());

      expect(result, isA<FailureResult<List<Country>, Failure>>());
      expect(
        (result as FailureResult<List<Country>, Failure>).failure,
        failure,
      );
    });
  });
}

class _FakeCountriesRepository implements CountriesRepository {
  _FakeCountriesRepository({required this.countriesResult});

  final Result<List<Country>, Failure> countriesResult;
  int getCountriesCalls = 0;

  @override
  Future<Result<List<Country>, Failure>> getCountries() async {
    getCountriesCalls++;

    return countriesResult;
  }
}
