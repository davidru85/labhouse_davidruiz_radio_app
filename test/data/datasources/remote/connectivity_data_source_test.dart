import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:radio_app/data/datasources/remote/connectivity_data_source.dart';

class _MockConnectivity extends Mock implements Connectivity {}

void main() {
  late _MockConnectivity connectivity;

  setUp(() {
    connectivity = _MockConnectivity();
  });

  group('ConnectivityPlusDataSource', () {
    group('isOnline', () {
      test('returns true when a non-none connection is present', () async {
        when(() => connectivity.checkConnectivity()).thenAnswer(
          (_) async => <ConnectivityResult>[ConnectivityResult.wifi],
        );

        final online = await ConnectivityPlusDataSource(
          connectivity,
        ).isOnline();

        expect(online, isTrue);
      });

      test('returns false when the only result is none', () async {
        when(() => connectivity.checkConnectivity()).thenAnswer(
          (_) async => <ConnectivityResult>[ConnectivityResult.none],
        );

        final online = await ConnectivityPlusDataSource(
          connectivity,
        ).isOnline();

        expect(online, isFalse);
      });

      test('returns false for an empty result list', () async {
        when(
          () => connectivity.checkConnectivity(),
        ).thenAnswer((_) async => <ConnectivityResult>[]);

        final online = await ConnectivityPlusDataSource(
          connectivity,
        ).isOnline();

        expect(online, isFalse);
      });
    });

    group('onlineStatusStream', () {
      test('maps connectivity changes to online booleans', () {
        // ADR-0013 — the wrapper collapses transport changes into a simple
        // online/offline boolean for the repository/BLoC layers.
        when(() => connectivity.onConnectivityChanged).thenAnswer(
          (_) => Stream<List<ConnectivityResult>>.fromIterable(
            <List<ConnectivityResult>>[
              <ConnectivityResult>[ConnectivityResult.none],
              <ConnectivityResult>[ConnectivityResult.wifi],
            ],
          ),
        );

        expect(
          ConnectivityPlusDataSource(connectivity).onlineStatusStream,
          emitsInOrder(<bool>[false, true]),
        );
      });

      test('treats a list containing any non-none result as online', () {
        when(() => connectivity.onConnectivityChanged).thenAnswer(
          (_) => Stream<List<ConnectivityResult>>.value(<ConnectivityResult>[
            ConnectivityResult.none,
            ConnectivityResult.mobile,
          ]),
        );

        expect(
          ConnectivityPlusDataSource(connectivity).onlineStatusStream,
          emits(true),
        );
      });
    });
  });
}
