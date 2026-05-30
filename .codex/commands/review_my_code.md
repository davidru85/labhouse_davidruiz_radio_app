---
description: Review all changed files and validate whether they are OK to commit, using code_review_agent.md as the review specification.
argument-hint: "[optional: extra focus or scope notes]"
---

# Review My Code

Perform a full code review of the currently changed files and decide whether they are **OK to commit**.

The authoritative review specification lives in `code_review_agent.md` at the repository root. That file defines the reviewer persona, mandatory reading order, normative language, blocking rules, TDD checkpoint rules, architecture/API/error/persistence/test checklists, and the required output format. **It is the single source of truth for how this review must be conducted.**

## Preflight

1. Determine the full set of changed files, including staged, unstaged, and untracked files:
   - `git status --porcelain`
   - `git diff`
   - `git diff --staged`
2. Read untracked files directly so new files are not missed.
3. Read `code_review_agent.md` in full and treat it as the governing review instructions.
4. Apply any extra focus or scope notes provided by the user as supplemental guidance only. User notes do not override `code_review_agent.md`, accepted ADRs, contractual documents, or the active TDD checkpoint.

## Review

Act as the Code Review Agent described in `code_review_agent.md`.

Before judging the change, follow the **Mandatory Reading Before Any Review** order from `code_review_agent.md`, including:

1. `MEMORY.md`
2. `CONTEXT.md`
3. `CONVENTIONS.md`
4. `docs/adr/README.md`
5. Any ADR directly referenced by the current task, changed files, changed behavior, or `MEMORY.md`
6. `ROADMAP.md`
7. The relevant contractual documents:
   - `ARCHITECTURE.md`
   - `TECHNICAL_SPEC.md`
   - `API_SPEC.md`
   - `VALIDATION_CHECKLIST.md`
8. `TESTING_STRATEGY.md`
9. `AGENTS.md`
10. `TODO.md`, `DESIGN.md`, `GLOSSARY.md`, and remaining Markdown files when relevant

If documentation conflicts, apply the canonical source map in `AGENTS.md`. Contractual documents and accepted ADRs are authoritative.

## Output

Return the verdict using the exact **Review Output Format** defined in `code_review_agent.md`:

- Verdict
- Checkpoint
- Findings
- Contract Validation
- Required Evidence Before Approval
- Suggested Commit Message

Findings come first within the review body and must be ordered by severity. Do not bury blockers.

## Commit Decision

After the review, summarize clearly whether the changes are **OK to commit**:

- **Approved**: state that no blocking issues were found and the changes are OK to commit. Surface the suggested Conventional Commit message.
- **Changes Requested** or **Blocked**: state that the changes are **NOT** OK to commit yet and list the blockers that must be resolved first.

Do **not** create any commit. Commits happen only after the human owner explicitly approves the checkpoint.
