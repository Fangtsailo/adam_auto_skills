---
name: angular-code-review
description: >-
  Review Angular PRs/MRs against team gates and angular-dev-core-rules (i18n,
  FP, declarative UI). Covers NGXS, inject(), TypeScript, style, security, and
  performance. States commit intent first, then reports only the most serious
  concerns. Use when reviewing Angular code or the user asks for a review.
---

# Angular Code Review

## Scope & related skills

- **This skill:** PR/MR checklist, severity (Critical / Suggestions / Positive), output format, and team-wide gates (TypeScript, style, security, performance).
- **`angular-dev-core-rules`:** Source of truth for i18n, functional style, comments, and declarative UI/data flow. Do not duplicate or contradict those rules here — reference them when flagging issues.
- For reviews touching templates, NGXS, RxJS, or translations, apply both skills together.

## Review Checklist

Use **`angular-dev-core-rules`** for the core sections below; use **this skill** for team gates in the following subsections.

**Authoritative source:** bullets under Core dev rules are review shorthand only. If anything conflicts with `angular-dev-core-rules`, follow dev-core.

### Core dev rules (angular-dev-core-rules)

#### i18n (see `angular-dev-core-rules` + `apps/gui3/src/i18n/readme.md`)
- No **runtime** fallback: no `instant` default text, inline English, or hidden locale switch when a key is missing. Build-time `en-us` fill in `translation.build.cjs` is project-standard — do not add a second app-level fallback.
- New UI strings added in the correct **YAML** under `apps/gui3/src/i18n/` (not hand-synced across every `i18n.crowdin/<lang>.json`).
- Extract/build workflow respected (`npm run i18n:extract`, `npm run i18n:build`; use `npm run i18n:build -- --validate` when validating); flag keys used in templates but missing from YAML/extract output.

#### Functional style & state
- Prefer immutability for NGXS/shared state (`patchState` with new collections; avoid in-place mutation of `ctx.getState()`).
- Side effects at service/NGXS/effect boundaries; extract pure transforms when logic is non-trivial or reused.
- RxJS: composed `pipe`; errors handled explicitly — not swallowed without clear UX intent.

#### Declarative UI
- View data via `select` + `async` pipe, template-friendly streams, or documented local Signals — not `subscribe` only to copy into template fields (in **touched** code).
- Component `subscribe` only when imperative (telemetry, legacy APIs, etc.) with `takeUntil` / `DestroyRef` and a brief **why** when non-obvious. Legacy `takeUntil` patterns in untouched lines: note only or omit.
- DOM/`ElementRef`/`Renderer2` as last resort; prefer CDK or project abstractions.

#### Comments
- Comments explain **why**, trade-offs, or edge cases — not restated obvious control flow.

### Architecture & state (team gates)
- Primary state: NGXS + RxJS (`takeUntil`, `async` pipe)
- Local-only Signals are acceptable; do not break existing NGXS patterns
- Prefer component composition over inheritance
- Use `inject()` for dependency injection on new or touched code (avoid constructor injection for new code)

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

## Review approach

1. **Commit intent first** — Before listing findings, read the diff / commit message and explain **what this change is trying to accomplish** (the author's goal, not a file-by-file summary). If intent is unclear from the diff alone, say so briefly.
2. **Most serious concerns only** — After intent, report **only Critical-level issues** (see table below). Do **not** include Suggestions, Positive notes, style nits, or legacy patterns in untouched lines unless the user explicitly asks for a full review.
3. **Nothing critical?** — Say so in one sentence (e.g. "No critical concerns found.") and stop. Do not pad with minor feedback.

Align with dev-core **prefer, not dogma** — do not demand drive-by rewrites outside the PR scope unless the user asks.

## Severity guidance

| Finding | Typical severity |
|---------|------------------|
| Missing YAML i18n keys / runtime locale fallback in app code | Critical |
| Untranslated Crowdin strings (build validate warnings only) | Suggestions unless PR blocks release |
| NGXS in-place mutation of shared state | Critical |
| Unsafe `innerHTML` / XSS risk | Critical |
| `any` or broken NGXS patterns in **new** code | Critical |
| `subscribe` only to feed template fields (no documented reason) | Suggestions (Critical if widespread in touched code) |
| Imperative DOM without documented justification | Suggestions |
| Style / import formatting | Suggestions |
| Legacy patterns in **untouched** lines | Note only or omit |

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

- Review examples and NGXS notes: [reference.md](reference.md)
- i18n, FP, declarative UI depth: [../angular-dev-core-rules/reference.md](../angular-dev-core-rules/reference.md)
