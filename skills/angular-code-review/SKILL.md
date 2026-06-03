---
name: angular-code-review
description: >-
  Review Angular code for NGXS patterns, inject() usage, strict TypeScript,
  and team coding standards. Use when reviewing Angular PRs, components,
  services, or when the user asks for an Angular code review.
---

# Angular Code Review

## Review Checklist

### Architecture & State
- State management uses NGXS + RxJS (`takeUntil`, `async` pipe)
- Local-only Signals are acceptable; do not break existing NGXS patterns
- Prefer component composition over inheritance
- Use `inject()` for dependency injection (no constructor injection for new code)

### TypeScript
- Strict typing; no `any`
- Use interfaces for all data models
- Optional chaining (`?.`) and nullish coalescing (`??`)

### Performance
- `trackBy` for `*ngFor` / `@for`
- Consider `NgOptimizedImage` for images
- Use `@defer` for non-critical views

### Security
- No unsafe `innerHTML`; rely on Angular sanitization
- Validate user input at boundaries

### Style & Structure
- File naming: kebab-case with suffixes (e.g. `user.component.ts`)
- Imports sorted per `@ianvs/prettier-plugin-sort-imports`
- 4-space indent, 120 char width, single quotes (TS/JS)

## Output Format

```markdown
# Angular Code Review

## Summary
[One-paragraph overview]

## Critical
- [ ] Issue with file:line reference

## Suggestions
- [ ] Improvement with rationale

## Positive
- What was done well
```

## Additional Resources

- For detailed NGXS patterns, see [reference.md](reference.md)
