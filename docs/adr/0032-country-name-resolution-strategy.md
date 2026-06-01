# ADR-0032 — Country name resolution strategy

- **Status:** Accepted
- **Date:** 2026-05-29
- **Amended:** 2026-06-01 — the helper is a **pure** function that receives a
  lookup callback rather than calling `AppLocalizations` itself, because
  Flutter's `gen-l10n` generates **named getters** (`l10n.country_DE`) and
  exposes **no dynamic string-key lookup**. Resolution happens at the
  presentation boundary; the data-layer mapper leaves the name as the raw
  ISO code. See "Amendment (2026-06-01)" below.
- **Deciders:** David Ruiz
- **Related:** `API_SPEC.md` §6.3, `ROADMAP.md` Phase 2, ADR-0005, ADR-0017, ADR-0018, ADR-0034

> This document uses the normative keyword convention defined in
> `CONVENTIONS.md`. Words in **all capitals** (MUST, SHOULD, MAY, etc.)
> carry the meanings defined there.

## Context

The Radio Browser `/json/countrycodes` API returns a list of ISO country codes (e.g. "ES", "DE"). The application needs to display localized, human-readable country names (e.g. "Spain", "Germany") to the user.

[ADR-0005](0005-i18n-and-country-names.md) establishes that English is the launch language but we must scaffold the app for multi-language support (specifically Spanish). The standard Dart `intl` package does not contain a built-in database of localized ISO country codes.

We need to choose a strategy for translating ISO codes that scales cleanly, supports multi-language localization, and does not violate dependency constraints (ADR-0018).

## Decision

The country name resolution MUST be integrated into the application's standard localization system using ARB resource files.

Specifically:
- Country translations MUST be defined in localization ARB files (such as `lib/l10n/intl_en.arb`) using the naming convention `country_XX` (where `XX` is the uppercase ISO 3166-1 alpha-2 country code).
- The `country_name_resolver` utility helper MUST resolve the string key `country_${isoCode.toUpperCase()}` from the application's localizations (amended — see "Amendment (2026-06-01)" for how, given `gen-l10n`'s lack of dynamic lookup).
- If a translation key does not exist for a given country code, the helper MUST fall back gracefully to returning the raw uppercase ISO country code (e.g. "US").
- No external country name translation packages SHALL be added.

## Consequences

### Positive
- Zero external package footprint: respects ADR-0018 and keeps the binary size minimal.
- Scaling support: as the app localization expands (e.g. adding Spanish ARB files), country names will translate automatically without modifying code.
- Uniformity: leverages the standard `flutter_localizations` flow for all text translations in the app.

### Negative
- Requires maintaining a list of country code keys in the ARB files (we will populate the most common/mirror countries initially and expand as needed).

## Alternatives considered

### Option A — Static Map inside the Dart code
Hardcode a map of ISO codes directly inside the Dart helper class. Rejected because it would require branching code logic to support future languages, which violates the localized separation of concerns.

### Option C — Add an external translation package
Integrate packages like `flutter_country_names`. Rejected because it introduces unnecessary external dependencies, increases package footprint, and might not match the custom ARB-based localization scheme.

## Amendment (2026-06-01)

The original decision said the helper would "dynamically look up the string
key … using the generated AppLocalizations classes". Flutter's `gen-l10n`
generates one **named getter per ARB key** (`l10n.country_DE`) and provides
**no dynamic `lookup(String key)`** facility, so a `core/utils` helper
cannot resolve an arbitrary `country_${code}` key by itself. ADR-0034 also
forbids `core/utils` from importing `presentation/` (where `AppLocalizations`
is consumed). The strategy is therefore refined as follows:

- `country_name_resolver` is a **pure** function in `core/utils/`:
  `String resolveCountryName(String isoCode, String? Function(String key) lookup)`.
  It builds the key `country_${isoCode.toUpperCase()}`, calls `lookup`, and
  returns the result, falling back to the uppercase ISO code when `lookup`
  returns `null` (or when `isoCode` is blank). It imports nothing from
  `domain/`, `data/`, or `presentation/` (per ADR-0034).
- The **lookup callback** is supplied by the **presentation** layer, which
  adapts `AppLocalizations` (e.g. a `switch` over the generated getters, or
  a small generated map) into a `String? Function(String key)`. Country
  name resolution thus happens at the presentation boundary, where a
  `BuildContext`/locale is available.
- The **data-layer** `CountryCodeDto → Country` mapper does **not** localize:
  it sets `Country.countryCode` and `Country.name` to the raw ISO code from
  the API. Presentation replaces the display name via the resolver. (The
  `Country.name` field therefore carries the ISO code until the presentation
  boundary resolves it; this keeps the data layer free of localization.)

The ARB convention (`country_XX`), the uppercase-ISO fallback, and the
no-external-package rule are unchanged.

## Documentation impact

- `API_SPEC.md` §6.3 — updated the country name resolver description.
- `ROADMAP.md` Phase 2 — added tasks to include country translation keys in the initial ARB file.
- _Amendment (2026-06-01):_ `API_SPEC.md` §6.3 — note the pure
  lookup-callback signature and presentation-boundary resolution;
  `MEMORY.md` decision log — record the amendment.
