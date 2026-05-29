# Claude Analysis — Pre-Implementation Documentation Review

> **Scope:** Gap analysis of the planning/documentation suite before the coding
> phase begins. Re-checked after the addition of ADRs 0020–0025 (commit `f95cb4e`).
> **Date:** 2026-05-29

---

## Overall assessment

The documentation corpus (14 root docs + 25 ADRs) is unusually complete and
internally cross-referenced: canonical-source map, RFC-2119 conventions, a
validation checklist, a per-phase roadmap, and ADRs that trace cleanly into the
specs. Architecture, API integration, failure taxonomy, persistence, and the
test matrix are all defined to a buildable level.

The most recent round of changes closed the majority of the previously
identified gaps and fixed a latent hard-constraint violation. The remaining
items are a small number of behavioral/decision gaps plus minor doc drift.

---

## ✅ Resolved

- **`audio_service` background/lock-screen controls** → **ADR-0022**. Fully
  specified: controls limited to Play/Pause/Stop, skip/seek disabled, station
  name as title + `NowPlayingInfo` (or genre/country fallback) as subtitle.
  Propagated into `ARCHITECTURE.md` (new §Background Media Controls),
  `TECHNICAL_SPEC.md` §4, `VALIDATION_CHECKLIST.md` §Playback, `ROADMAP.md`
  Phase 6, with the deferred Next/Previous item tracked in `TODO.md`.
- **Mirror list was illustrative ("for example")** → **ADR-0023**. Now a
  concrete static list of 4 HTTPS mirrors (DE/AT/NL/FR); `API_SPEC.md` §2 and
  ROADMAP Phase 1 updated. Forcing HTTPS is the right call.
- **History contract under-defined** → **ADR-0021**. 50-item FIFO cap +
  promote-on-replay (dedup) pinned in `TECHNICAL_SPEC.md` §4,
  `VALIDATION_CHECKLIST.md`, ROADMAP Phase 6.

## ✅ Good catches beyond the original review

- **ADR-0014 rework** — `CancelToken` moved out of the BLoC into
  `RemoteStationDataSource` + a `cancelSearch()` repository method /
  `CancelSearchUseCase`. This fixed a latent **hard-constraint violation**: the
  old wording had the BLoC handling Dio `CancelToken`s, which breaks
  "Presentation MUST NOT access `Dio`" (`AGENTS.md` §Hard Constraints).
- **ADR-0024** — Icy multi-separator parsing (split on *first* ` - `). The old
  rule ("exactly one separator, else null") would have silently dropped valid
  metadata like `Artist - Song - Live`.
- **ADR-0020** — favorites orphan handling on `byuuid` sync (mark
  `lastCheckOk=false`, never silent-delete). Closed a genuine gap in
  `API_SPEC.md` §8.
- **ADR-0025** — offline play goes Buffering→Error for lifecycle uniformity.
  Good consistency fix for the Phase 7 test matrix.

## 🟡 Partially resolved

- **What triggers `AddToHistory`.** ADR-0021 implies "on play" and defines
  dedup/cap, but still doesn't name *which component fires it or at which
  transition* (e.g. `RadioPlayerBloc` on entering `PlayerPlayingState` vs
  `StationsBloc` on `StationPlayRequested`). The storage contract is solid; the
  cross-BLoC firing point is still unstated — a test-writing decision for
  Phase 7.

## 🔴 Still open

- **`flutter create` bundle-ID trap.** Most concrete Phase-1 blocker.
  `ROADMAP.md` Phase 1 + ADR-0003 are untouched: `--project-name radio_app`
  yields `applicationId = ...radio_app`, but the spec requires `...radioapp`.
  Phase 1 needs an explicit manual native-ID override step (or an ADR-0003 note).
- **Popular-stations strategy.** `MEMORY.md` Pending Question #2 is still open,
  and ROADMAP Phase 3 still carries both `LoadTopClickStationsUseCase` /
  `LoadTopVoteStationsUseCase` while `API_SPEC.md` §5.2 marks the top endpoints
  OPTIONAL. Scopes Phases 3/5 — undecided.
- **Error observability / crash reporting.** No decision (ADR-0018 rejected
  `logger`, nothing replaces it). Defensible as "none for v1," but should be an
  explicit one-line ADR.
- **History has no presentation surface.** Only Stations + Favorites tabs in
  `DESIGN.md`; no `HistoryScreen`/route. UI-gated, but affects Phase 8 routing.
- **Pagination end-of-list / dedup / `STATIONS_MAX_LIMIT=100` vs page 30
  interaction.** Still unspecified.

## 🆕 New inconsistencies introduced by the edits

- **`README.md` counts are now stale.** It still says "19 accepted ADRs and 6
  inherited" and "14 features deliberately deferred" — there are now **25 ADRs**
  and one more deferred item (Next/Previous).
- **`TESTING_STRATEGY.md` §StationsBloc not updated for the ADR-0014 refactor.**
  It still asserts bloc-observable cancellation "when a new `SearchStations` /
  `FilterByCountry` / `FilterByGenre` event arrives," but cancellation is now
  automatic inside the data layer, and there's no test bullet for the new
  `CancelSearchUseCase` being invoked on `StationPlayRequested`/dispose.

---

## Correctly out of scope (not blocking)

Theming/design tokens, app icon, splash, contrast/screen-reader passes are
UI-gated to Phase 9. App store metadata, licensing, continuous delivery/signing,
CHANGELOG, coverage thresholds, analytics provider + GDPR consent, auto-resume,
sleep timer, volume control are explicitly deferred in `TODO.md` with backing
ADRs. Deep links, push notifications, RTL, state restoration are not in product
scope and not implied by any contract.

---

## Bottom line

Of the 5 original blockers, **1 is fully closed** (audio_service controls),
**1 is mostly closed** (history trigger), and **3 remain** (bundle-ID,
popular-stations, error observability) — plus the History-surface and pagination
loose ends, and two minor doc-drift items.

### Suggested quick tidy-ups
1. Bump `README.md` decision-summary counts (25 ADRs, deferred-feature count).
2. Update `TESTING_STRATEGY.md` §StationsBloc cancellation bullets to match ADR-0014.
3. Add a one-paragraph ADR-0003 note for the bundle-ID override at scaffold time.
