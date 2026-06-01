import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/utils/country_name_resolver.dart';

void main() {
  group('resolveCountryName', () {
    test('returns the localized name from the lookup callback', () {
      final name = resolveCountryName(
        'ES',
        (String key) => key == 'country_ES' ? 'Spain' : null,
      );

      expect(name, 'Spain');
    });

    test('builds the lookup key from the uppercased ISO code', () {
      String? capturedKey;
      resolveCountryName('es', (String key) {
        capturedKey = key;
        return 'Spain';
      });

      expect(capturedKey, 'country_ES');
    });

    test('falls back to the uppercase ISO code when lookup returns null', () {
      expect(resolveCountryName('us', (_) => null), 'US');
    });

    test('falls back when the lookup has no entry for the code', () {
      final name = resolveCountryName(
        'xx',
        (String key) => key == 'country_ES' ? 'Spain' : null,
      );

      expect(name, 'XX');
    });
  });
}
