# Git workflow — feature branches and review

## Branching

- **`main`** holds integrated, reviewed work. Keep it **stable** and deployable for your personal use.
- **Feature branches** are required for any change that touches **artifacts**: code (`src/`, `filters/`, `tests/`, `ppd/`, `packaging/`, `fixtures/`), **`spec.md`**, or **`plan.md`**.

### Naming

Use a short, descriptive prefix:

- `feature/<topic>` — new functionality or iterations
- `fix/<topic>` — bugfixes
- `docs/<topic>` — documentation-only (optional branch; still review before merge if policy requires)

Examples: `feature/iteration-1-cups-stub`, `fix/network-timeout`, `docs/architecture-note`.

## Workflow

1. **Branch** from `main`: `git checkout main && git pull && git checkout -b feature/my-change`
2. **Commit** in logical chunks with clear messages.
3. **Open a pull request** to `main` (GitHub) or use **local review** with the Code Review Agent before merging.
4. **Run the Code Review Agent** (see [`AGENTS.md`](../AGENTS.md)) on the branch diff; address **Request changes** before merge.
5. **Merge** to `main` after review approval (merge commit or squash per preference).

## Merge policy

- Do **not** merge to `main` until the Code Review Agent (or equivalent human review) results in **Approve** for that branch.
- Rebase or merge `main` into the feature branch if `main` has moved, then re-review if the diff is large.

## Related

- [`docs/code-review-agent.md`](code-review-agent.md) — full review checklist and output format
- [`scripts/review-context.sh`](../scripts/review-context.sh) — print diff context for reviews
