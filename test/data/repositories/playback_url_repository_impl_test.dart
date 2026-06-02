import 'package:flutter_test/flutter_test.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/core/network/network_exception.dart';
import 'package:radio_app/data/datasources/remote/remote_playback_url_data_source.dart';
import 'package:radio_app/data/repositories/playback_url_repository_impl.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';

void main() {
  group('PlaybackUrlRepositoryImpl', () {
    test('prefers the resolved click URL when the remote yields one', () async {
      final remote = _FakeRemotePlaybackUrlDataSource(
        result: 'https://click.example.com/stream',
      );
      final repository = PlaybackUrlRepositoryImpl(remote);

      final result = await repository.resolvePlaybackUrl(_station());

      expect(result, isA<Success<String, Failure>>());
      expect(
        (result as Success<String, Failure>).value,
        'https://click.example.com/stream',
      );
    });

    test(
      'falls back to resolvedStreamUrl when the remote returns null',
      () async {
        final remote = _FakeRemotePlaybackUrlDataSource();
        final repository = PlaybackUrlRepositoryImpl(remote);

        final result = await repository.resolvePlaybackUrl(
          _station(resolvedStreamUrl: 'https://resolved.example.com/stream'),
        );

        expect(
          (result as Success<String, Failure>).value,
          'https://resolved.example.com/stream',
        );
      },
    );

    test('falls back to streamUrl when the remote returns null and '
        'resolvedStreamUrl is empty', () async {
      final remote = _FakeRemotePlaybackUrlDataSource();
      final repository = PlaybackUrlRepositoryImpl(remote);

      final result = await repository.resolvePlaybackUrl(
        _station(
          resolvedStreamUrl: '',
          streamUrl: 'https://raw.example.com/stream',
        ),
      );

      expect(
        (result as Success<String, Failure>).value,
        'https://raw.example.com/stream',
      );
    });

    test('degrades gracefully to the station URLs when click registration '
        'throws (playback must not fail solely on click failure)', () async {
      final remote = _FakeRemotePlaybackUrlDataSource(
        error: const NetworkException(SocketFailure()),
      );
      final repository = PlaybackUrlRepositoryImpl(remote);

      final result = await repository.resolvePlaybackUrl(
        _station(resolvedStreamUrl: 'https://resolved.example.com/stream'),
      );

      expect(result, isA<Success<String, Failure>>());
      expect(
        (result as Success<String, Failure>).value,
        'https://resolved.example.com/stream',
      );
    });

    test(
      'returns StreamUnreachableFailure when no usable URL exists at all',
      () async {
        final remote = _FakeRemotePlaybackUrlDataSource();
        final repository = PlaybackUrlRepositoryImpl(remote);

        final result = await repository.resolvePlaybackUrl(
          _station(resolvedStreamUrl: '', streamUrl: ''),
        );

        expect(result, isA<FailureResult<String, Failure>>());
        expect(
          (result as FailureResult<String, Failure>).failure,
          isA<StreamUnreachableFailure>(),
        );
      },
    );
  });
}

class _FakeRemotePlaybackUrlDataSource implements RemotePlaybackUrlDataSource {
  _FakeRemotePlaybackUrlDataSource({this.result, this.error});

  final String? result;
  final NetworkException? error;

  @override
  Future<String?> resolvePlaybackUrl(String stationUuid) async {
    final thrown = error;
    if (thrown != null) {
      throw thrown;
    }
    return result;
  }
}

RadioStation _station({
  String resolvedStreamUrl = 'https://example.com/resolved',
  String streamUrl = 'https://example.com/raw',
}) => RadioStation(
  stationUuid: 'station-uuid',
  name: 'Station',
  streamUrl: streamUrl,
  resolvedStreamUrl: resolvedStreamUrl,
  favicon: null,
  homepage: null,
  tags: '',
  tagList: const [],
  country: 'Germany',
  countryCode: 'DE',
  language: null,
  codec: null,
  bitrate: null,
  votes: 0,
  clickCount: 0,
  lastCheckOk: true,
  isHLS: false,
);
