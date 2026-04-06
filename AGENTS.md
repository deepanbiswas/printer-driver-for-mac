# Agents — Canon PIXMA G3010 macOS driver

This repository uses **Cursor** agents with explicit roles. Invoke them by **@mentioning the agent in the Cursor chat**, by describing the task in natural language (e.g. “run the code review agent on this branch”), or by opening the rule **“Code Review Agent”** in the rules picker when reviewing diffs.

---

## Code Review Agent

**Role:** Review changes on a **feature branch** (or PR) against `main` before merge. Enforce **SDD** (spec/plan consistency) and **TDD** (tests for behavior changes), plus security and maintainability for a CUPS/driver codebase.

**When to use**

- Before merging to `main` when `spec.md`, `plan.md`, or code under `src/`, `filters/`, `tests/`, `ppd/`, `packaging/`, or `fixtures/` changed.
- After pushing updates to address prior review feedback.

**How to run**

1. Check out the feature branch and ensure `main` is up to date (`git fetch origin main`).
2. Run `./scripts/review-context.sh` from the repo root (optional but recommended).
3. In Cursor, ask the agent to review **`main...HEAD`** (three-dot diff), or paste the script output + ask for a full review per [`docs/code-review-agent.md`](docs/code-review-agent.md).

**Authoritative instructions:** [`docs/code-review-agent.md`](docs/code-review-agent.md) and [`.cursor/rules/code-review-agent.mdc`](.cursor/rules/code-review-agent.mdc).

**Git workflow:** [`docs/git-workflow.md`](docs/git-workflow.md).

---

## Adding more agents

Document new agents in this file with: role, when to use, how to invoke, and a pointer to any detailed spec under `docs/` or `.cursor/rules/`.
