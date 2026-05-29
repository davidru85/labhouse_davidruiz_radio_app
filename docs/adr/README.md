# Architecture Decision Records

This directory contains immutable records of architectural and product
decisions made for RadioApp.

## Conventions

- ADRs are numbered sequentially starting at 0001.
- ADRs are immutable once Status is `Accepted`. To change a decision,
  create a new ADR with `Status: Accepted` and update the old ADR's
  status to `Superseded by ADR-NNNN`.
- The template lives at [`0000-template.md`](0000-template.md).
- ADR files are written in English, regardless of the language used during
  the decision-making conversation.

## Index

| #    | Title                                                       | Status   | Date       |
|------|-------------------------------------------------------------|----------|------------|
| 0001 | [Target platforms](0001-target-platforms.md)                | Accepted | 2026-05-28 |
| 0002 | [Minimum OS versions](0002-minimum-os-versions.md)          | Accepted | 2026-05-28 |
| 0003 | [App identifiers](0003-app-identifiers.md)                  | Accepted | 2026-05-28 |
| 0004 | [Screen orientation](0004-screen-orientation.md)            | Accepted | 2026-05-28 |
| 0005 | [i18n and country names](0005-i18n-and-country-names.md)    | Accepted | 2026-05-28 |
| 0006 | [Accessibility baseline](0006-accessibility-baseline.md)    | Accepted | 2026-05-28 |
| 0007 | [Build flavors](0007-build-flavors.md)                      | Accepted | 2026-05-28 |
| 0008 | [CI/CD strategy and branch protection](0008-ci-cd-strategy.md) | Accepted | 2026-05-28 |
| 0009 | [Git workflow and commit conventions](0009-git-workflow.md) | Accepted | 2026-05-28 |
| 0010 | [Volume control scope](0010-volume-control-scope.md)        | Accepted | 2026-05-28 |
| 0011 | [Sleep timer scope](0011-sleep-timer-scope.md)              | Accepted | 2026-05-28 |
| 0012 | [Now-playing metadata (Icy stream)](0012-now-playing-metadata.md) | Accepted | 2026-05-28 |
| 0013 | [Offline behaviour](0013-offline-behavior.md)               | Accepted | 2026-05-28 |
| 0014 | [Search debounce and request cancellation](0014-search-debounce.md) | Accepted | 2026-05-28 |
| 0015 | [Player buffering state](0015-player-buffering-state.md)    | Accepted | 2026-05-28 |
| 0016 | [Mirror cache persistence backend](0016-mirror-cache-persistence.md) | Accepted | 2026-05-28 |
| 0017 | [`core/utils/` folder in the mandatory structure](0017-core-utils-folder.md) | Accepted | 2026-05-28 |
| 0018 | [Official dependency list (consolidated)](0018-official-dependency-list.md) | Accepted | 2026-05-28 |
| 0019 | [Analytics interface (provider-agnostic)](0019-analytics-interface.md) | Accepted | 2026-05-28 |
| 0020 | [Favorites synchronization resilience](0020-favorites-sync-resilience.md) | Accepted | 2026-05-29 |
| 0021 | [Recently played history limit](0021-recently-played-history-limit.md) | Accepted | 2026-05-29 |
| 0022 | [Background playback notification controls](0022-background-playback-controls.md) | Accepted | 2026-05-29 |
| 0023 | [API mirrors static list](0023-api-mirrors-list.md) | Accepted | 2026-05-29 |
| 0024 | [Now-playing metadata parsing rules](0024-now-playing-parsing-rules.md) | Accepted | 2026-05-29 |
| 0025 | [Offline playback state transitions](0025-offline-playback-state-transitions.md) | Accepted | 2026-05-29 |
| 0026 | [Recently played history triggers](0026-recently-played-history-triggers.md) | Accepted | 2026-05-29 |
| 0027 | [Popular stations strategy](0027-popular-stations-strategy.md) | Accepted | 2026-05-29 |
| 0028 | [Error observability and crash reporting](0028-error-observability-crash-reporting.md) | Accepted | 2026-05-29 |
| 0029 | [Recently played history presentation surface](0029-recently-played-history-presentation-surface.md) | Accepted | 2026-05-29 |
