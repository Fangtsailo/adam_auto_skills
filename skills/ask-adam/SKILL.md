---
name: ask-adam
description: Catalog menu first, else Wrap ask-matt.
disable-model-invocation: true
---

# Ask Adam

## Workflow

1. **Match** — pick exactly one row in the tables below, or **Wrap**. Two table rows fit → ask **one** question. A table row and a Matt flow fit (e.g. "寫實作計畫") → ask **one** question: the Catalog file, or idea-to-ship via `ask-matt`. Done when one skill is named.
2. **Which-only** — the user only asked which skill → name it. Stop.
3. **Follow** — read that skill's `SKILL.md` and run it to **that** skill's completion criterion. Output shape: `/i-have-adhd`.

**Wrap:** read `.agents/skills/ask-matt/SKILL.md` from the project root and Follow it. That file is upstream. Missing → say so and stop (`npx skills add mattpocock/skills` in this project).

Match only the tables. `architect-first-gate` and `angular-dev-core-rules` / `zyxel-i18n-write` / `angular-developer` fire on their own.

## Documents

Read [CONTEXT.md](CONTEXT.md) **Which document**, then Follow:

| Document | Read |
|---|---|
| 畫面操作說明 | [ui-operation-desc](../ui-operation-desc/SKILL.md) |
| 測試項目 | [test-item](../test-item/SKILL.md) |
| 需求規格（給後端） | [fe-code-to-api-requirement](../fe-code-to-api-requirement/SKILL.md) |
| TD Detail | [td-detail-fillin](../td-detail-fillin/SKILL.md) |

## Git

| Need | Read |
|---|---|
| Commit staged changes | [git-commit](../git-commit/SKILL.md) (it already shows the MR block) |
| MR description only, no commit | [generate-mr-content](../generate-mr-content/SKILL.md) |

## Review

A commit, branch, PR, or diff is this row with no question. Named `code-review` or two-axis Standards + Spec → Wrap.

| Need | Read |
|---|---|
| Review a commit, branch, PR, or diff | [angular-code-review](../angular-code-review/SKILL.md) |

## Plan and ownership

| Need | Read |
|---|---|
| Implementation plan to a markdown file | [write-implementation-plan](../write-implementation-plan/SKILL.md) |
| FE/BE/Shared ownership of a Business Rule | [knowledge-implementation-guideline](../knowledge-implementation-guideline/SKILL.md) |
