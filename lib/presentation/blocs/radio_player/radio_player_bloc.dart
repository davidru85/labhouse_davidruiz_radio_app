import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/now_playing_info.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/player_state.dart';
import 'package:radio_app/domain/usecases/pause_playback_use_case.dart';
import 'package:radio_app/domain/usecases/play_station_use_case.dart';
import 'package:radio_app/domain/usecases/stop_playback_use_case.dart';
import 'package:radio_app/domain/usecases/use_case.dart';
import 'package:radio_app/domain/usecases/watch_now_playing_use_case.dart';
import 'package:radio_app/domain/usecases/watch_player_state_use_case.dart';

/// Events for [RadioPlayerBloc].
sealed class RadioPlayerEvent extends Equatable {
  /// Creates a radio player event.
  const RadioPlayerEvent();

  @override
  List<Object?> get props => [];
}

/// Requests playback of [station].
final class RadioPlayerPlayRequested extends RadioPlayerEvent {
  /// Creates a play-requested event.
  const RadioPlayerPlayRequested(this.station);

  /// The station to play.
  final RadioStation station;

  @override
  List<Object?> get props => [station];
}

/// Requests pausing the current playback.
final class RadioPlayerPauseRequested extends RadioPlayerEvent {
  /// Creates a pause-requested event.
  const RadioPlayerPauseRequested();
}

/// Requests stopping the current playback.
final class RadioPlayerStopRequested extends RadioPlayerEvent {
  /// Creates a stop-requested event.
  const RadioPlayerStopRequested();
}

final class _PlayerEngineStateChanged extends RadioPlayerEvent {
  const _PlayerEngineStateChanged(this.state);

  final PlayerState state;

  @override
  List<Object?> get props => [state];
}

final class _NowPlayingChanged extends RadioPlayerEvent {
  const _NowPlayingChanged(this.nowPlaying);

  final NowPlayingInfo? nowPlaying;

  @override
  List<Object?> get props => [nowPlaying];
}

/// States for [RadioPlayerBloc].
sealed class RadioPlayerState extends Equatable {
  /// Creates a radio player state.
  const RadioPlayerState();

  @override
  List<Object?> get props => [];
}

/// Idle, nothing playing.
final class RadioPlayerInitial extends RadioPlayerState {
  /// Creates the initial player state.
  const RadioPlayerInitial();
}

/// Loading or rebuffering [station] (per ADR-0015).
final class RadioPlayerBuffering extends RadioPlayerState {
  /// Creates a buffering player state.
  const RadioPlayerBuffering(this.station);

  /// The station being loaded.
  final RadioStation station;

  @override
  List<Object?> get props => [station];
}

/// Actively playing [station] with optional [nowPlaying] metadata.
final class RadioPlayerPlaying extends RadioPlayerState {
  /// Creates a playing player state.
  const RadioPlayerPlaying(this.station, this.nowPlaying);

  /// The station being played.
  final RadioStation station;

  /// Live now-playing metadata, when available (per ADR-0012).
  final NowPlayingInfo? nowPlaying;

  @override
  List<Object?> get props => [station, nowPlaying];
}

/// Playback of [station] is paused.
final class RadioPlayerPaused extends RadioPlayerState {
  /// Creates a paused player state.
  const RadioPlayerPaused(this.station);

  /// The paused station.
  final RadioStation station;

  @override
  List<Object?> get props => [station];
}

/// Playback is stopped.
final class RadioPlayerStopped extends RadioPlayerState {
  /// Creates a stopped player state.
  const RadioPlayerStopped();
}

/// Playback failed; carries the originating [failure].
final class RadioPlayerError extends RadioPlayerState {
  /// Creates an error player state.
  const RadioPlayerError(this.failure, [this.station]);

  /// The failure that interrupted or prevented playback.
  final Failure failure;

  /// The station involved, when known.
  final RadioStation? station;

  @override
  List<Object?> get props => [failure, station];
}

