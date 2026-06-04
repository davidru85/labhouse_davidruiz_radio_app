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
| 0030 | [Android cleartext traffic configuration](0030-android-cleartext-traffic.md) | Accepted | 2026-05-29 |
| 0031 | [Search pagination deduplication and end-of-list behavior](0031-search-pagination-deduplication-and-end.md) | Accepted | 2026-05-29 |
| 0032 | [Country name resolution strategy](0032-country-name-resolution-strategy.md) | Accepted | 2026-05-29 |
| 0033 | [Branch before task execution](0033-branch-before-task.md) | Accepted | 2026-05-30 |
| 0034 | [Domain-free core utility return types](0034-domain-free-core-utils.md) | Accepted | 2026-05-30 |
| 0035 | [Pull request before next task branch](0035-pr-before-next-task-branch.md) | Accepted | 2026-05-31 |
| 0036 | [Push approved phase commits to the remote](0036-push-after-green-commit.md) | Accepted | 2026-05-31 (amended 2026-06-01) |
| 0037 | [Hive persistence model design](0037-hive-persistence-model-design.md) | Accepted | 2026-06-01 |
| 0038 | [Adopt Hive Community Edition (Hive CE)](0038-adopt-hive-community-edition.md) | Accepted | 2026-06-01 |
| 0039 | [Mirror failover networking architecture and remote error mapping](0039-mirror-failover-and-remote-error-mapping.md) | Accepted | 2026-06-01 |
| 0040 | [Defer the Favorites local search field](0040-favorites-local-search-deferral.md) | Accepted | 2026-06-03 |
| 0041 | [Routing shell via `StatefulShellRoute.indexedStack`](0041-stateful-shell-route-indexed-stack.md) | Accepted | 2026-06-03 |
| 0042 | [Platform-adaptive theming (Material/Cupertino); Liquid Glass deferred](0042-platform-adaptive-theming-liquid-glass-deferred.md) | Accepted | 2026-06-04 |
