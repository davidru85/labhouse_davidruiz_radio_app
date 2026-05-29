# ADR-0030 — Android cleartext traffic configuration

- **Status:** Accepted
- **Date:** 2026-05-29
- **Deciders:** David Ruiz
- **Related:** `ARCHITECTURE.md` §"Native Platform Configuration", ADR-0002

> This document uses the normative keyword convention defined in
> `CONVENTIONS.md`. Words in **all capitals** (MUST, SHOULD, MAY, etc.)
> carry the meanings defined there.

## Context

A substantial portion of public community-maintained radio streams returned by the Radio Browser API are served over insecure `http://` protocols instead of `https://`. 

Starting with Android 9 (API level 28), the Android operating system blocks all cleartext HTTP traffic by default for security reasons. While iOS has a matching constraint that we configured via `NSAllowsArbitraryLoads` in `Info.plist`, the previous Android configuration did not specify how cleartext traffic is handled. 

Without explicit permission, attempts to stream HTTP audio URLs on Android devices will fail silently.

## Decision

The Android module MUST be configured to allow cleartext HTTP traffic to enable playing insecure radio streams.

Specifically:
- The main `AndroidManifest.xml` file MUST include the attribute `android:usesCleartextTraffic="true"` within the `<application>` tag.
- If a more restrictive network security configuration is introduced in the future, it MUST still permit HTTP audio connections to arbitrary streaming domains.

## Consequences

### Positive
- Ensures that all HTTP-based radio streams can play successfully on Android 9 and newer versions.
- Keeps parity with iOS network security exceptions, providing a consistent multi-platform media experience.

### Negative
- Broadly enables HTTP traffic for the entire application. Since the application does not transmit sensitive user credentials or personal data, this trade-off is acceptable.

## Alternatives considered

### Option A — Filter out HTTP streams in the client
Filter search results in the remote data source to exclude any station where the stream URL starts with `http://`. Rejected because it would exclude a large fraction of active public radio stations from the directory, significantly degrading product coverage.

## Documentation impact

- `ARCHITECTURE.md` §"Native Platform Configuration" (Android) — added `usesCleartextTraffic` to the Android checklist.
