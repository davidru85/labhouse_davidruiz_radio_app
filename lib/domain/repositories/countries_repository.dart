import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/country.dart';
import 'package:radio_app/domain/failures/failure.dart';

/// Domain contract for station country metadata.
// ignore: one_member_abstracts
abstract interface class CountriesRepository {
  /// Loads supported station countries.
  Future<Result<List<Country>, Failure>> getCountries();
}
