---
description: Review the issues the user collected in code_review_result.md, verify each against the repo, fix only the real ones, delete the file, and hand back for re-review (no commit).
argument-hint: "[optional: a different review file path, or extra focus notes]"
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git diff --staged:*), Bash(git log:*), Bash(git show:*), Bash(flutter analyze:*), Bash(flutter test:*), Bash(rm:*), Read, Glob, Grep, Edit, Write
---

# /fix_review_issues

The user has just reviewed the pending changes with AI agents and collected the issues into **`code_review_result.md`** (at the repo root) before committing. Your job: read that file, fix the issues it raises, delete the file, and then let the user know so they can review again.

The end state is: real issues fixed, `code_review_result.md` deleted, the user notified. **Do not commit, push, or merge** — the user re-reviews and owns the commit.

## Critical: verify before you fix

Review output from AI agents is frequently **wrong**. Past runs produced false positives such as "production code committed before RED", a phantom `git push` line supposedly added to `AGENTS.md`, and a non-existent `UseCase` contract. **Never apply a fix on the strength of the review file alone — confirm each finding against the actual repository first.** Rebut the false ones with evidence; fix only the real ones.

`ARCHITECTURE.md` §4 is canonical (e.g. the real `UseCase<T, Params>` requirement). When documents conflict, apply the source map in `AGENTS.md`. A finding that contradicts canonical docs is a false positive.

## Steps

1. **Read the review file.** `Read` `code_review_result.md` at the repo root (or the path/notes given in `$ARGUMENTS`). Extract every distinct finding — blockers, non-blocking issues, and questions.

2. **Establish ground truth.** Before judging any finding, check the real repo state: `git status --porcelain`, `git log --oneline -n 10`, `git show <commit>` for any referenced commit, `git diff` / `git diff --staged`, and `Read` untracked files directly. Consult the governing docs the findings lean on (`ARCHITECTURE.md` §4 first, then `AGENTS.md`, `ROADMAP.md`, relevant ADRs, `TESTING_STRATEGY.md`, `MEMORY.md`).

3. **Classify each finding as REAL or FALSE POSITIVE**, with concrete evidence — `file:line`, `git show` output, or freshly-run `flutter analyze <paths>` / `flutter test <paths>` results, never the reviewer's say-so.

4. **Fix the real issues** with the minimal change that satisfies the contract, staying inside the current TDD step (RED → GREEN → REFACTOR). If a fix would change checkpoint state — touching tests, adding production code during RED, weakening a test — STOP and ask for explicit approval first, explaining why. Do not fix false positives; note the evidence that refutes them.

5. **Re-validate.** Run `flutter analyze` and `flutter test` on the affected paths and confirm they are clean.

6. **Delete the file.** `rm code_review_result.md` so it is never swept into a commit. If a real blocker remains unresolved because it needs the user's approval, do NOT delete the file — leave it and say so.

7. **Hand back.** Tell the user it's ready for re-review. Reply in the user's language (the user often writes in Spanish — match it). Summarize per finding: REAL → what you fixed, or FALSE POSITIVE → the evidence refuting it. Then state the re-validation result and that `code_review_result.md` was deleted. Do not commit, push, or merge.
