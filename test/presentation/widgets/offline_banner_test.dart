import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/presentation/blocs/connectivity/connectivity_bloc.dart';
import 'package:radio_app/presentation/routing/app_router.dart';

import '../../support/shell_chrome_harness.dart';

void main() {
  group('Global offline banner (sub-task 9.10, per ADR-0013)', () {
    testWidgets('shows "You\'re offline" while the device is offline', (
      tester,
    ) async {
      final harness = buildShellChromeHarness(
        routerFactory: createAppRouter,
        connectivityState: const ConnectivityOffline(),
      );

      await tester.pumpWidget(harness.widget);
      await tester.pumpAndSettle();

      expect(find.text("You're offline"), findsOneWidget);
    });

    testWidgets('shows no banner while steadily online', (tester) async {
      // Default harness connectivity is the steady online state.
      final harness = buildShellChromeHarness(routerFactory: createAppRouter);

      await tester.pumpWidget(harness.widget);
      await tester.pumpAndSettle();

      expect(find.text("You're offline"), findsNothing);
      expect(find.text('Back online'), findsNothing);
    });

    testWidgets('on reconnection shows "Back online" briefly, then hides it', (
      tester,
    ) async {
      final harness = buildShellChromeHarness(
        routerFactory: createAppRouter,
        connectivityState: const ConnectivityOffline(),
        connectivityStream: Stream<ConnectivityState>.fromIterable(const [
          ConnectivityOnline(),
        ]),
      );

      await tester.pumpWidget(harness.widget);
      // Process the offline → online transition.
      await tester.pump();
      await tester.pump();

      // The transient "Back online" confirmation appears...
      expect(find.text('Back online'), findsOneWidget);
      expect(find.text("You're offline"), findsNothing);

      // ...and disappears after the two-second window (per ADR-0013).
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('Back online'), findsNothing);
    });
  });
}
