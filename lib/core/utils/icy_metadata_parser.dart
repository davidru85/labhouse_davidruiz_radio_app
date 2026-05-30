const _metadataSeparator = ' - ';

/// Parsed Icy `StreamTitle` metadata.
typedef ParsedIcyMetadata = ({String? artist, String? raw, String? track});

/// Parses raw Icy `StreamTitle` metadata.
///
/// Applies the rules in `API_SPEC.md` §6.4 (amended by ADR-0024):
///
/// * `null` or empty input yields null fields.
/// * Input containing one or more ` - ` separators splits on the FIRST
///   separator, mapping the left side to `artist` and the right side to
///   `track`, both trimmed.
/// * Input without a separator is exposed verbatim as `raw` with null
///   `artist` and `track`.
ParsedIcyMetadata parseIcyMetadata(String? raw) {
  if (raw == null || raw.isEmpty) {
    return (raw: null, artist: null, track: null);
  }

  final separatorIndex = raw.indexOf(_metadataSeparator);
  if (separatorIndex == -1) {
    return (raw: raw, artist: null, track: null);
  }

  return (
    raw: raw,
    artist: raw.substring(0, separatorIndex).trim(),
    track: raw.substring(separatorIndex + _metadataSeparator.length).trim(),
  );
}
