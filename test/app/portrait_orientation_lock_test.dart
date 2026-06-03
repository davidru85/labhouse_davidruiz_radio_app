import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Slice 1 — Portrait-only lock (ADR-0004): native source-of-truth.
///
/// The manifest/Info.plist declarations are the source of truth for the
/// orientation lock; these tests pin them so it cannot silently regress.
/// The Dart `SystemChrome` reinforcement is covered separately in
/// `portrait_orientation_reinforcement_test.dart`.
void main() {
  group('Android manifest (ADR-0004)', () {
    test('the launcher activity is locked to portrait', () {
      final manifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();
      expect(
        manifest.contains('android:screenOrientation="portrait"'),
        isTrue,
        reason:
            'The main <activity> must declare '
            'android:screenOrientation="portrait" (ADR-0004)',
      );
    });
  });

  group('iOS Info.plist (ADR-0004)', () {
    late String infoPlist;

    setUp(() {
      infoPlist = File('ios/Runner/Info.plist').readAsStringSync();
    });

    test('phone orientations are portrait-only', () {
      final phoneBlock = _supportedOrientations(
        infoPlist,
        'UISupportedInterfaceOrientations',
      );
      expect(
        phoneBlock,
        <String>['UIInterfaceOrientationPortrait'],
        reason: 'iPhone must support portrait only (ADR-0004)',
      );
    });

    test('iPad orientations are portrait-only', () {
      final ipadBlock = _supportedOrientations(
        infoPlist,
        'UISupportedInterfaceOrientations~ipad',
      );
      expect(
        ipadBlock,
        <String>['UIInterfaceOrientationPortrait'],
        reason: 'iPad must support portrait only (ADR-0004)',
      );
    });
  });
}

/// Returns the `<string>` values declared under the `<key>[key]</key>` array in
/// an Info.plist body, in document order.
List<String> _supportedOrientations(String plist, String key) {
  final keyIndex = plist.indexOf('<key>$key</key>');
  if (keyIndex == -1) return const [];
  final arrayStart = plist.indexOf('<array>', keyIndex);
  final arrayEnd = plist.indexOf('</array>', arrayStart);
  final body = plist.substring(arrayStart, arrayEnd);
  return RegExp('<string>(.*?)</string>')
      .allMatches(body)
      .map((m) => m.group(1)!)
      .toList();
}
