---
name: angular-dev-core-rules
description: >-
  Guides Angular implementation toward project i18n (YAML/Crowdin), functional
  programming, declarative UI/data flow, and purposeful comments. Use when
  building or refactoring Angular/NGXS/RxJS components, services, or state
  logic. For PR review checklists, use angular-code-review instead.
---

# Angular Dev Core Rules

## Scope & related skills

- **This skill:** implementation direction while writing or refactoring code.
- **`angular-code-review`:** PR/MR review checklist, output format, style/security/performance gates.
- Apply only in the Angular domain. Prefer existing project patterns when they already satisfy these principles.

## 1. i18n (YAML → Crowdin; no runtime fallback)

- **Source of truth:** add English strings in `apps/gui3/src/i18n/**/*.yml`. Follow folder rules in `apps/gui3/src/i18n/readme.md` (`$`, `$$`, per-module paths). Do not hand-edit every `i18n.crowdin/<lang>.json` for new keys.
- **Workflow:** after YAML changes, run `npm run i18n:extract`; translations go through Crowdin → `apps/gui3/src/i18n.crowdin/<lang>.json`; assets are built via `npm run i18n:build` (use `--validate` in CI/pre-commit when applicable).
- **Runtime:** do not add app-level fallback when a key is missing (`translateService.instant` with default text, inline English in templates, or a hidden locale switch). Let `@ngx-translate` show the key or the project’s missing-key behavior.
- **Build pipeline (project standard):** `tools/i18n/translation.build.cjs` fills missing Crowdin strings from `en-us`. That is not a license to skip YAML keys or mask defects — treat `npm run i18n:build -- --validate` (or `npm run i18n:validate`) warnings on untranslated strings as defects to fix via Crowdin, not as something to paper over in component code.
- Reuse existing key prefixes (`NUB.*`, `COMMON.*`, etc.) and `| translate` / project translate helpers.

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
- **Component `subscribe`:** avoid subscribing only to copy values into template fields. If subscription is needed (imperative side effect, third-party API), use `takeUntil` / `DestroyRef` and document why `async` pipe is not enough. Many NUBs still use `takeUntil` subscriptions — improve **touched** code only; no drive-by rewrites unless asked.
- **DOM APIs (`ElementRef`, `Renderer2`, native DOM):** last resort when template/state cannot express the requirement (e.g. focus management, legacy widget). Prefer CDK or project abstractions when available.
- **Control flow:** prefer `@if` / `@for` with `track` over legacy `*ngFor` where you are already editing the template.

## Additional resources

- Patterns, NGXS notes, and examples: [reference.md](reference.md)
- i18n structure and build flow: `apps/gui3/src/i18n/readme.md`
