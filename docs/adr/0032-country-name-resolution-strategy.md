# ADR-0032 — Country name resolution strategy

- **Status:** Accepted
- **Date:** 2026-05-29
- **Deciders:** David Ruiz
- **Related:** `API_SPEC.md` §6.3, `ROADMAP.md` Phase 2, ADR-0005, ADR-0018

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
- The `country_name_resolver` utility helper MUST dynamically look up the string key `country_${isoCode.toUpperCase()}` using the generated AppLocalizations classes.
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

## Documentation impact

- `API_SPEC.md` §6.3 — updated the country name resolver description.
- `ROADMAP.md` Phase 2 — added tasks to include country translation keys in the initial ARB file.
