---
name: ask-adam
description: Router: Catalog menu first, else Wrap ask-matt.
disable-model-invocation: true
---

# Ask Adam

You don't remember every skill, so ask.

**Menu-first.** Match one row in the tables below. No table matches → **Wrap** `ask-matt`: read `.agents/skills/ask-matt/SKILL.md` from the project root and follow it to **that** skill's completion criterion. Do not edit `ask-matt`. Do not ask the user to type another `/` name when the match is clear.

A Catalog row and a Matt flow could both fit (e.g. "寫實作計畫") → ask **one** question: the Catalog markdown template, or idea-to-ship via `ask-matt`.

If Wrap is chosen and `.agents/skills/ask-matt/SKILL.md` is missing, say so and stop. The fix is `npx skills add mattpocock/skills` in this project.

## Workflow

1. **Match** — pick exactly one Catalog row, or Wrap. Two Catalog rows could fit → ask **one** question. Done when one skill is named (Catalog or `ask-matt`).
2. **Which-only** — if the user only asked which skill to use, name it and stop.
3. **Follow** — read that skill's `SKILL.md` and run it to **that** skill's completion criterion.

## Documents

Handoff documents (畫面操作說明 / 測試項目 / 需求規格（給後端） / TD Detail): read [CONTEXT.md](CONTEXT.md) **Which document**, then follow:

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

## Plan and ownership

| Need | Read |
|---|---|
| Implementation plan to a markdown file | [write-implementation-plan](../write-implementation-plan/SKILL.md) |
| FE/BE/Shared ownership of a Business Rule | [knowledge-implementation-guideline](../knowledge-implementation-guideline/SKILL.md) |

## Not this router

These fire on their own. Do not Match them here:

- `architect-first-gate` — before writing application code
- `angular-dev-core-rules` / `zyxel-i18n-write` / `angular-code-review` / `angular-developer` — while coding or reviewing Angular

Output shape: `/i-have-adhd`.
