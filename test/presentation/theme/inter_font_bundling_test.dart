import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Slice 2a — Inter font bundled locally (TECHNICAL_SPEC §10, ADR-0018).
///
/// Inter MUST be bundled in `pubspec.yaml` with its license tracked, rather
/// than pulling an unapproved font package. These tests pin the declaration,
/// the four weight assets, and the license file.
void main() {
  late String pubspec;

  setUp(() {
    pubspec = File('pubspec.yaml').readAsStringSync();
  });

  group('pubspec font declaration', () {
    test('declares the Inter family', () {
      expect(
        pubspec.contains('- family: Inter'),
        isTrue,
        reason: 'pubspec.yaml must declare the Inter font family',
      );
    });

    test('declares all four weights (400/500/600/700)', () {
      for (final entry in const {
        'assets/fonts/Inter-Regular.ttf': 400,
        'assets/fonts/Inter-Medium.ttf': 500,
        'assets/fonts/Inter-SemiBold.ttf': 600,
        'assets/fonts/Inter-Bold.ttf': 700,
      }.entries) {
        expect(
          pubspec.contains('asset: ${entry.key}'),
          isTrue,
          reason: 'pubspec.yaml must declare the asset ${entry.key}',
        );
        expect(
          pubspec.contains('weight: ${entry.value}'),
          isTrue,
          reason: 'pubspec.yaml must declare weight ${entry.value}',
        );
      }
    });
  });

  group('bundled font assets', () {
    for (final path in const [
      'assets/fonts/Inter-Regular.ttf',
      'assets/fonts/Inter-Medium.ttf',
      'assets/fonts/Inter-SemiBold.ttf',
      'assets/fonts/Inter-Bold.ttf',
    ]) {
      test('$path exists', () {
        expect(
          File(path).existsSync(),
          isTrue,
          reason: '$path must be bundled in the repository',
        );
      });
    }

    test('the Inter license is tracked alongside the fonts', () {
      expect(
        File('assets/fonts/Inter-LICENSE.txt').existsSync(),
        isTrue,
        reason: 'The Inter OFL license must be tracked (TECHNICAL_SPEC §10)',
      );
    });
  });
}
