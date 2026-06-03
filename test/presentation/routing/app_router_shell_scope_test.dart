import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/presentation/routing/app_router.dart';
import 'package:radio_app/presentation/screens/favorites_screen.dart';
import 'package:radio_app/presentation/screens/stations_screen.dart';
import '../../support/router_test_harness.dart';

/// Minimal cubit used to observe that the shell scope is owned by the routing
/// shell and shared across its tabs.
class _ProbeCubit extends Cubit<int> {
  _ProbeCubit() : super(0);
}

void main() {
  group('createAppRouter shell scope', () {
    testWidgets('keeps the same shell-scoped bloc instance across shell tabs', (
      tester,
    ) async {
      final probe = _ProbeCubit();
      addTearDown(probe.close);

      final router = createAppRouter(
        shellScopeBuilder: (context, child) =>
            BlocProvider<_ProbeCubit>.value(value: probe, child: child),
      );

      await tester.pumpWidget(buildRouterHarness(router));
      await tester.pumpAndSettle();

      final onStations = tester
          .element(find.byType(StationsScreen))
          .read<_ProbeCubit>();

      router.go('/favorites');
      await tester.pumpAndSettle();

      final onFavorites = tester
          .element(find.byType(FavoritesScreen))
          .read<_ProbeCubit>();

      expect(onFavorites, same(onStations));
      expect(onFavorites, same(probe));
    });
  });
}
