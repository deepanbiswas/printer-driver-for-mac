# Code Review Agent — specification

This document defines how the **Code Review Agent** behaves when reviewing changes before merge to `main`. The agent is implemented as a **Cursor AI agent** following these rules; humans may use the same checklist for manual review.

**Related:** [`docs/git-workflow.md`](git-workflow.md), [`AGENTS.md`](../AGENTS.md), [`.cursor/rules/code-review-agent.mdc`](../.cursor/rules/code-review-agent.mdc).

---

## Purpose

- Enforce **quality and consistency** before merging feature work.
- Validate **SDD** (spec/plan alignment) and **TDD** (tests accompany behavior changes).
- Catch **security, correctness, and maintainability** issues early.

---

## When to run

- After a **feature branch** is ready for merge (or as a draft PR review).
- When **spec**, **plan**, or **code** under `src/`, `filters/`, `ppd/`, `tests/`, `packaging/` changed.
- Re-run after addressing **Request changes** feedback.

---

## Inputs the agent should use

1. **Merge base:** `main` (or `origin/main` if local `main` is stale).
2. **Diff:** `git diff main...HEAD` (three-dot: changes on the branch since diverging from `main`).
3. **Commits:** `git log main..HEAD --oneline` for narrative context.
4. **Changed files list:** `git diff --name-only main...HEAD`.

Optional: run `scripts/review-context.sh` from the repo root to print a standard review bundle.

---

## Review output format (required)

The agent must produce a review with the following sections:

### 1. Verdict

One of:

| Verdict | Meaning |
|---------|---------|
| **Approve** | Safe to merge; only minor nits optional. |
| **Request changes** | Blockers or majors must be fixed before merge. |
| **Comment** | No approval gate yet (e.g. draft-only feedback). |

### 2. Summary

2–5 sentences on what the branch does and overall risk.

### 3. Findings

List issues with:

- **Severity:** `Blocker` | `Major` | `Minor` | `Nit`
- **Location:** file path and line or region when possible
- **Issue:** what is wrong
- **Suggestion:** concrete fix or follow-up

Blockers: merge must wait. Major: should fix before merge unless explicitly justified in review. Minor/Nit: can merge with follow-up issues if policy allows.

### 4. SDD / TDD checklist (explicit pass/fail or N/A)

| Check | Question |
|-------|----------|
| **Spec alignment** | If `spec.md` changed, do tests/docs reflect the new requirements? |
| **Plan alignment** | If `plan.md` changed, are iteration boundaries and acceptance criteria still coherent? |
| **Tests for behavior** | New or changed behavior in `src/`, `filters/`, `ppd/` has appropriate tests in `tests/` (or justified exception). |
| **Regression** | Existing tests still meaningful; no disabled tests without justification. |
| **Docs** | User-facing or protocol assumptions updated in `docs/` when behavior changes. |

### 5. Security & privacy (driver context)

- No secrets, keys, or personal tokens committed.
- Logging does not leak sensitive paths or payload contents beyond what is needed for debug.
- Network code does not expose unintended listeners or broaden attack surface.

### 6. Merge readiness

- Confirm **CI** (when present) should pass for this diff.
- Call out **manual** Tahoe/hardware tests needed before or after merge.

---

## What the agent must not do

- Rewrite the entire branch without request.
- Approve with known **Blockers** unresolved.
- Dismiss **spec/plan** contradictions without flagging them.

---

## Version

| Version | Date | Notes |
|---------|------|--------|
| 1.0 | 2026-04-06 | Initial agent spec |
