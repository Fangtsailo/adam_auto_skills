---
name: git-commit-helper
description: >-
  Generate descriptive git commit messages by analyzing staged changes and
  diffs. Use when the user asks for help writing commit messages, reviewing
  staged changes, or preparing a commit.
---

# Git Commit Helper

## Workflow

1. Run `git status` to see untracked and modified files
2. Run `git diff` for unstaged changes; `git diff --staged` for staged changes
3. Analyze the nature of changes (feature, fix, refactor, test, docs)
4. Draft a concise 1–2 sentence message focused on **why**, not just **what**

## Commit Message Format

```
<type>(<scope>): <subject>

[optional body]
```

**Types:** `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `style`, `perf`

**Examples:**

```
feat(auth): add OAuth2 login flow

fix(cart): prevent duplicate items on rapid click

refactor(user-service): extract validation into pure functions
```

## Safety Rules

- Never commit files likely containing secrets (`.env`, credentials)
- Do not use `--no-verify` unless explicitly requested
- Do not amend unless the user explicitly requests it and conditions are met
- Focus the subject on intent and impact, not file names

## Output

Provide:
1. Recommended commit message (ready to copy)
2. Brief rationale (1 sentence)
3. Files included in the commit
