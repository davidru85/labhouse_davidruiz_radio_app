# Merged Documentation Readiness Analysis

Date: 2026-05-29

Scope: Consolidates the findings from:

- `analysis/claude_analysis.md`
- `analysis/codex_analysis.md`
- `analysis/deepseek_analysis.md`
- `analysis/gemma_analysis.md`
- `analysis/qwen_analysis.md`

No Flutter or Dart implementation code was reviewed or changed for this
analysis. This document is a planning artifact for the pre-implementation
documentation phase.

## Executive Summary

The documentation suite is strong and unusually mature for a pre-coding Flutter
project. The accepted ADR set, canonical source map, RFC-2119 convention,
roadmap, testing strategy, and validation checklist provide a solid foundation
for a disciplined Phase 1 implementation.

The project is not fully implementation-ready yet because recent documentation
updates have introduced contradictions and stale references. The most important
problems are concentrated in four areas:

1. The UI/design gate is inconsistent after the Stitch design export was added.
2. `DESIGN.md` contains controls and display text that conflict with accepted
   ADRs and the Radio Browser data model.
3. `API_SPEC.md` still describes the superseded popular-stations strategy.
4. Several implementation contracts are named but not precise enough for
   repeatable TDD work.

Some reported items are not documentation blockers. Missing files such as
`config/app.json`, `.github/workflows/ci.yml`, `lefthook.yml`, updated
`pubspec.yaml`, and corrected platform folders are expected Phase 1 tasks, not
evidence that planning has failed.

## Readiness Verdict

Current status: almost ready, but not ready to start coding safely.

Minimum pre-coding cleanup:

1. Resolve the UI gate status.
2. Align `DESIGN.md` with accepted v1 scope.
3. Rewrite `API_SPEC.md` popular stations section to match ADR-0027.
4. Define repository/use-case/failure contracts precisely enough for TDD.
5. Split Phase 1 into smaller Red/Green/Refactor sub-tasks.

After those fixes, Phase 1 can begin under the existing mandatory TDD checkpoint
process.

## Blocking Issues

### B1. UI Gate Status Is Contradictory

Consensus: reported by all five analyses.

`DESIGN.md` now says visual specifications are available from the Labhouse David
Radio Stitch export, including tokens, screen catalog, component notes, and
screen mapping.

However, multiple files still describe UI as blocked because visual
specifications are pending:

- `CONTEXT.md`: UI status is still "Design pending".
- `DESIGN.md`: still says UI/layout/styling code must not be generated until
  detailed visual specifications are provided.
- `AGENTS.md`: prohibits UI/styling code until specs are provided.
- `MEMORY.md`: still asks what design system will be used.
- `README.md`: document map still describes `DESIGN.md` as UI work blocked
  until specs.
- `ROADMAP.md`: correctly gates Phase 9 on specs plus explicit user approval,
  but the meaning of "specs provided" is now unclear.

Decision needed:

- Option A: Treat the Stitch export as the visual specification. UI work still
  remains Phase 9 only and still requires explicit user approval before starting.
- Option B: Keep UI blocked. Clarify that the Stitch export exists but has not
  yet been accepted as sufficient implementation guidance.

Recommended resolution: Option A, phrased carefully as "visual specifications
are available, but Phase 9 remains blocked until explicit user approval." This
keeps the roadmap and permission protocol intact while removing stale "design
pending" language.

### B2. `DESIGN.md` Includes Features Excluded From v1

Consensus: reported by Claude, Codex, DeepSeek, and Qwen.

Conflicts:

| Design item | Conflict |
| --- | --- |
| In-app volume slider and `volume_mute` / `volume_up` icons | ADR-0010 chooses system volume only. |
| Sleep footer action and `timer` icon | ADR-0011 defers sleep timer out of v1. |
| Up Next footer action and `playlist_play` icon | ADR-0022 limits live radio controls and defers queue/skip semantics. |
| Share footer action | No accepted v1 scope or ADR defines share behavior. |

Decision needed:

- Remove all four from the v1 design spec, or
- Author new ADRs that explicitly bring any desired feature into scope.

Recommended resolution: remove or mark these controls as "present in Stitch
export but out of scope for v1 and not to be implemented." Bringing them into
scope would expand v1 and require ADR work before implementation.

### B3. `DESIGN.md` Uses Fictional Frequency Subtitles

Consensus: reported by Claude, DeepSeek, and Qwen.

`DESIGN.md` uses examples such as:

- `101.9 MHz - Ambient`
- `104.2 FM - London`

