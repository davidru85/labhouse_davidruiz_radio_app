import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/domain/failures/failure.dart';

void main() {
  group('Failure hierarchy', () {
    test('defines every concrete failure from the architecture contract', () {
      final failures = _failureCatalogue();

      expect(failures, hasLength(12));
      expect(failures, everyElement(isA<Failure>()));
    });

    test('groups concrete failures under their sealed category types', () {
      expect(const ServerFailure(), isA<ApiFailure>());
      expect(const ValidationErrorFailure(), isA<ApiFailure>());
      expect(const UnauthorizedFailure(), isA<ApiFailure>());

      expect(const ConnectionTimeoutFailure(), isA<NetworkFailure>());
      expect(const SocketFailure(), isA<NetworkFailure>());
      expect(const MirrorFailure(), isA<NetworkFailure>());

      expect(const StreamUnreachableFailure(), isA<PlaybackFailure>());
      expect(const CodecUnsupportedFailure(), isA<PlaybackFailure>());
      expect(const PlaybackInterruptedFailure(), isA<PlaybackFailure>());
      expect(const ConnectivityLostFailure(), isA<PlaybackFailure>());

      expect(const StorageReadWriteFailure(), isA<StorageFailure>());
      expect(const FavoritesSyncFailure(), isA<StorageFailure>());
    });

    test('exposes stable localization keys', () {
      final expectedKeys = <Failure, String>{
        const ServerFailure(): 'error_server',
        const ValidationErrorFailure(): 'error_validation',
        const UnauthorizedFailure(): 'error_unauthorized',
        const ConnectionTimeoutFailure(): 'error_network_timeout',
        const SocketFailure(): 'error_network_socket',
        const MirrorFailure(): 'error_network_mirror',
        const StreamUnreachableFailure(): 'error_playback_unreachable',
        const CodecUnsupportedFailure(): 'error_playback_codec',
        const PlaybackInterruptedFailure(): 'error_playback_interrupted',
        const ConnectivityLostFailure(): 'error_playback_connectivity',
        const StorageReadWriteFailure(): 'error_storage_io',
        const FavoritesSyncFailure(): 'error_favorites_sync',
      };

      for (final entry in expectedKeys.entries) {
        expect(entry.key.localizationKey, entry.value);
      }
    });

    test('supports nullable messages and value equality', () {
      expect(const ServerFailure().message, isNull);
      expect(
        const ServerFailure('server down'),
        equals(const ServerFailure('server down')),
      );
      expect(
        const ServerFailure('server down'),
        isNot(equals(const ServerFailure('different message'))),
      );
      expect(
        const SocketFailure('network issue'),
        equals(const SocketFailure('network issue')),
      );
      expect(
        const ConnectivityLostFailure('offline'),
        equals(const ConnectivityLostFailure('offline')),
      );
      expect(
        const StorageReadWriteFailure('box failed'),
        equals(const StorageReadWriteFailure('box failed')),
      );
    });
  });
}

List<Failure> _failureCatalogue() {
  return const [
    ServerFailure('server down'),
    ValidationErrorFailure('invalid query'),
    UnauthorizedFailure('unauthorized'),
    ConnectionTimeoutFailure('timed out'),
    SocketFailure('dns failed'),
    MirrorFailure('mirrors exhausted'),
    StreamUnreachableFailure('stream unreachable'),
    CodecUnsupportedFailure('codec unsupported'),
    PlaybackInterruptedFailure('playback interrupted'),
    ConnectivityLostFailure('connectivity lost'),
    StorageReadWriteFailure('storage failed'),
    FavoritesSyncFailure('favorites sync failed'),
  ];
}
