# Glossary

Domain-specific terms used across the RadioApp documentation. The
list is intentionally short: standard Clean Architecture and Flutter
vocabulary (DTO, use case, repository, BLoC, ARB, etc.) is assumed
to be known and is not redefined here.

For documentation conventions (RFC 2119 keywords), see
[`CONVENTIONS.md`](CONVENTIONS.md).

---

## Click registration

A request to the Radio Browser endpoint
`GET /json/url/{stationuuid}` that registers the user's intent to
play a station and returns a — potentially improved — resolved
stream URL. Click registration MAY fail without aborting playback;
when it does, the resolved URL is unavailable and the player falls
back to the next URL in the fallback chain. See
[`API_SPEC.md` §5.3](API_SPEC.md).

## Fallback chain

The ordered list of stream URLs the player tries when starting
playback for a station:

1. resolved click URL (from `/json/url/{stationuuid}`),
2. `url_resolved` from the station data,
3. `url` from the station data.

The first URL that yields a playable stream wins. See
[`API_SPEC.md` §5.3](API_SPEC.md).

## HLS

**HTTP Live Streaming.** A streaming protocol (originally from
Apple) that segments audio into short chunks served over HTTP. A
station is HLS when its `hls` field equals `1` in the Radio Browser
payload; this maps to `RadioStation.isHLS == true`.

## Icy metadata

Inline metadata embedded in a Shoutcast / Icecast HTTP audio stream.
Every `icy-metaint` bytes the server injects a short text block of
the form `StreamTitle='Artist - Track';StreamUrl='...';` describing
the currently playing track. The application surfaces parsed Icy
data through `NowPlayingInfo`. See
[`API_SPEC.md` §6.4](API_SPEC.md) and
[ADR-0012](docs/adr/0012-now-playing-metadata.md).

## lastcheckok

A field returned by Radio Browser indicating whether the most recent
automated check found the stream playable. The value `1` maps to
`RadioStation.lastCheckOk == true`. `lastcheckok == 1` does **not**
guarantee successful playback at the current moment; streams can
break between checks.

## Mirror

A Radio Browser API server. The infrastructure is replicated across
several geographically distributed mirrors
(`de1.api.radio-browser.info`, `nl1.api.radio-browser.info`,
`at1.api.radio-browser.info`, etc.). There is no single canonical
host; the application MUST treat mirrors as interchangeable. See
[`API_SPEC.md` §2](API_SPEC.md).

## Mirror failover

The networking-layer behaviour that retries a failed request on the
next available mirror after a connection-level error or a 5xx
response. Retries are capped at 2 attempts per mirror and 6 total
requests. The last-known-working mirror is persisted in the Hive
box `app_settings` and used first on the next startup. See
[`API_SPEC.md` §2](API_SPEC.md) and
[ADR-0016](docs/adr/0016-mirror-cache-persistence.md).

## stationuuid

The stable, opaque, version-4 UUID assigned by Radio Browser to each
station. It is the only identifier used throughout the application.
Legacy numeric IDs from the Radio Browser data MUST NOT be used.

## StreamTitle

A field inside an Icy metadata block carrying free-text information
about the currently playing track, conventionally formatted as
`Artist - Track`. Parsing rules tolerate malformed values; see
[`API_SPEC.md` §6.4](API_SPEC.md).
