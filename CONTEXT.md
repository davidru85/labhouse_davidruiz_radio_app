# PROJECT CONTEXT

## Project Goal
Build a high-quality, production-grade online radio streaming application using Flutter.

The application must be robust, scalable, maintainable, and suitable for real Radio Browser API integration.

---

## Agent Role
Act as a Senior Software Engineer and Flutter/Dart expert.

The project must follow a rigorous development methodology:

* Clean Architecture.
* BLoC state management.
* Test-Driven Development.
* Strict static analysis.
* Explicit review checkpoints.

---

## Current Status
* **Phase:** Initial Setup / Infrastructure Bootstrapping.
* **UI Status:** Design pending.

---

## Project Start Condition (Critical)

### Design UI Status
Final visual and aesthetic details will be defined later using specialized design tools.

### Execution Rule
Generating code for user interfaces, layouts, or definitive styling is strictly prohibited until detailed visual specifications are provided.

For now, the focus must be exclusively on:

1. Application core architecture.
2. Contracts and abstractions.
3. Business logic.
4. Testing.
5. Full production-grade API integration.

---

## Core Product Scope

The app is an online radio streaming application backed exclusively by the Radio Browser public community-maintained API.

Core capabilities implied by the architecture:

* Discover stations.
* Search and filter stations.
* Browse by country and genre.
* Load popular stations.
* Play streams with fallback URL resolution.
* Persist favorites locally.
* Track recently played history locally.
* Cache genres and country codes for offline access.
* Handle broken or unreliable radio streams gracefully.

---

## Key Constraints

This list is a summary intended for new-session orientation. The
authoritative sources are linked alongside each item.

* Flutter >= 3.22 and Dart >= 3.4
  (`TECHNICAL_SPEC.md` §1).
* Target platforms: Android and iOS only (ADR-0001).
* BLoC is the only permitted state management approach
  (`TECHNICAL_SPEC.md` §1).
* `go_router` is used for routing (`TECHNICAL_SPEC.md` §1).
* `very_good_analysis` is configured with a zero-warnings policy
  (`TECHNICAL_SPEC.md` §1).
* Clean Architecture and the dependency rule
  (`ARCHITECTURE.md` §"Dependency Rule").
* DI via `get_it`; widgets never invoke `GetIt` directly
  (`ARCHITECTURE.md` §"Dependency Injection").
* Compile-time configuration only; no `.env` files; single flavor
  with `config/app.json` (`TECHNICAL_SPEC.md` §7, ADR-0007).
* The documentation conventions live in `CONVENTIONS.md`.
