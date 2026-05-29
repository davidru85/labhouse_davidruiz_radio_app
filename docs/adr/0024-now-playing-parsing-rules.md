# ADR-0024 — Now-playing metadata parsing rules

- **Status:** Accepted
- **Date:** 2026-05-29
- **Deciders:** David Ruiz
- **Related:** `API_SPEC.md` §6.4, `TESTING_STRATEGY.md` §Unit Testing, `VALIDATION_CHECKLIST.md` §Domain And Data Modeling, ADR-0012

> This document uses the normative keyword convention defined in
> `CONVENTIONS.md`. Words in **all capitals** (MUST, SHOULD, MAY, etc.)
> carry the meanings defined there.

## Context

Shoutcast and Icecast radio streams embed inline Icy metadata, exposing the currently playing track via `StreamTitle`. `API_SPEC.md` §6.4 and ADR-0012 define the `NowPlayingInfo` entity, mapping the `StreamTitle` into `artist` and `track` fields. 

However, the previous rule only defined the split logic when the raw string contained *exactly one* ` - ` (space-hyphen-space) separator. In real-world radio streams, metadata titles often contain multiple separators (e.g. `Artist - Song Title - Live Version` or `Artist - Song Title - Show Name`). Without an explicit mathematical split policy, the parser implementation could fail or act unpredictably, returning null for both fields on valid metadata.

We need a clear split policy that isolates the artist correctly on rich metadata strings.

## Decision

The application's Icy metadata parser MUST split the raw `StreamTitle` string on the **first** ` - ` (space-hyphen-space) separator encountered from left to right.

Specifically:
1. If the raw string contains one or more ` - ` separators:
   - The substring to the left of the **first** separator MUST map to `artist` (trimmed of leading/trailing whitespace).
   - The substring to the right of the **first** separator (which may contain additional hyphens) MUST map to `track` (trimmed of leading/trailing whitespace).
2. If the raw string contains no ` - ` separator, `artist` and `track` MUST be null, and `raw` MUST hold the verbatim string.
3. If the raw string is null or empty, all fields MUST be null.

## Consequences

### Positive
- Ensures that complex metadata (e.g., live recordings, radio shows, or featured artists separated by hyphens) is parsed correctly, extracting the primary artist.
- Provides an explicit, deterministic rule that can be verified via unit tests during Phase 1 RED testing.
- Avoids silent failure (returning nulls) for popular stations that append metadata details at the end of their stream titles.

### Negative
- If a station places secondary information before the artist (e.g., `Live Aid - Queen - Bohemian Rhapsody`), the split will misattribute the artist (e.g., `artist: "Live Aid"`, `track: "Queen - Bohemian Rhapsody"`). However, this layout is extremely rare in commercial radio, making this an acceptable trade-off.

### Neutral
- String parsing remains stateless and side-effect free, belonging in `lib/core/utils/icy_metadata_parser.dart` (per ADR-0017).

## Alternatives considered

### Option B — Split on the last separator
Rejected because secondary information (remix names, live dates, etc.) is conventionally appended to the end of the song title, meaning the first hyphen is the one separating the artist from the track.

### Option C — Reject parsing if multiple separators are present
Leave `artist` and `track` null if there is more than one hyphen. Rejected because it drops useful artist details for a significant portion of active stations.

## Documentation impact

- `API_SPEC.md` §6.4 — updated parsing rules for `NowPlayingInfo`.
- `TESTING_STRATEGY.md` §Unit Testing — updated test cases for `icy_metadata_parser`.
- `VALIDATION_CHECKLIST.md` §Domain And Data Modeling — updated verification rules.
