import 'package:radio_app/domain/entities/now_playing_info.dart';
import 'package:radio_app/domain/entities/radio_station.dart';

/// Resolves the single-line mini-player label for the currently playing
/// content.
///
/// Per ADR-0012 §"UI projection", the mini-player shows the track and artist
/// only when BOTH are present (`artist - track`) and falls back to the station
/// name otherwise — raw/unparseable `StreamTitle` text is never surfaced.
String nowPlayingLabel(RadioStation station, NowPlayingInfo? nowPlaying) {
  final artist = nowPlaying?.artist;
  final track = nowPlaying?.track;
  if (artist != null &&
      artist.isNotEmpty &&
      track != null &&
      track.isNotEmpty) {
    return '$artist - $track';
  }
  return station.name;
}