/// Manages audio playback lifecycle, surfacing engine state and now-playing
/// metadata, with a connectivity-loss-during-playback failure path
/// (per ADR-0012/0013/0015/0025).
class RadioPlayerBloc extends Bloc<RadioPlayerEvent, RadioPlayerState> {
  /// Creates the radio player bloc over its use cases and engine watchers.
  RadioPlayerBloc(
    this._playStation,
    this._pausePlayback,
    this._stopPlayback,
    WatchPlayerStateUseCase watchPlayerState,
    WatchNowPlayingUseCase watchNowPlaying,
  ) : super(const RadioPlayerInitial()) {
    on<RadioPlayerPlayRequested>(_onPlayRequested);
    on<RadioPlayerPauseRequested>(_onPauseRequested);
    on<RadioPlayerStopRequested>(_onStopRequested);
    on<_PlayerEngineStateChanged>(_onEngineStateChanged);
    on<_NowPlayingChanged>(_onNowPlayingChanged);

    _playerStateSubscription = watchPlayerState(
      const NoParams(),
    ).listen((state) => add(_PlayerEngineStateChanged(state)));
    _nowPlayingSubscription = watchNowPlaying(
      const NoParams(),
    ).listen((info) => add(_NowPlayingChanged(info)));
  }

  final PlayStationUseCase _playStation;
  final PausePlaybackUseCase _pausePlayback;
  final StopPlaybackUseCase _stopPlayback;

  late final StreamSubscription<PlayerState> _playerStateSubscription;
  late final StreamSubscription<NowPlayingInfo?> _nowPlayingSubscription;

  RadioStation? _currentStation;
  NowPlayingInfo? _nowPlaying;

  Future<void> _onPlayRequested(
    RadioPlayerPlayRequested event,
    Emitter<RadioPlayerState> emit,
  ) async {
    _currentStation = event.station;
    _nowPlaying = null;
    // Optimistically buffer so every request transitions through Buffering
    // before Playing or Error (per ADR-0015 / ADR-0025).
    emit(RadioPlayerBuffering(event.station));
    final result = await _playStation(
      PlayStationParams(station: event.station),
    );
    if (result case FailureResult<void, Failure>(:final failure)) {
      emit(RadioPlayerError(failure, event.station));
    }
  }

  Future<void> _onPauseRequested(
    RadioPlayerPauseRequested event,
    Emitter<RadioPlayerState> emit,
  ) async {
    await _pausePlayback(const NoParams());
  }

  Future<void> _onStopRequested(
    RadioPlayerStopRequested event,
    Emitter<RadioPlayerState> emit,
  ) async {
    await _stopPlayback(const NoParams());
  }

  void _onEngineStateChanged(
    _PlayerEngineStateChanged event,
    Emitter<RadioPlayerState> emit,
  ) {
    final station = _currentStation;
    switch (event.state) {
      case PlayerIdleState():
        emit(const RadioPlayerInitial());
      case PlayerBufferingState():
        if (station != null) emit(RadioPlayerBuffering(station));
      case PlayerPlayingState():
        if (station != null) emit(RadioPlayerPlaying(station, _nowPlaying));
      case PlayerPausedState():
        if (station != null) emit(RadioPlayerPaused(station));
      case PlayerStoppedState():
        emit(const RadioPlayerStopped());
      case PlayerErrorState(:final failure):
        emit(RadioPlayerError(failure, station));
    }
  }

  void _onNowPlayingChanged(
    _NowPlayingChanged event,
    Emitter<RadioPlayerState> emit,
  ) {
    _nowPlaying = event.nowPlaying;
    final station = _currentStation;
    if (state is RadioPlayerPlaying && station != null) {
      emit(RadioPlayerPlaying(station, _nowPlaying));
    }
  }

  @override
  Future<void> close() async {
    await _playerStateSubscription.cancel();
    await _nowPlayingSubscription.cancel();
    return super.close();
  }
}
