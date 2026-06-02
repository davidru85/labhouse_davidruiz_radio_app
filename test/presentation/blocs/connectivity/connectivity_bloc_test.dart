import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/connectivity_repository.dart';
import 'package:radio_app/domain/usecases/watch_connectivity_use_case.dart';
import 'package:radio_app/presentation/blocs/connectivity/connectivity_bloc.dart';

// `WatchConnectivityUseCase` is `final` (unmockable outside its library): use a
// fake repository with a controllable stream and build the real use case,
// keeping the BLoC use-case-only (ARCHITECTURE.md §"Dependency Rule").
class _FakeConnectivityRepository implements ConnectivityRepository {
  _FakeConnectivityRepository(this._controller);

  final StreamController<bool> _controller;

  @override
  Stream<bool> get connectivityStream => _controller.stream;

  @override
  Future<Result<bool, Failure>> checkConnectivity() async {
    return const Success<bool, Failure>(true);
  }
}

void main() {
  late StreamController<bool> controller;

  setUp(() {
    controller = StreamController<bool>.broadcast();
  });

  tearDown(() {
    controller.close();
  });

  ConnectivityBloc build() => ConnectivityBloc(
    WatchConnectivityUseCase(_FakeConnectivityRepository(controller)),
  );

  Future<void> tick() => Future<void>.delayed(Duration.zero);

  group('ConnectivityBloc', () {
    blocTest<ConnectivityBloc, ConnectivityState>(
      'emits Online when the first connectivity value reports online '
      '(per ADR-0013)',
      build: build,
      act: (bloc) async {
        controller.add(true);
        await tick();
      },
      expect: () => const [ConnectivityOnline()],
    );

    blocTest<ConnectivityBloc, ConnectivityState>(
      'emits Offline then Online on a connection loss and recovery '
      '(per ADR-0013)',
      build: build,
      act: (bloc) async {
        controller.add(false);
        await tick();
        controller.add(true);
        await tick();
      },
      expect: () => const [ConnectivityOffline(), ConnectivityOnline()],
    );

    blocTest<ConnectivityBloc, ConnectivityState>(
      'emits Online then Offline when connectivity is lost (per ADR-0013)',
      build: build,
      act: (bloc) async {
        controller.add(true);
        await tick();
        controller.add(false);
        await tick();
      },
      expect: () => const [ConnectivityOnline(), ConnectivityOffline()],
    );
  });
}
