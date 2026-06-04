---
name: angular-dev-core-rules
description: >-
  Guides Angular implementation toward strict i18n, functional programming,
  declarative UI/data flow, and purposeful comments. Use when building or
  refactoring Angular/NGXS/RxJS components, services, or state logic. For PR
  review checklists, use angular-code-review instead.
---

# Angular Dev Core Rules

## Scope & related skills

- **This skill:** implementation direction while writing or refactoring code.
- **`angular-code-review`:** PR/MR review checklist, output format, style/security/performance gates.
- Apply only in the Angular domain. Prefer existing project patterns when they already satisfy these principles.

## 1. i18n (strict, no silent fallback)

- **Default:** no runtime fallback to another locale or hard-coded default string when a key is missing.
- Missing keys should surface as errors, raw keys, or an explicit project-defined missing-key handler — not a hidden language switch.
- When adding keys, keep locale files aligned (same key paths across supported locales).
- Match the project's i18n API (pipe, service, or loader); the rule is **behavior**, not a specific helper name.

## 2. Functional programming (prefer, not dogma)

- **Prefer** pure functions for data transformation; keep side effects at boundaries (services, NGXS actions, effects).
- **Prefer** immutability: return new arrays/objects (`map`, spread, `patchState`) instead of in-place mutation, especially for shared or store state.
- **Prefer** RxJS `pipe` composition for async flows; choose operators by intent (`switchMap` for switchable deps, `concatMap` when order matters).
- Imperative code is acceptable when it is clearer or matches existing module patterns — keep it localized and easy to test.

## 3. Comments (purposeful, not noisy)

- Code should stay self-explanatory via naming; comments add value for **why**, trade-offs, edge cases, and extension points.
- Do not restate obvious control flow. Avoid comment clutter on every member.

## 4. Declarative UI & data binding

- **Default:** describe *what* the UI should show from state, not step-by-step DOM manipulation.
- **Template binding:** prefer `async` pipe or template-friendly Signals for view data; NGXS store streams typically use `select` + `async` pipe.
- **Component `subscribe`:** avoid subscribing only to copy values into template fields. If subscription is needed (imperative side effect, third-party API), use `takeUntil` / `DestroyRef` and document why `async` pipe is not enough.
- **DOM APIs (`ElementRef`, `Renderer2`, native DOM):** last resort when template/state cannot express the requirement (e.g. focus management, legacy widget). Prefer CDK or project abstractions when available.
- **Control flow:** prefer `@if` / `@for` (or existing structural directives) and declarative collection transforms over manual index loops where readability allows.

## Additional resources

- Patterns, NGXS notes, and examples: [reference.md](reference.md)
