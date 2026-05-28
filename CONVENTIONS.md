# Documentation conventions

This file declares the writing conventions used by the contractual
documents of this repository. It MUST be read by any contributor (human
or agent) before authoring or modifying those documents.

## Normative keywords (RFC 2119 / BCP 14 / RFC 8174)

The following key words MUST be interpreted as described in
[RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) and
[RFC 8174](https://www.rfc-editor.org/rfc/rfc8174) when, and only when,
they appear in **all capitals**:

| Keyword                     | Meaning                                                                                              |
|-----------------------------|------------------------------------------------------------------------------------------------------|
| **MUST** / **REQUIRED** / **SHALL** | Absolute requirement. Violation is an error.                                              |
| **MUST NOT** / **SHALL NOT**         | Absolute prohibition. Violation is an error.                                              |
| **SHOULD** / **RECOMMENDED**         | Strong recommendation. Deviation is permissible only with a clearly understood justification. |
| **SHOULD NOT** / **NOT RECOMMENDED** | Strong discouragement. Deviation is permissible only with a clearly understood justification. |
| **MAY** / **OPTIONAL**               | Freely optional. Either choice is valid.                                                  |

In lowercase ("must", "should", "may"), the same words carry their
ordinary English meaning and have no normative weight.

## Which documents are contractual

The keywords are used in the following documents:

- `API_SPEC.md`
- `ARCHITECTURE.md`
- `TECHNICAL_SPEC.md`
- `VALIDATION_CHECKLIST.md`
- Every Architecture Decision Record under `docs/adr/`.

The following documents are narrative or operational and do **not** use
the normative keyword convention. Their prose is informative:

- `CONTEXT.md`
- `MEMORY.md`
- `ROADMAP.md`
- `DESIGN.md`
- `AGENTS.md`
- `TESTING_STRATEGY.md`
- `TODO.md`
- `CONVENTIONS.md` (this file)

## How to apply the convention

When introducing or amending a contractual statement:

1. Decide whether the statement is an obligation (MUST), a strong
   preference (SHOULD), or a free choice (MAY).
2. Express it with the keyword in all capitals.
3. Avoid using the same word in lowercase in the same sentence; rephrase
   if the ambiguity would distract the reader.
4. Avoid stacking modifiers ("MUST always", "MUST never") — the keyword
   already carries the strength.

## How to read the convention

When reading a contractual document:

- A capitalised MUST / MUST NOT / REQUIRED / SHALL / SHALL NOT clause
  is a contract. Code that violates it fails a quality gate.
- A capitalised SHOULD / SHOULD NOT / RECOMMENDED / NOT RECOMMENDED
  clause is a default that may be overridden when the trade-off is
  understood.
- A capitalised MAY / OPTIONAL clause is a choice with no preferred
  side; pick what suits the situation.

Statements without any of these keywords are explanatory prose, not
contractual obligations.
