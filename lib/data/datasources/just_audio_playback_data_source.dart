import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:radio_app/data/datasources/audio_playback_data_source.dart';

/// Concrete [AudioPlaybackDataSource] wrapping `just_audio` and `audio_service`
/// (per ADR-0012/0022).
class JustAudioPlaybackDataSource implements AudioPlaybackDataSource {
  /// Creates the data source and begins listening to player streams to sync
  /// background media service states.
  JustAudioPlaybackDataSource(this._player, this._handler) {
    _statusSubscription = _player.playbackEventStream.listen(_onPlaybackEvent);
    _processingStateSubscription = _player.processingStateStream.listen(
      (_) => _onPlaybackEvent(_player.playbackEvent),
    );
    _playingSubscription = _player.playingStream.listen(
      (_) => _onPlaybackEvent(_player.playbackEvent),
    );
    _metadataSubscription = _player.icyMetadataStream.listen(_onIcyMetadata);
  }

  final AudioPlayer _player;
  final BaseAudioHandler _handler;

  late final StreamSubscription<PlaybackEvent> _statusSubscription;
  late final StreamSubscription<ProcessingState> _processingStateSubscription;
  late final StreamSubscription<bool> _playingSubscription;
  late final StreamSubscription<IcyMetadata?> _metadataSubscription;

  String? _currentTitle;
  String? _currentSubtitle;

  @override
  Stream<PlaybackStatus> get statusStream =>
      _player.playerStateStream.map((state) {
        if (!state.playing) {
          return switch (state.processingState) {
            ProcessingState.idle => PlaybackStatus.idle,
            ProcessingState.loading => PlaybackStatus.buffering,
            ProcessingState.buffering => PlaybackStatus.buffering,
            ProcessingState.ready => PlaybackStatus.paused,
            ProcessingState.completed => PlaybackStatus.stopped,
          };
        }
        return switch (state.processingState) {
          ProcessingState.idle => PlaybackStatus.idle,
          ProcessingState.loading => PlaybackStatus.buffering,
          ProcessingState.buffering => PlaybackStatus.buffering,
          ProcessingState.ready => PlaybackStatus.playing,
          ProcessingState.completed => PlaybackStatus.stopped,
        };
      });

  @override
  Stream<String?> get icyMetadataStream =>
      _player.icyMetadataStream.map((metadata) => metadata?.info?.title);

  @override
  Future<void> setUrl(
    String url, {
    required String title,
    required String subtitle,
  }) async {
    _currentTitle = title;
    _currentSubtitle = subtitle;

    await _player.setAudioSource(AudioSource.uri(Uri.parse(url), tag: url));
    _updateMetadata(title: title, subtitle: subtitle);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  /// Disposes internal resources and stream subscriptions.
  Future<void> dispose() async {
    await _statusSubscription.cancel();
    await _processingStateSubscription.cancel();
    await _playingSubscription.cancel();
    await _metadataSubscription.cancel();
  }

  void _onPlaybackEvent(PlaybackEvent event) {
    final playing = _player.playing;
    final processingState = _player.processingState;

    final controls = [
      if (playing) MediaControl.pause else MediaControl.play,
      MediaControl.stop,
    ];

    _handler.playbackState.add(
      PlaybackState(
        controls: controls,
        androidCompactActionIndices: List.generate(controls.length, (i) => i),
        processingState: switch (processingState) {
          ProcessingState.idle => AudioProcessingState.idle,
          ProcessingState.loading => AudioProcessingState.loading,
          ProcessingState.buffering => AudioProcessingState.buffering,
          ProcessingState.ready => AudioProcessingState.ready,
          ProcessingState.completed => AudioProcessingState.completed,
        },
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
      ),
    );
  }

  void _onIcyMetadata(IcyMetadata? metadata) {
    final title = metadata?.info?.title;
    if (title != null && title.isNotEmpty) {
      _updateMetadata(title: _currentTitle ?? 'Live Radio', subtitle: title);
    } else {
      _updateMetadata(
        title: _currentTitle ?? 'Live Radio',
        subtitle: _currentSubtitle ?? '',
      );
    }
  }

  void _updateMetadata({required String title, required String subtitle}) {
    final sequence = _player.audioSource?.sequence;
    final tag = (sequence != null && sequence.isNotEmpty)
        ? sequence.first.tag
        : null;
    final mediaId = tag is String ? tag : 'live_stream';
    _handler.mediaItem.add(
      MediaItem(
        id: mediaId,
        album: 'Live Radio',
        title: title,
        artist: subtitle,
      ),
    );
  }
}

/// Concrete [AudioHandler] that routes media commands directly to
/// a `just_audio` player (per ADR-0022).
class RadioAudioHandler extends BaseAudioHandler {
  /// Creates the handler over [_player].
  RadioAudioHandler(this._player);

  final AudioPlayer _player;

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();
}
