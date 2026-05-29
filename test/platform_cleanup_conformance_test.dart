import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Platform Cleanup & Naming Conformance', () {
    test('non-conforming platform folders do not exist', () {
      expect(Directory('web').existsSync(), isFalse, reason: 'web/ folder must be deleted');
      expect(Directory('macos').existsSync(), isFalse, reason: 'macos/ folder must be deleted');
      expect(Directory('linux').existsSync(), isFalse, reason: 'linux/ folder must be deleted');
      expect(Directory('windows').existsSync(), isFalse, reason: 'windows/ folder must be deleted');
    });

    test('package name in pubspec.yaml is radio_app', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec.contains('name: radio_app\n'), isTrue, reason: 'pubspec.yaml name must be updated to radio_app');
    });

    test('main.dart contains a minimal clean shell and not the counter app', () {
      final mainContent = File('lib/main.dart').readAsStringSync();
      expect(mainContent.contains('MyHomePage'), isFalse, reason: 'main.dart should not contain MyHomePage');
      expect(mainContent.contains('_counter'), isFalse, reason: 'main.dart should not contain counter state');
    });
  });
}
