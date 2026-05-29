# ADR-0028 — Error observability and crash reporting

- **Status:** Accepted
- **Date:** 2026-05-29
- **Deciders:** David Ruiz
- **Related:** `TECHNICAL_SPEC.md` §5, ADR-0018, ADR-0019

> This document uses the normative keyword convention defined in
> `CONVENTIONS.md`. Words in **all capitals** (MUST, SHOULD, MAY, etc.)
> carry the meanings defined there.

## Context

Production-grade applications usually integrate error observability tools (like Sentry, Firebase Crashlytics, or Bugsnag) to monitor unhandled exceptions and track diagnostic logs.

Currently, the project contains no dependencies or policies regarding error logging or crash reporting. We need to define the scope and tooling for error monitoring in version 1 of the application, keeping in mind privacy concerns and target dependencies.

## Decision

For version 1 of the application, external error reporting and crash observability services MUST NOT be integrated.

Specifically:
- Diagnostic logging is restricted to local console logs using standard tools like `debugPrint` or a basic custom log utility.
- Non-development logging (such as unhandled exceptions sent to remote dashboards) is deferred to future iterations.
- In-production logs MUST NOT leak any sensitive user data.

## Consequences

### Positive
- Minimizes external package bloat and keeps the build footprint small (reduces risk of dependency conflicts).
- Remains fully compliant with a privacy-first, zero-telemetry default stance until a proper GDPR consent flow is introduced (as tracked in `TODO.md` per ADR-0019).
- No API keys, credentials, or remote dashboards need configuration in CI/CD or compile-time variables.

### Negative
- We will not have real-time visibility into unhandled crashes or playback issues encountered by real users in production.

## Alternatives considered

### Option A — Integrate Firebase Crashlytics or Sentry
Add third-party packages to track crashes. Rejected because it complicates project initialization, introduces privacy/GDPR implications that we are not yet prepared to resolve (consent tracking is out-of-scope for v1), and violates the goal of starting with a lightweight, zero-configuration setup.

## Documentation impact

- `TECHNICAL_SPEC.md` §5 — clarified console-only logging for unhandled exceptions.
- `TODO.md` — added remote crash reporting integration as a deferred feature.
