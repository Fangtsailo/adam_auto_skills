---
name: angular-code-review
description: >-
  Review Angular PRs/MRs against team gates and angular-dev-core-rules (i18n,
  FP, declarative UI). Covers NGXS, inject(), TypeScript, style, security, and
  performance. Use when reviewing Angular code or the user asks for a review.
---

# Angular Code Review

## Scope & related skills

- **This skill:** PR/MR checklist, severity (Critical / Suggestions / Positive), output format, and team-wide gates (TypeScript, style, security, performance).
- **`angular-dev-core-rules`:** Source of truth for i18n, functional style, comments, and declarative UI/data flow. Do not duplicate or contradict those rules here — reference them when flagging issues.
- For reviews touching templates, NGXS, RxJS, or translations, apply both skills together.

## Review Checklist

Use **`angular-dev-core-rules`** for the core sections below; use **this skill** for team gates in the following subsections.

### Core dev rules (angular-dev-core-rules)

#### i18n
- No silent fallback to another locale or hard-coded default when a key is missing (unless the project standardizes it globally).
- New keys added across all supported locale files with aligned key paths.
- No inline fallback copy in templates/services that masks missing keys.

#### Functional style & state
- Prefer immutability for NGXS/shared state (`patchState` with new collections; avoid in-place mutation of `ctx.getState()`).
- Side effects at service/NGXS/effect boundaries; extract pure transforms when logic is non-trivial or reused.
- RxJS: composed `pipe`; errors handled explicitly — not swallowed without clear UX intent.

#### Declarative UI
- View data via `select` + `async` pipe, template-friendly streams, or documented local Signals — not `subscribe` only to copy into template fields.
- Component `subscribe` only when imperative (telemetry, legacy APIs, etc.) with `takeUntil` / `DestroyRef` and a brief **why** when non-obvious.
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
- Imports sorted per `@ianvs/prettier-plugin-sort-imports`
- 4-space indent, 120 char width, single quotes (TS/JS)
- Default to Module-based components unless Standalone is required by the project

## Severity guidance

Align with dev-core **prefer, not dogma** — do not demand drive-by rewrites outside the PR scope unless the user asks.

| Finding | Typical severity |
|---------|------------------|
| Missing i18n keys / silent locale fallback | Critical |
| NGXS in-place mutation of shared state | Critical |
| Unsafe `innerHTML` / XSS risk | Critical |
| `any` or broken NGXS patterns in **new** code | Critical |
| `subscribe` only to feed template fields (no documented reason) | Suggestions (Critical if widespread in touched code) |
| Imperative DOM without documented justification | Suggestions |
| Style / import formatting | Suggestions |
| Legacy patterns in **untouched** lines | Note only or omit |

## Output Format

```markdown
# Angular Code Review

## Summary
[One-paragraph overview]

## Critical
- [ ] Issue with file:line reference

## Suggestions
- [ ] Improvement with rationale (reference angular-dev-core-rules when applicable)

## Positive
- What was done well
```

## Additional resources

- Review examples and NGXS notes: [reference.md](reference.md)
- i18n, FP, declarative UI depth: [../angular-dev-core-rules/reference.md](../angular-dev-core-rules/reference.md)