The `RadioStation` entity in `API_SPEC.md` has no frequency, MHz, or FM field.
Radio Browser stations are internet streams, so an implementer cannot wire this
text to real data.

Decision needed:

- Use `primary genre - country` / `genre - country` style subtitles, or
- Use technical fields such as `bitrate`, `codec`, and genre.

Recommended resolution: use genre plus country for product-facing subtitles,
with technical fields reserved for secondary metadata if the UI later needs it.

### B4. Popular Stations Strategy Is Stale In `API_SPEC.md`

Consensus: reported by Codex, DeepSeek, and Qwen.

ADR-0027 says popular stations MUST be retrieved through:

- `/json/stations/search`
- `order=clickcount` or `order=votes`
- `reverse=true`

It also says `/json/stations/topclick` and `/json/stations/topvote` SHALL NOT be
integrated, and replaces `LoadTopClickStationsUseCase` /
`LoadTopVoteStationsUseCase` with unified search parameterization.

`API_SPEC.md` section 5.2 still lists:

- `GET /json/stations/topclick/{limit}`
- `GET /json/stations/topvote/{limit}`
- `LoadTopClickStationsUseCase`
- `LoadTopVoteStationsUseCase`

Resolution required: rewrite `API_SPEC.md` section 5.2 so it makes
`LoadPopularStationsUseCase` and search-based popularity the only v1 strategy.
This is not a new product decision; the decision already exists in ADR-0027.

### B5. Repository, Use-Case, And Failure Contracts Are Underspecified

Consensus: reported by Codex and DeepSeek; indirectly supported by Qwen.

The docs list required repositories, use cases, BLoCs, and failure groups, but
do not define enough concrete interface detail for consistent TDD
implementation.

Missing or ambiguous:

- Project-wide return convention: thrown exceptions, sealed result type, or
  another custom pattern.
- Whether a custom `Result<T>`/`Either` equivalent will be implemented locally,
  since no `dartz` or `fpdart` dependency is approved.
- Repository method signatures.
- Use-case `call()` signatures and request/response models.
- Pagination parameter model and result shape.
- Search cancellation contract.
- Stream contracts for audio playback, now-playing metadata, and connectivity.
- Empty response behavior: empty list vs failure by endpoint.
- Failure constructors, fields, equality, retryability, user-facing copy,
  localization keys, and original-cause handling.
- Dio exception/status mapping into `ApiFailure` and `NetworkFailure`.

Resolution required: add a contractual "Domain Contracts" section or document
before Phase 2 starts. Because Phase 1 may introduce networking primitives, at
least the error/result convention and Dio mapping should be clarified before
the first networking implementation task.

## High-Priority Documentation Fixes

### H1. Phase 1 Dio / Mirror Failover Scope Is Ambiguous

Reported by Codex and DeepSeek.

`ROADMAP.md` Phase 1 includes a `Dio` client factory with mirror failover,
headers, and timeouts. Full mirror persistence depends on Hive box
`app_settings`, which is scheduled for Phase 4.

Clarify one of these boundaries:

- Phase 1 creates only constants, headers, timeout configuration, and basic
  mirror iteration without Hive persistence.
- Phase 1 creates a testable networking component with an injectable mirror
  cache abstraction, and Phase 4 supplies the Hive-backed implementation.

Recommended resolution: define a temporary Phase 1 boundary so bootstrap work
does not pull Phase 4 storage implementation forward.

### H2. Phase 1 TDD Strategy Is Too Batch-Oriented

Reported by Codex, DeepSeek, and Qwen.

`TESTING_STRATEGY.md` lists many Phase 1 RED checks as a block. The project
requires strict Red/Green/Refactor micro-cycles with review before each step.

Resolution required: split Phase 1 into explicit sub-tasks, each with:

- RED test/check file and expectation.
- GREEN implementation scope.
- REFACTOR criteria.
- Required checkpoint output.

This prevents an agent from writing a large batch of failing tests and then
implementing a broad unrelated set of fixes.

### H3. `DESIGN.md` References Missing Or Broken Stitch Assets

Consensus: reported by Claude, DeepSeek, and Qwen.

Verified state:

- `stitch_export.txt` is referenced but does not exist.
- `DESIGN.md` references both `stitch_export.txt` and a different
  `stitch/export.txt` wording.
- Screen catalog links point to absolute `file:///Users/.../Documents/...`
  paths outside the repository.
- `stitch/full_player/screen.png` exists but is only 28 bytes, so it is a
  placeholder or invalid image.
- `stitch/full_player/code.html` is absent, unlike the stations and favorites
  screens.

Resolution required:

