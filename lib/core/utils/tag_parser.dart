/// Parses a comma-separated [tags] string into a normalized tag list.
///
/// Trims each tag, drops empty segments, and removes duplicates while
/// preserving first-seen order. Returns an empty list for null, empty, or
/// whitespace-only input. Domain-free (per ADR-0017, ADR-0034).
List<String> parseTags(String? tags) {
  if (tags == null) {
    return const <String>[];
  }

  final parsed = <String>[];
  final seen = <String>{};
  for (final segment in tags.split(',')) {
    final tag = segment.trim();
    if (tag.isEmpty) {
      continue;
    }
    if (seen.add(tag)) {
      parsed.add(tag);
    }
  }
  return parsed;
}
