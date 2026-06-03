import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/main.dart';

/// Slice 1 — Portrait-only lock (ADR-0004): Dart reinforcement.
///
/// Manifests remain the source of truth; this pins the optional
/// `SystemChrome.setPreferredOrientations` call made before `runApp`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          calls.add(call);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  test('lockPortraitOrientation requests portraitUp only', () async {
    await lockPortraitOrientation();

    final orientationCall = calls.singleWhere(
      (c) => c.method == 'SystemChrome.setPreferredOrientations',
    );
    expect(orientationCall.arguments, <String>['DeviceOrientation.portraitUp']);
  });
}
