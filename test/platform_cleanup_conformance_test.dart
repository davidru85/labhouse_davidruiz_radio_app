import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Platform Cleanup & Naming Conformance', () {
    test('non-conforming platform folders do not exist', () {
      expect(
        Directory('web').existsSync(),
        isFalse,
        reason: 'web/ folder must be deleted',
      );
      expect(
        Directory('macos').existsSync(),
        isFalse,
        reason: 'macos/ folder must be deleted',
      );
      expect(
        Directory('linux').existsSync(),
        isFalse,
        reason: 'linux/ folder must be deleted',
      );
      expect(
        Directory('windows').existsSync(),
        isFalse,
        reason: 'windows/ folder must be deleted',
      );
    });

    test('package name in pubspec.yaml is radio_app', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(
        pubspec.contains('name: radio_app\n'),
        isTrue,
        reason: 'pubspec.yaml name must be updated to radio_app',
      );
    });

    test(
      'main.dart contains a minimal clean shell and not the counter app',
      () {
        final mainContent = File('lib/main.dart').readAsStringSync();
        expect(
          mainContent.contains('MyHomePage'),
          isFalse,
          reason: 'main.dart should not contain MyHomePage',
        );
        expect(
          mainContent.contains('_counter'),
          isFalse,
          reason: 'main.dart should not contain counter state',
        );
      },
    );

    group('App identifiers (ADR-0003)', () {
      test('Android applicationId and namespace are '
          'com.labhouse.davidruizassessment.radioapp', () {
        final gradle = File('android/app/build.gradle.kts').readAsStringSync();
        expect(
          gradle.contains(
            'applicationId = "com.labhouse.davidruizassessment.radioapp"',
          ),
          isTrue,
          reason:
              'Android applicationId must be '
              'com.labhouse.davidruizassessment.radioapp (ADR-0003)',
        );
        expect(
          gradle.contains(
            'namespace = "com.labhouse.davidruizassessment.radioapp"',
          ),
          isTrue,
          reason:
              'Android namespace must be '
              'com.labhouse.davidruizassessment.radioapp (ADR-0003)',
        );
      });

      test(
        'iOS bundle identifier is com.labhouse.davidruizassessment.radioapp',
        () {
          final pbxproj = File(
            'ios/Runner.xcodeproj/project.pbxproj',
          ).readAsStringSync();
          expect(
            pbxproj.contains(
              'PRODUCT_BUNDLE_IDENTIFIER = '
              'com.labhouse.davidruizassessment.radioapp;',
            ),
            isTrue,
            reason:
                'iOS PRODUCT_BUNDLE_IDENTIFIER must be '
                'com.labhouse.davidruizassessment.radioapp (ADR-0003)',
          );
          expect(
            pbxproj.contains('com.example'),
            isFalse,
            reason:
                'iOS project must not retain any com.example bundle identifier',
          );
        },
      );

      test('display name is RadioApp on Android and iOS', () {
        final manifest = File(
          'android/app/src/main/AndroidManifest.xml',
        ).readAsStringSync();
        expect(
          manifest.contains('android:label="RadioApp"'),
          isTrue,
          reason: 'Android android:label must be RadioApp (ADR-0003)',
        );
        final infoPlist = File('ios/Runner/Info.plist').readAsStringSync();
        expect(
          infoPlist.contains(
            '<key>CFBundleDisplayName</key>\n\t<string>RadioApp</string>',
          ),
          isTrue,
          reason: 'iOS CFBundleDisplayName must be RadioApp (ADR-0003)',
        );
      });

      test('the conforming MainActivity exists under the new package path', () {
        const newPath =
            'android/app/src/main/kotlin/com/labhouse/davidruizassessment/radioapp/MainActivity.kt';
        expect(
          File(newPath).existsSync(),
          isTrue,
          reason: 'MainActivity must live under the new package path',
        );
        expect(
          File(newPath).readAsStringSync().contains(
            'package com.labhouse.davidruizassessment.radioapp',
          ),
          isTrue,
          reason: 'MainActivity package must match the new applicationId',
        );
        expect(
          Directory('android/app/src/main/kotlin/com/example').existsSync(),
          isFalse,
          reason: 'The legacy com/example MainActivity path must be removed',
        );
      });
    });

    group('Minimum OS versions (ADR-0002)', () {
      test('Android SDK levels are minSdk=23, targetSdk=34, compileSdk=34', () {
        final gradle = File('android/app/build.gradle.kts').readAsStringSync();
        expect(
          gradle.contains('minSdk = 23'),
          isTrue,
          reason: 'Android minSdkVersion must be 23 (ADR-0002)',
        );
        expect(
          gradle.contains('targetSdk = 34'),
          isTrue,
          reason: 'Android targetSdkVersion must be 34 (ADR-0002)',
        );
        expect(
          gradle.contains('compileSdk = 34'),
          isTrue,
          reason: 'Android compileSdkVersion must be 34 (ADR-0002)',
        );
      });

      test('iOS deployment target is 13.0', () {
        final pbxproj = File(
          'ios/Runner.xcodeproj/project.pbxproj',
        ).readAsStringSync();
        expect(
          pbxproj.contains('IPHONEOS_DEPLOYMENT_TARGET = 13.0;'),
          isTrue,
          reason: 'iOS deployment target must be 13.0 (ADR-0002)',
        );
      });
    });
  });
}
