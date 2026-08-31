---
name: angular-code-review
description: >-
  Review Angular PRs/MRs against team gates, angular-dev-core-rules (FP,
  declarative UI), and zyxel-i18n-write (string write path). Covers NGXS,
  inject(), TypeScript, style, security, and performance. States commit intent
  first, then reports only the most serious concerns. Use when reviewing
  Angular code or the user asks for a review.
---

# Angular Code Review

## Scope

This skill owns the review **steps**, **severity**, **output format**, and **team gates** below.

Read the matching skill when the diff hits that branch.

| Diff touches | Read |
|---|---|
| User-visible strings | [zyxel-i18n-write](../zyxel-i18n-write/SKILL.md) |
| NGXS, RxJS, subscriptions, template binding, comments, i18n runtime | [angular-dev-core-rules](../angular-dev-core-rules/SKILL.md) |
| Angular API shape (Signals, Forms, Routing, DI mechanics) | [angular-developer](../angular-developer/SKILL.md); team gates in this skill still win |

String write path: **zyxel-i18n-write**. Implementation direction: **angular-dev-core-rules**.

## Review approach

1. **Commit intent first** — Before listing findings, read the diff / commit message and explain **what this change is trying to accomplish** (the author's goal, not a file-by-file summary). If intent is unclear from the diff alone, say so briefly.
2. **Most serious concerns only** — After intent, report **only Critical-level issues** (see table below). Do **not** include Suggestions, Positive notes, style nits, or legacy patterns in untouched lines unless the user explicitly asks for a full review.
3. **Nothing critical?** — Say so in one sentence (e.g. "No critical concerns found.") and stop. Do not pad with minor feedback.

Align with angular-dev-core-rules **prefer, not dogma** — do not demand drive-by rewrites outside the PR scope unless the user asks.

## Team gates

### Architecture & state

- Primary store is NGXS; local Signals must not replace it. Details: `angular-dev-core-rules`.
- Prefer component composition over inheritance.
- Use `inject()` on new or touched code (see [reference.md](reference.md)).

### TypeScript

- Strict typing; no `any`
- Use interfaces for all data models
- Optional chaining (`?.`) and nullish coalescing (`??`)

### Performance

- `track` in `@for` / `trackBy` for `*ngFor`
- Consider `NgOptimizedImage` for images
- Use `@defer` for non-critical views

### Security

- No unsafe `innerHTML`; rely on Angular sanitization
- Validate user input at boundaries

### Style & structure

- File naming: kebab-case with suffixes (e.g. `user.component.ts`)
- Imports sorted per `@ianvs/prettier-plugin-sort-imports`; follow `.vscode/code_style_guide.md` when present in the target repo
- 4-space indent, 120 char width (`.prettierrc.yaml`); single quotes (TS/JS), double quotes (SASS/SCSS)
- Semantic HTML and ARIA for new or changed interactive UI
- Default to Module-based components unless Standalone is required by the project

## Severity guidance

| Finding | Typical severity |
|---------|------------------|
| Missing YAML i18n keys (non-Dedupe) / runtime locale fallback in app code | Critical |
| Dedupe Term added as YAML, or stale Crowdin text left on a changed YAML key | Critical |
| Untranslated Crowdin strings (build validate warnings only) | Suggestions unless PR blocks release |
| NGXS in-place mutation of shared state | Critical |
| Unsafe `innerHTML` / XSS risk | Critical |
| `any` or broken NGXS patterns in **new** code | Critical |
| `subscribe` only to feed template fields (no documented reason) | Suggestions (Critical if widespread in touched code) |
| Imperative DOM without documented justification | Suggestions |
| Style / import formatting | Suggestions |
| Legacy patterns in **untouched** lines | Note only or omit |

**Not a finding:** Crowdin JSON edits required by zyxel-i18n-write Rule 2. Do not require `npm run i18n:extract` in the PR.

## Output Format

Keep the response short. Use Traditional Chinese for prose; file paths and code references stay as in the repo.

```markdown
# Angular Code Review

## Commit 意圖
[1–3 sentences: what the author is trying to achieve with this change]

## 最嚴重疑慮
- [ ] Issue with file:line reference and brief rationale (only if Critical)

若無 Critical 問題：「未發現嚴重疑慮。」
```

Do **not** output Suggestions or Positive sections unless the user asks for a full review.

## Additional resources

- Team-gate examples (`inject()`): [reference.md](reference.md)
- Implementation examples: [../angular-dev-core-rules/reference.md](../angular-dev-core-rules/reference.md)
