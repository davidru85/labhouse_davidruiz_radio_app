import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final projectRoot = Directory.current.absolute;

  group('Localization Conformance (Sub-task 2.5)', () {
    test('l10n.yaml configures Flutter localization generation', () {
      final l10nConfig = File('${projectRoot.path}/l10n.yaml');

      expect(l10nConfig.existsSync(), isTrue);

      final configLines = l10nConfig
          .readAsLinesSync()
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();

      expect(
        configLines,
        containsAll([
          'arb-dir: lib/l10n',
          'template-arb-file: intl_en.arb',
          'output-localization-file: app_localizations.dart',
          'nullable-getter: false',
        ]),
      );
    });

    test('pubspec.yaml enables generated localization outputs', () {
      final pubspec = File(
        '${projectRoot.path}/pubspec.yaml',
      ).readAsStringSync();

      expect(
        pubspec,
        contains(RegExp(r'^\s*generate:\s*true$', multiLine: true)),
      );
    });

    test('intl_en.arb defines initial Radio Browser country names', () {
      final arbFile = File('${projectRoot.path}/lib/l10n/intl_en.arb');

      expect(arbFile.existsSync(), isTrue);

      final arb =
          jsonDecode(arbFile.readAsStringSync()) as Map<String, Object?>;

      expect(arb['@@locale'], 'en');
      expect(arb['country_DE'], 'Germany');
      expect(arb['country_AT'], 'Austria');
      expect(arb['country_NL'], 'Netherlands');
      expect(arb['country_FR'], 'France');
    });
  });
}
