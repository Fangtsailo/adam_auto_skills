---
name: git-commit
description: Commit staged changes with Cocogitto via mise, after showing the MR block and waiting for confirmation.
disable-model-invocation: true
---

# Git Commit (cog via mise)

Commit **staged** changes only, using Cocogitto through mise:

```bash
mise exec -- cog commit <TYPE> "<MESSAGE>" [SCOPE]
```

Do **not** use `./manage git:commit` for execution. That wrapper (and `.cmds/git/commit.sh`) passes unquoted `$@` into `cog commit`, which splits a multi-word `MESSAGE` on spaces (e.g. `unexpected argument 'up' found`). `mise exec -- cog commit` is the reliable path and is what the wrapper intends to run.

## Trigger

Apply when the user asks to commit via this repo's flow, including:

| User prompt | Meaning |
|-------------|---------|
| `commit` | Commit **without** SCOPE |
| `commit 71166` | Commit **with** SCOPE `RM-71166` |
| `commit RM-71166` | Commit **with** SCOPE `RM-71166` |

Also: **產生commit**, **幫我 commit**, **git:commit**, **送出 commit**.

## Hard gates

1. **Staged only** — Source of truth is `git diff --staged`. If nothing is staged, stop and tell the user to stage first (`./manage git:staged` and/or `git add <paths>`). Do not invent a commit from unstaged work.
2. **Confirm before execute** — Never run `mise exec -- cog commit` (or `./manage git:commit` / raw `git commit`) until the user explicitly confirms the proposed command in this turn. Draft → ask → wait → only then execute.
3. **No push** — This skill does not push. Stop after a successful commit unless the user separately asks to push.

## Workflow

Copy and track:

```
Commit Progress:
- [ ] 1. Verify staged changes
- [ ] 2. Resolve TYPE
- [ ] 3. Run generate-mr-content; show full MR block; MESSAGE = Title
- [ ] 4. Resolve SCOPE (from prompt ID, else omit)
- [ ] 5. Show proposed command and wait for confirmation
- [ ] 6. On confirm only: run mise exec -- cog commit ...
```

### 1. Verify staged changes

```bash
git status --short
git diff --staged
```

If staged diff is empty → stop; ask user to stage.

### 2. Resolve TYPE

Read current branch: `git branch --show-current` (or equivalent).

**Infer from branch name prefix** (first path segment before `/`, case-insensitive):

| Branch prefix | TYPE |
|---------------|------|
| `feat`, `feature` | `feat` |
| `fix`, `bugfix`, `hotfix` | `fix` |
| `chore` | `chore` |
| `refactor` | `refactor` |
| `docs` | `docs` |
| `test`, `tests` | `test` |
| `ci` | `ci` |
| `build` | `build` |
| `perf` | `perf` |
| `style` | `style` |
| `revert` | `revert` |

Examples: `feat/71166` → `feat`; `fix/RM-71108` → `fix`; `chore/lefthook_files` → `chore`.

**If uncertain** (no matching prefix, ambiguous name, or staged intent clearly conflicts with the prefix): **ask the user** before continuing. When asking, always list selectable TYPEs:

```
build, chore, ci, docs, feat, fix, perf, refactor, revert, style, test
```

Do not guess a TYPE when uncertain.

### 3. Resolve MESSAGE (and show MR content)

Follow [generate-mr-content](../generate-mr-content/SKILL.md) on the **staged** diff:

1. Draft the full MR block (**Title**, **Root Cause**, **How to Fix**) per that skill.
2. **Always show the user** that full ` ```markdown ` fenced MR block (same copy-paste format as generate-mr-content)—do not hide it or only use Title internally.
3. Set MESSAGE = the **Title** line from that block (do not prepend TYPE; do not include SCOPE in MESSAGE).
4. In the same reply (or immediately after the MR fence), continue with the commit proposal / confirmation from step 5. The MR fence is required every time this skill runs, not only when the user separately asked for MR content.

### 4. Resolve SCOPE

SCOPE comes **only from the user prompt**, not from the branch name.

| User prompt | SCOPE |
|-------------|-------|
| `commit` (no ticket id) | **Omit** |
| `commit 71166` | `RM-71166` |
| `commit RM-71166` / `commit rm-71166` | `RM-71166` |

Rules:

1. If the prompt includes a bare numeric ticket id (e.g. `71166`), compose SCOPE as `RM-<id>` → `RM-71166`.
2. If the prompt already includes `RM-<id>` (any case), normalize to uppercase `RM-<id>`.
3. If the prompt has **no** ticket id (plain `commit` / equivalent), **omit SCOPE**.
4. Do **not** invent SCOPE from the branch name (e.g. do not take `71166` from `feat/71166` unless the user also put that id in the prompt).

### 5. Confirmation (mandatory)

In the same turn as step 3, after the MR markdown fence, show the commit proposal, then **stop and wait**:

```text
Proposed commit:
  TYPE:    <type>
  MESSAGE: <message>   # = Title from the MR block above
  SCOPE:   <scope or (omitted)>

Command:
  mise exec -- cog commit <TYPE> "<MESSAGE>"
  # or with scope:
  mise exec -- cog commit <TYPE> "<MESSAGE>" <SCOPE>

Reply to confirm (e.g. 確認 / yes), or tell me what to change (TYPE / MESSAGE / SCOPE).
```

Reply shape: (1) full generate-mr-content ` ```markdown ` fence, then (2) the proposed commit block above. **Do not execute** until the user confirms.

Allowed after confirmation: adjust TYPE/MESSAGE/SCOPE per user feedback, then confirm again if the command changed; execute only the final confirmed command.

### 6. Execute

On explicit confirmation only:

```bash
mise exec -- cog commit <TYPE> "<MESSAGE>"
# or
mise exec -- cog commit <TYPE> "<MESSAGE>" <SCOPE>
```

Always quote `MESSAGE` for the shell (double quotes). Never route through `./manage git:commit`. Report success/failure from the command output. Do not push.

## Command reference

| Piece | Source |
|-------|--------|
| Entry | `mise exec -- cog commit` (not `./manage git:commit`) |
| TYPE | Branch prefix, else ask (list all cog types) |
| MESSAGE | generate-mr-content **Title** (full MR block always shown to user) |
| SCOPE | From prompt id → `RM-<id>`; omit if prompt has no id |

Valid TYPE values (cog): `build`, `chore`, `ci`, `docs`, `feat`, `fix`, `perf`, `refactor`, `revert`, `style`, `test`.

## Examples

**User: `commit`** — no SCOPE:

```bash
mise exec -- cog commit feat "Split Overview Organization Type and Billing Mode"
```

**User: `commit 71166`** — SCOPE = `RM-71166`:

```bash
mise exec -- cog commit feat "Split Overview Organization Type and Billing Mode" RM-71166
```

**User: `commit RM-71166`** — same SCOPE normalization:

```bash
mise exec -- cog commit feat "Split Overview Organization Type and Billing Mode" RM-71166
```

**Branch `next` or `wip/experiment`:** ask user to pick TYPE from the full list, then continue with MESSAGE/SCOPE/confirm steps.