- Replace absolute links with relative repository links.
- Either add the raw export file or remove references to it.
- Mark the full-player asset as pending or provide a valid export.
- Consider adding `stitch/README.md` with an inventory and asset status.

### H4. `MEMORY.md` Has Stale Entries

Consensus: reported by Claude, Codex, DeepSeek, and Qwen.

Stale or partly stale:

- Pending question about the exact visual design system is now answered if the
  Stitch export is accepted.
- Country-name risk is resolved at strategy level by ADR-0032, though
  implementation work remains.
- UI risk wording depends on the B1 decision.

Not all current risks are stale. Mirror availability and broken station streams
remain real operational risks even though the architecture has mitigation
strategies.

Resolution required: refresh `MEMORY.md` after the B1 decision. Keep genuine
runtime risks; remove or reword resolved planning questions.

### H5. README AI-Agent Reading Order Diverges From `AGENTS.md`

Reported by Codex, DeepSeek, and Qwen.

`AGENTS.md` mandates this startup order:

1. `MEMORY.md`
2. `CONTEXT.md`
3. `CONVENTIONS.md`
4. `docs/adr/README.md`
5. Relevant ADRs
6. Relevant contractual docs

`README.md` has a shorter AI-agent order that omits several required documents.

Resolution required: update `README.md` to reference `AGENTS.md` as the
authoritative startup protocol or duplicate the mandated order exactly.

### H6. ADR Cross-Reference Hygiene Is Needed

Reported by Claude, DeepSeek, and Qwen.

Items:

- ADR-0012 says Icy metadata splits only when exactly one ` - ` separator
  exists.
- ADR-0024 changes the rule to split on the first separator.
- `API_SPEC.md` already reflects ADR-0024.

Resolution required: add a cross-reference note to ADR-0012 that its parsing
rule is amended or partially superseded by ADR-0024. Do not silently edit the
accepted decision without following the project's ADR immutability convention.

Related minor tension:

- ADR-0005 rejects a hand-maintained country table.
- ADR-0032 introduces ARB-based country keys.

Resolution required: add a cross-reference explaining that ADR-0032 extends the
localization workflow rather than contradicting ADR-0005.

### H7. Now-Playing Fallback Subtitle Is Ambiguous

Reported by Claude and DeepSeek.

ADR-0022 and `ARCHITECTURE.md` say notification subtitle falls back to a static
genre or country subtitle. The word "or" leaves implementation undefined.

Resolution required: choose a deterministic fallback order, for example:

1. `NowPlayingInfo` formatted as `Artist - Track`.
2. Primary genre.
3. Country display name.
4. App name or "Live radio".

### H8. Inter Font Requirement Is Not Accounted For

Reported by DeepSeek and Qwen.

`DESIGN.md` specifies Inter, but the technical docs and dependency list do not
say whether Inter will be bundled as a font asset, omitted, or introduced through
a dependency.

Resolution required before Phase 9:

- Prefer bundling font assets if Inter is required.
- Record license and asset setup.
- Avoid adding an unapproved font package without ADR-0018 amendment.

### H9. L10n Configuration Is Under-Mentioned

Reported by Qwen.

Phase 2 references `lib/l10n/intl_en.arb`, but the docs do not mention a
`l10n.yaml` file or generated localization output conventions.

Resolution required: add `l10n.yaml` to the Phase 2 checklist or technical spec
if Flutter localization generation is expected.

### H10. License Is Undecided And Not Tracked

Consensus: reported by Claude, Codex, DeepSeek, and Qwen.

`README.md` says the license is to be decided before the repo becomes public.
That is acceptable now, but it should be tracked in `TODO.md` or resolved before
delivery.

## Expected Phase 1 Tasks, Not Documentation Blockers

Several analyses listed missing files or non-conforming scaffold state. These
are real tasks, but the roadmap already expects them in Phase 1.

Do not treat these as pre-coding documentation blockers:

- `config/app.json` does not exist yet.
  - ADR-0007 already defines exact initial contents.
  - A summary table in `TECHNICAL_SPEC.md` may improve discoverability, but the
    source of truth exists.
- `pubspec.yaml` still has the default scaffold package/dependencies.
- `analysis_options.yaml` still uses `flutter_lints`.
- `web/`, `macos/`, `linux/`, and `windows/` still exist.
- `lib/main.dart` still contains the default counter app.
- `.github/workflows/ci.yml` does not exist.
- `lefthook.yml` does not exist.
- Native Android/iOS config is not aligned yet.

These should be handled through Phase 1 TDD micro-cycles after the documentation
blockers above are resolved.

