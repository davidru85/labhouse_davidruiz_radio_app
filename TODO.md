# Future improvements / out-of-scope tracker

This file tracks features, refinements and follow-ups that have been
**deliberately deferred** from v1 of RadioApp. Items here are not bugs
and not pending decisions — they are documented scope choices, each
backed by the ADR that excluded them.

For pending decisions that still need to be made during the current
polish phase, see `MEMORY.md` §Pending Questions instead.

## Conventions

- Each item links to the originating ADR.
- Items are grouped by domain.
- Bringing an item back into scope requires a new ADR that supersedes
  or amends the originating decision.
- Items are removed from this file only when they ship or when a new
  ADR formally drops them from the roadmap.

## Platform reach

- **Web platform support.** Requires an alternative
  `AudioPlayerRepository` implementation because `audio_service` does
  not support web. Browser CORS and autoplay policies would also
  affect a non-trivial share of public radio streams.
  Source: [ADR-0001](docs/adr/0001-target-platforms.md).
- **Desktop platform support** (macOS, Linux, Windows). No production
  quality `audio_service` support; adds maintenance surface without
  current demand.
  Source: [ADR-0001](docs/adr/0001-target-platforms.md).
- **Landscape orientation.** Currently locked to portrait at the
  native manifest level.
  Source: [ADR-0004](docs/adr/0004-screen-orientation.md).
- **Tablet-specific layouts.** App runs portrait-only on tablets as a
  scaled-up phone layout. A proper two-pane tablet layout is deferred.
  Source: [ADR-0004](docs/adr/0004-screen-orientation.md).

## Internationalisation

- **Additional UI languages**, notably Spanish. The `flutter_localizations`
  scaffold and ARB workflow are in place; bringing a language in is
  additive (a translated ARB file plus QA).
  Source: [ADR-0005](docs/adr/0005-i18n-and-country-names.md).
- **Automatic locale detection** at launch based on the system locale,
  with fallback. Currently the app uses `en_US` unconditionally.
  Source: [ADR-0005](docs/adr/0005-i18n-and-country-names.md).

## Accessibility

- **External keyboard navigation.** Out of scope for a mobile-only
  product but trivially additive if the application gains a desktop
  or web target later.
  Source: [ADR-0006](docs/adr/0006-accessibility-baseline.md).
- **Dedicated high-contrast mode.** Flutter has no stable API for
  this at the time of ADR; deferred until either the platform supports
  it or a need emerges.
  Source: [ADR-0006](docs/adr/0006-accessibility-baseline.md).
- **Automatic adaptation to OS accessibility settings beyond text
  scaling.** Bold text, reduce motion, etc. The app respects text
  scaling at launch; behaviour branching on other settings is deferred.
  Source: [ADR-0006](docs/adr/0006-accessibility-baseline.md).

## Build configuration

- **Multiple build flavors** (dev / staging / prod). Currently a single
  flavor. To be introduced if a non-public backend, QA proxy, or
  parallel install of dev vs. prod becomes necessary.
  Source: [ADR-0007](docs/adr/0007-build-flavors.md).

## CI / CD and release engineering

- **Coverage threshold enforcement** on CI. The `test` job produces a
  coverage report but does not gate merges on a minimum percentage.
  A policy will be set in a future ADR alongside testing refinement.
  Source: [ADR-0008](docs/adr/0008-ci-cd-strategy.md).
- **Continuous delivery**: signed release builds, store uploads,
  TestFlight / Play Console automation. Requires paid Apple Developer
  Program and signing infrastructure.
  Source: [ADR-0008](docs/adr/0008-ci-cd-strategy.md).
- **Automated CHANGELOG generation** from Conventional Commits on
  `main`. Deferred until the history has enough volume to justify it.
  Source: [ADR-0009](docs/adr/0009-git-workflow.md).

## Playback features

- **In-app volume control.** Application currently relies on system
  volume only, in line with comparable radio apps.
  Source: [ADR-0010](docs/adr/0010-volume-control-scope.md).
- **Sleep timer.** Stop playback after a user-configured duration.
  Architecturally additive when implemented.
  Source: [ADR-0011](docs/adr/0011-sleep-timer-scope.md).
- **Next and Previous station controls in the player.** Skip to the next or previous station in the active list (e.g. from Favorites or search results) directly from the player interface. Deferred to avoid queue synchronization complexity and high network load on rapid skipping in v1.
  Source: [ADR-0022](docs/adr/0022-background-playback-controls.md).

## Analytics

- **Choose analytics provider.** Candidates include Firebase
  Analytics, Amplitude, Mixpanel, PostHog. The choice will be
  recorded in a future ADR that supersedes the no-op registration.
  Source: [ADR-0019](docs/adr/0019-analytics-interface.md).
- **Implement provider-specific adapter.** Translate
  `AnalyticsEvent` instances into the provider's native event API
  while honouring the contract defined in ADR-0019.
  Source: [ADR-0019](docs/adr/0019-analytics-interface.md).
- **GDPR consent flow and privacy policy.** REQUIRED **before** any
  real analytics adapter is registered in the composition root. The
  no-op adapter is GDPR-safe; any real provider is not. Includes:
  opt-in modal at first launch, persisted choice, revoke flow, and
  a linked privacy policy.
  Source: [ADR-0019](docs/adr/0019-analytics-interface.md).
- **Auto-resume playback on reconnection.** When connectivity is lost
  mid-playback the application surfaces `PlayerErrorState`; user must
  tap play again. Auto-resume needs debounce, cooldown, and a
  distinction between user-initiated stop and connectivity-induced
  stop.
  Source: [ADR-0013](docs/adr/0013-offline-behavior.md).
- **Predictive segment caching.** Not feasible for live radio in
  general; tracked here so the deferral is explicit.
  Source: [ADR-0013](docs/adr/0013-offline-behavior.md).

## Error observability and crash reporting

- **Remote crash reporting integration.** Integrate a production crash reporting service (such as Sentry or Firebase Crashlytics) to monitor unhandled exceptions and diagnostics. Formally deferred to maintain a zero-dependency telemetry profile at launch.
  Source: [ADR-0028](docs/adr/0028-error-observability-crash-reporting.md).

## Project delivery / Licensing

- **Repository licensing.** Decide on the final license (e.g., MIT, Apache 2.0, or proprietary) and add the LICENSE file to the project root before the repository becomes public.
  Source: [README.md](README.md) §License.


