import 'package:equatable/equatable.dart';

/// Immutable now-playing metadata parsed from Icy stream titles.
final class NowPlayingInfo extends Equatable {
  /// Creates now-playing metadata.
  const NowPlayingInfo({this.raw, this.artist, this.track});

  /// Raw `StreamTitle` value verbatim, when present.
  final String? raw;

  /// Parsed artist, when metadata follows the expected separator format.
  final String? artist;

  /// Parsed track, when metadata follows the expected separator format.
  final String? track;

  @override
  List<Object?> get props => [raw, artist, track];
}