## Findings That Should Be Reclassified Or Ignored

Some source analyses over-classified issues:

- "Deployment credentials" are not needed for the currently specified debug
  Android/iOS verification builds. Release signing and continuous delivery are
  deferred in `TODO.md`.
- `config/app.json` values are not missing from the project decision record;
  ADR-0007 contains the exact JSON.
- The mirror and broken-stream risks in `MEMORY.md` are not fully resolved by
  ADRs. ADRs provide mitigation, but the external systems can still fail.
- `VALIDATION_CHECKLIST.md` already includes the Phase 9 accessibility visual
  checkpoint items as bullets. It can be reformatted for clearer checklist use,
  but the content is not absent.

## Recommended Resolution Order

1. Decide the UI gate state:
   - Accept Stitch as visual spec, or keep UI blocked pending explicit design
     acceptance.
2. Align `DESIGN.md` with v1 scope:
   - Remove/defer volume, Sleep, Up Next, and Share.
   - Replace frequency examples with real data fields.
3. Fix `API_SPEC.md` section 5.2 to match ADR-0027.
4. Refresh `MEMORY.md` and `README.md` after the UI gate decision.
5. Fix Stitch asset links and missing/invalid asset references in `DESIGN.md`.
6. Add ADR cross-reference notes for ADR-0012/ADR-0024 and ADR-0005/ADR-0032.
7. Define domain contract signatures and project-wide failure/result
   conventions.
8. Clarify Phase 1 networking scope.
9. Split Phase 1 into explicit TDD micro-cycles.
10. Track license and Inter font decisions for later delivery/UI phases.

## Consolidated Issue Register

| ID | Severity | Issue | Primary files |
| --- | --- | --- | --- |
| B1 | Blocking | UI gate contradiction after Stitch export | `DESIGN.md`, `CONTEXT.md`, `AGENTS.md`, `MEMORY.md`, `README.md`, `ROADMAP.md` |
| B2 | Blocking | Design includes v1-forbidden controls | `DESIGN.md`, ADR-0010, ADR-0011, ADR-0022 |
| B3 | Blocking | Frequency subtitles have no data source | `DESIGN.md`, `API_SPEC.md` |
| B4 | Blocking | Popular stations spec still uses superseded endpoints/use cases | `API_SPEC.md`, ADR-0027 |
| B5 | Blocking | Repository/use-case/failure contracts lack precise signatures | `ARCHITECTURE.md`, `TECHNICAL_SPEC.md`, `ROADMAP.md` |
| H1 | High | Phase 1 Dio/mirror scope overlaps later Hive persistence | `ROADMAP.md`, `API_SPEC.md`, ADR-0016 |
| H2 | High | Phase 1 RED checks are too batch-oriented | `TESTING_STRATEGY.md`, `ROADMAP.md`, `AGENTS.md` |
| H3 | High | Stitch asset references are missing, broken, or non-portable | `DESIGN.md`, `stitch/` |
| H4 | High | `MEMORY.md` has stale design/country entries | `MEMORY.md`, ADR-0032 |
| H5 | High | README AI-agent reading order diverges from required order | `README.md`, `AGENTS.md` |
| H6 | Medium | ADR supersession/cross-reference hygiene needed | ADR-0012, ADR-0024, ADR-0005, ADR-0032 |
| H7 | Medium | Notification subtitle fallback is ambiguous | `ARCHITECTURE.md`, ADR-0022 |
| H8 | Medium | Inter font requirement is unspecified for implementation | `DESIGN.md`, `TECHNICAL_SPEC.md`, ADR-0018 |
| H9 | Medium | `l10n.yaml` is not specified | `ROADMAP.md`, `TECHNICAL_SPEC.md` |
| H10 | Low | License decision is untracked | `README.md`, `TODO.md` |

## Proposed Definition Of Done For Documentation Readiness

Before coding starts, the documentation should satisfy:

- There is one clear statement of UI spec status and Phase 9 gate status.
- `DESIGN.md` contains only implementable v1 behavior or clearly marks future
  elements as out of scope.
- Popular stations are specified only through the ADR-0027 search strategy.
- Phase 1 has small TDD sub-tasks that respect Red/Green/Refactor checkpoints.
- Domain result/failure conventions are precise enough that multiple
  implementers would produce compatible repository and use-case interfaces.
- Stale references in `README.md`, `MEMORY.md`, and `DESIGN.md` are corrected.
- Missing Phase 1 scaffold artifacts remain in the roadmap as implementation
  tasks, not as unresolved planning questions.

