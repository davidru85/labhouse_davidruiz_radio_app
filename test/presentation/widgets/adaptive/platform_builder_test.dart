import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/presentation/widgets/adaptive/platform_builder.dart';

void main() {
  group('PlatformBuilder', () {
    Widget harness(TargetPlatform platform) {
      return MaterialApp(
        theme: ThemeData(platform: platform),
        home: PlatformBuilder(
          material: (context) => const Text('material'),
          cupertino: (context) => const Text('cupertino'),
        ),
      );
    }

    testWidgets('renders the material builder on Android', (tester) async {
      await tester.pumpWidget(harness(TargetPlatform.android));

      expect(find.text('material'), findsOneWidget);
      expect(find.text('cupertino'), findsNothing);
    });

    testWidgets('renders the cupertino builder on iOS', (tester) async {
      await tester.pumpWidget(harness(TargetPlatform.iOS));

      expect(find.text('cupertino'), findsOneWidget);
      expect(find.text('material'), findsNothing);
    });

    testWidgets('renders the cupertino builder on macOS', (tester) async {
      await tester.pumpWidget(harness(TargetPlatform.macOS));

      expect(find.text('cupertino'), findsOneWidget);
    });

    testWidgets('renders the material builder on other platforms', (
      tester,
    ) async {
      await tester.pumpWidget(harness(TargetPlatform.linux));

      expect(find.text('material'), findsOneWidget);
    });

    testWidgets('isCupertino reflects the resolved platform', (tester) async {
      late bool iosResult;
      late bool androidResult;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Builder(
            builder: (context) {
              iosResult = PlatformBuilder.isCupertino(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: Builder(
            builder: (context) {
              androidResult = PlatformBuilder.isCupertino(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(iosResult, isTrue);
      expect(androidResult, isFalse);
    });
  });
}
