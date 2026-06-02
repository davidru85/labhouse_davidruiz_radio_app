import 'dart:async';

import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/core/utils/icy_metadata_parser.dart';
import 'package:radio_app/data/datasources/audio_playback_data_source.dart';
import 'package:radio_app/domain/entities/now_playing_info.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/audio_player_repository.dart';
import 'package:radio_app/domain/repositories/connectivity_repository.dart';
import 'package:radio_app/domain/repositories/player_state.dart';

/// [AudioPlayerRepository] over an [AudioPlaybackDataSource] engine port,
/// surfacing connectivity loss during playback as a [PlaybackFailure]
/// (per ADR-0012/0013/0022).
class AudioPlayerRepositoryImpl implements AudioPlayerRepository {
  /// Creates the repository, wiring engine status and connectivity into a
  /// single player state stream.
  AudioPlayerRepositoryImpl(this._playback, this._connectivity) {
    _statusSubscription = _playback.statusStream.listen(_onStatus);
    _connectivitySubscription = _connectivity.connectivityStream.listen(
      _onConnectivityChanged,
    );
  }

  final AudioPlaybackDataSource _playback;
  final ConnectivityRepository _connectivity;

  final StreamController<PlayerState> _stateController =
      StreamController<PlayerState>.broadcast();
  late final StreamSubscription<PlaybackStatus> _statusSubscription;
  late final StreamSubscription<bool> _connectivitySubscription;
  bool _isPlaying = false;

  @override
  Stream<PlayerState> get playerStateStream => _stateController.stream;

  @override
  Stream<NowPlayingInfo?> get nowPlayingStream =>
      _playback.icyMetadataStream.map(_toNowPlaying);

  @override
  Future<Result<void, Failure>> play(
    String url, {
    required String title,
    required String subtitle,
  }) async {
    try {
      await _playback.setUrl(url, title: title, subtitle: subtitle);
      await _playback.play();
      return const Success<void, Failure>(null);
    } on Object catch (error) {
      return FailureResult<void, Failure>(
        StreamUnreachableFailure(error.toString()),
      );
    }
  }

  @override
  Future<Result<void, Failure>> pause() => _guard(_playback.pause);

  @override
  Future<Result<void, Failure>> stop() => _guard(_playback.stop);

  /// Cancels subscriptions and closes the player state stream.
  Future<void> dispose() async {
    await _statusSubscription.cancel();
    await _connectivitySubscription.cancel();
    await _stateController.close();
  }

  void _onStatus(PlaybackStatus status) {
    _isPlaying = status == PlaybackStatus.playing;
    _stateController.add(_mapStatus(status));
  }

  void _onConnectivityChanged(bool isOnline) {
    // A drop to offline during active playback is surfaced as a playback
    // failure so the player layer needs no connectivity awareness (ADR-0013).
    if (!isOnline && _isPlaying) {
      _stateController.add(const PlayerErrorState(ConnectivityLostFailure()));
    }
  }

  PlayerState _mapStatus(PlaybackStatus status) => switch (status) {
    PlaybackStatus.idle => const PlayerIdleState(),
    PlaybackStatus.buffering => const PlayerBufferingState(),
    PlaybackStatus.playing => const PlayerPlayingState(),
    PlaybackStatus.paused => const PlayerPausedState(),
    PlaybackStatus.stopped => const PlayerStoppedState(),
  };

  NowPlayingInfo? _toNowPlaying(String? raw) {
    final parsed = parseIcyMetadata(raw);
    if (parsed.raw == null) {
      return null;
    }
    return NowPlayingInfo(
      raw: parsed.raw,
      artist: parsed.artist,
      track: parsed.track,
    );
  }

  Future<Result<void, Failure>> _guard(
    Future<void> Function() operation,
  ) async {
    try {
      await operation();
      return const Success<void, Failure>(null);
    } on Object catch (error) {
      return FailureResult<void, Failure>(
        PlaybackInterruptedFailure(error.toString()),
      );
    }
  }
}
