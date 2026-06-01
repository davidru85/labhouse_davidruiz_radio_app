import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Linter & Dependencies Conformance (Sub-task 1.2)', () {
    test('analysis_options.yaml uses very_good_analysis', () {
      final optionsFile = File('analysis_options.yaml');
      expect(optionsFile.existsSync(), isTrue);
      final content = optionsFile.readAsStringSync();
      expect(
        content.contains('package:very_good_analysis/analysis_options.yaml'),
        isTrue,
        reason: 'analysis_options.yaml must include very_good_analysis rules',
      );
    });

    test('pubspec.yaml contains all required production dependencies', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final requiredDeps = [
        'flutter_bloc:',
        'equatable:',
        'get_it:',
        'go_router:',
        'dio:',
        'connectivity_plus:',
        'stream_transform:',
        'just_audio:',
        'audio_service:',
        'hive_ce:',
        'hive_ce_flutter:',
        'cached_network_image:',
        'flutter_localizations:',
        'intl:',
      ];
      for (final dep in requiredDeps) {
        expect(
          pubspec.contains(dep),
          isTrue,
          reason: 'pubspec.yaml must contain production dependency: $dep',
        );
      }
    });

    test('pubspec.yaml contains all required dev dependencies', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final requiredDevDeps = [
        'very_good_analysis:',
        'bloc_test:',
        'mocktail:',
        'build_runner:',
        'hive_ce_generator:',
      ];
      for (final dep in requiredDevDeps) {
        expect(
          pubspec.contains(dep),
          isTrue,
          reason: 'pubspec.yaml must contain dev dependency: $dep',
        );
      }
    });
  });
}
