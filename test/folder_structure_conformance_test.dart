import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Folder Structure & App Configuration Conformance', () {
    const expectedDirectories = [
      'lib/core/constants',
      'lib/core/errors',
      'lib/core/network',
      'lib/core/utils',
      'lib/data/datasources',
      'lib/data/models',
      'lib/data/repositories',
      'lib/domain/entities',
      'lib/domain/failures',
      'lib/domain/repositories',
      'lib/domain/usecases',
      'lib/presentation/blocs',
      'lib/presentation/screens',
      'lib/presentation/widgets',
    ];

    for (final dirPath in expectedDirectories) {
      test('Directory "$dirPath" exists', () {
        expect(
          Directory(dirPath).existsSync(),
          isTrue,
          reason:
              'Mandatory Clean Architecture directory "$dirPath" must exist',
        );
      });
    }

    test('Configuration file "config/app.json" exists', () {
      expect(
        File('config/app.json').existsSync(),
        isTrue,
        reason: 'Compile-time configuration file "config/app.json" must exist',
      );
    });
  });
}
