import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/data/models/country_code_dto.dart';

void main() {
  group('CountryCodeDto', () {
    test('maps the ISO code to both countryCode and the raw name', () {
      final country = CountryCodeDto.fromJson(<String, dynamic>{
        'name': 'ES',
        'stationcount': 540,
      }).toEntity();

      // Per ADR-0032 (amended): the data mapper does not localize; the
      // display name is resolved at the presentation boundary.
      expect(country.countryCode, 'ES');
      expect(country.name, 'ES');
      expect(country.stationCount, 540);
    });

    test('maps an absent stationcount to null', () {
      final country = CountryCodeDto.fromJson(<String, dynamic>{
        'name': 'AD',
      }).toEntity();

      expect(country.countryCode, 'AD');
      expect(country.stationCount, isNull);
    });
  });
}
