import 'package:radio_app/domain/entities/now_playing_info.dart';

const _metadataSeparator = ' - ';

/// Parses raw Icy `StreamTitle` metadata into a [NowPlayingInfo].
///
/// Applies the rules in `API_SPEC.md` §6.4 (amended by ADR-0024):
///
/// * `null` or empty input yields an empty [NowPlayingInfo].
/// * Input containing one or more ` - ` separators splits on the FIRST
///   separator, mapping the left side to `artist` and the right side to
///   `track`, both trimmed.
/// * Input without a separator is exposed verbatim as `raw` with null
///   `artist` and `track`.
NowPlayingInfo parseIcyMetadata(String? raw) {
  if (raw == null || raw.isEmpty) {
    return const NowPlayingInfo();
  }

  final separatorIndex = raw.indexOf(_metadataSeparator);
  if (separatorIndex == -1) {
    return NowPlayingInfo(raw: raw);
  }

  return NowPlayingInfo(
    raw: raw,
    artist: raw.substring(0, separatorIndex).trim(),
    track: raw.substring(separatorIndex + _metadataSeparator.length).trim(),
  );
}
