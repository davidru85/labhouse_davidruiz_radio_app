import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/presentation/routing/app_router.dart';

/// Minimal cubit used to observe that the routing shell disposes its scope.
class _ProbeCubit extends Cubit<int> {
  _ProbeCubit() : super(0);
}

void main() {
  group('createAppRouter shell scope lifecycle', () {
    testWidgets('disposes the shell scope when navigating outside the shell', (
      tester,
    ) async {
      late _ProbeCubit probe;
      final router = createAppRouter(
        shellScopeBuilder: (context, child) => BlocProvider<_ProbeCubit>(
          create: (_) => probe = _ProbeCubit(),
          lazy: false,
          child: child,
        ),
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      expect(probe.isClosed, isFalse);

      // `/player` is a top-level route outside the shell, so the shell and its
      // scope must leave the tree and be disposed.
      router.go('/player');
      await tester.pumpAndSettle();

      expect(probe.isClosed, isTrue);
    });
  });
}
