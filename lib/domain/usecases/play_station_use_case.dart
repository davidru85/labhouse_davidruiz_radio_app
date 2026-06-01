import 'package:equatable/equatable.dart';
import 'package:radio_app/core/errors/result.dart';
import 'package:radio_app/domain/entities/radio_station.dart';
import 'package:radio_app/domain/failures/failure.dart';
import 'package:radio_app/domain/repositories/audio_player_repository.dart';
import 'package:radio_app/domain/repositories/playback_url_repository.dart';
import 'package:radio_app/domain/usecases/use_case.dart';

/// Resolves a station's stream URL and starts background playback.
final class PlayStationUseCase implements UseCase<void, PlayStationParams> {
  /// Creates a station playback use case.
  const PlayStationUseCase(this._urlRepository, this._audioPlayer);

  final PlaybackUrlRepository _urlRepository;
  final AudioPlayerRepository _audioPlayer;

  /// Resolves the playable URL for the [params] station and, on success,
  /// starts playback with background notification metadata (per ADR-0022).
  @override
  Future<Result<void, Failure>> call(PlayStationParams params) async {
    final station = params.station;
    final resolved = await _urlRepository.resolvePlaybackUrl(station);

    switch (resolved) {
      case FailureResult<String, Failure>(:final failure):
        return FailureResult<void, Failure>(failure);
      case Success<String, Failure>(:final value):
        return _audioPlayer.play(
          value,
          title: station.name,
          subtitle: _subtitleFor(station),
        );
    }
  }

  /// Builds the initial notification subtitle shown before live
  /// `NowPlayingInfo` arrives: "primary tag • country", or the country
  /// alone when the station has no tags (per ADR-0022).
  String _subtitleFor(RadioStation station) {
    if (station.tagList.isEmpty) {
      return station.country;
    }

    return '${station.tagList.first} • ${station.country}';
  }
}

/// Parameters for [PlayStationUseCase].
final class PlayStationParams extends Equatable {
  /// Creates station playback parameters.
  const PlayStationParams({required this.station});

  /// Station to resolve and play.
  final RadioStation station;

  @override
  List<Object> get props => [station];
}
