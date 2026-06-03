import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/presentation/widgets/app_shell.dart';

/// Minimal cubit used to observe shell-scoped BLoC provision and disposal.
class _ProbeCubit extends Cubit<int> {
  _ProbeCubit() : super(0);
}

void main() {
  group('AppShell', () {
    testWidgets('renders the child inside a Scaffold when no scope is injected', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: AppShell(child: Text('content'))),
      );

      expect(find.text('content'), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('exposes scope-provided BLoCs to its descendants', (
      tester,
    ) async {
      final probe = _ProbeCubit();
      addTearDown(probe.close);
      _ProbeCubit? resolved;

      await tester.pumpWidget(
        MaterialApp(
          home: AppShell(
            scopeBuilder: (context, child) => BlocProvider<_ProbeCubit>.value(
              value: probe,
              child: child,
            ),
            child: Builder(
              builder: (context) {
                resolved = context.read<_ProbeCubit>();
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(resolved, same(probe));
    });

    testWidgets('disposes scope-created BLoCs when it leaves the tree', (
      tester,
    ) async {
      final probe = _ProbeCubit();

      await tester.pumpWidget(
        MaterialApp(
          home: AppShell(
            scopeBuilder: (context, child) => BlocProvider<_ProbeCubit>(
              create: (_) => probe,
              child: child,
            ),
            child: const SizedBox.shrink(),
          ),
        ),
      );

      expect(probe.isClosed, isFalse);

      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));

      expect(probe.isClosed, isTrue);
    });
  });
}
