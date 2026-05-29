# ADR-0023 — API mirrors static list

- **Status:** Accepted
- **Date:** 2026-05-29
- **Deciders:** David Ruiz
- **Related:** `API_SPEC.md` §2, `ROADMAP.md` Phase 1/5

> This document uses the normative keyword convention defined in
> `CONVENTIONS.md`. Words in **all capitals** (MUST, SHOULD, MAY, etc.)
> carry the meanings defined there.

## Context

The Radio Browser API relies on geographically distributed mirrors. `API_SPEC.md` §2 establishes a failover strategy to rotate between "known-good mirrors" when requests fail, but the exact list of initial default mirrors was not defined in the specification. 

Without an explicit static list, developers would have to make arbitrary choices, risking the inclusion of slow, insecure, or decommissioned endpoints. We need a defined set of high-availability, HTTPS-enabled European mirrors as the baseline configuration for the application's network client.

## Decision

The application MUST pre-configure a static list of four default API mirrors in its network layer constants:

1. `https://de1.api.radio-browser.info` (Germany)
2. `https://at1.api.radio-browser.info` (Austria)
3. `https://nl1.api.radio-browser.info` (Netherlands)
4. `https://fr1.api.radio-browser.info` (France)

All network calls MUST cycle through these four servers using the failover rotation rules defined in `API_SPEC.md` §2. The mirrors MUST use the `https` scheme to guarantee secure communication.

## Consequences

### Positive
- Clarifies the baseline constants configuration, removing any ambiguity for Phase 1 and Phase 5 implementation.
- Enforces HTTPS for all API communications, avoiding mixed content issues on iOS and Android.
- Provides robust redundancy by utilizing four distinct high-availability mirrors in Western Europe.

### Negative
- If all four of these specific mirrors are blocked or down, network failover fails (mitigated by using `last_known_mirror` cache in Hive to allow quick recovery if mirrors fluctuate).

### Neutral
- The order of selection starts with the cached mirror or defaults to Germany (`de1`) as the primary endpoint.

## Alternatives considered

### Option B — Use SRV DNS Lookup
Resolve active mirrors dynamically. Rejected due to latency, potential mobile network blockages of SRV records, and testing complexity.

### Option C — Define only 3 mirrors
Rejected in favor of including France (`fr1`) to provide additional redundancy.

## Documentation impact

- `API_SPEC.md` §2 — documented the exact list of four API mirrors to be configured.
- `ROADMAP.md` Phase 1 — updated the task "Define mirror URL constants" to reference this static list.
