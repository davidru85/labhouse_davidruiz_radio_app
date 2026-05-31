import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/country.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/countries_repository.dart';
import 'package:radio_app/domain/usecases/use_case.dart';

/// Loads supported station countries for filter metadata.
final class LoadCountriesUseCase implements UseCase<List<Country>, NoParams> {
  /// Creates a countries loading use case.
  const LoadCountriesUseCase(this._repository);

  final CountriesRepository _repository;

  /// Loads the supported station countries.
  @override
  Future<Result<List<Country>, Failure>> call(NoParams params) {
    return _repository.getCountries();
  }
}
