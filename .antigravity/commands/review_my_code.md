---
description: Review all changed files and validate whether they are OK to commit, using code_review_agent.md as the review specification.
argument-hint: "[optional: extra focus or scope notes]"
allowed-tools: run_command(git status:*), run_command(git diff:*), run_command(git diff --staged:*), run_command(git log:*), view_file, list_dir, grep_search, invoke_subagent, send_message
---

# /review_my_code

Perform a full code review of the currently changed files and decide whether they are **OK to commit**.

The authoritative review specification lives in `code_review_agent.md` at the repository root. That file defines the reviewer persona, mandatory reading order, normative language, blocking rules, TDD checkpoint rules, architecture/API/error/persistence/test checklists, and the required output format. **It is the single source of truth for how this review must be conducted.**

## Steps

1. **Collect the changes to review.** Determine the full set of changed files (staged, unstaged, and untracked) so nothing is missed:
   - `git status --porcelain` using `run_command`
   - `git diff` (unstaged changes) using `run_command`
   - `git diff --staged` (staged changes) using `run_command`
   - For new/untracked files, use `view_file` to read them directly.

2. **Load the review specification.** Use `view_file` to read `code_review_agent.md` in full and treat it as your governing instructions for this review.

3. **Delegate the review to a dedicated review agent.** Launch a subagent via the `invoke_subagent` tool (subagent type `self`) whose entire job is to act as the Code Review Agent. Pass it:
   - The complete instructions from `code_review_agent.md` (the agent must read this file itself and follow it exactly).
   - The list of changed files and their diffs gathered in step 1.
   - Any extra focus or scope notes the user provided in `$ARGUMENTS`.

   Instruct the subagent to follow the **Mandatory Reading Before Any Review** order in `code_review_agent.md` (read `MEMORY.md`, `CONTEXT.md`, `CONVENTIONS.md`, ADRs, `ROADMAP.md`, the contractual docs, `TESTING_STRATEGY.md`, `AGENTS.md`, etc.) before judging the change, and to apply the canonical source map in `AGENTS.md` when documents conflict.

4. **Return the verdict in the required format.** The subagent MUST produce its output using the exact **Review Output Format** defined in `code_review_agent.md` (Verdict / Checkpoint / Findings / Contract Validation / Required Evidence Before Approval / Suggested Commit Message). Findings come first; do not bury blockers.

## Commit decision

After the review subagent returns, summarize clearly for the user whether the changes are **OK to commit**:

- **Approved** → state that no blocking issues were found and the changes are OK to commit. Surface the Suggested Commit Message.
- **Changes Requested** / **Blocked** → state that the changes are **NOT** OK to commit yet, and list the blockers that must be resolved first.

Do **not** create any commit yourself — per `code_review_agent.md`, commits happen only after the human owner approves the checkpoint. This command reviews and advises; it never commits.
