import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/data/models/country_hive_model.dart';
import 'package:radio_app/domain/entities/country.dart';

void main() {
  group('CountryHiveModel', () {
    test('round-trips a country with a station count', () {
      const country = Country(
        name: 'Spain',
        countryCode: 'ES',
        stationCount: 540,
      );

      final restored = CountryHiveModel.fromEntity(country).toEntity();

      expect(restored, country);
    });

    test('round-trips a country whose station count is null', () {
      const country = Country(
        name: 'Andorra',
        countryCode: 'AD',
        stationCount: null,
      );

      final restored = CountryHiveModel.fromEntity(country).toEntity();

      expect(restored, country);
      expect(restored.stationCount, isNull);
    });

    test('preserves the ISO country code verbatim', () {
      const country = Country(
        name: 'Spain',
        countryCode: 'ES',
        stationCount: 1,
      );

      final model = CountryHiveModel.fromEntity(country);

      expect(model.toEntity().countryCode, 'ES');
    });
  });
}
