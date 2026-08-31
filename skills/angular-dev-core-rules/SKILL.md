---
name: angular-dev-core-rules
description: >-
  Guides Angular implementation toward functional programming, declarative
  UI/data flow, purposeful comments, and i18n runtime rules. String write path
  is zyxel-i18n-write. Use when building or refactoring Angular/NGXS/RxJS
  components, services, or state logic. For PR review checklists, use
  angular-code-review instead.
---

# Angular Dev Core Rules

## Scope & related skills

- **This skill:** implementation direction while writing or refactoring code.
- **`angular-developer`:** Official Angular conventions (Signals, Forms, Routing, DI, testing, CLI). Read its `references/` for deep guidance on framework APIs.
- **`zyxel-i18n-write`:** Authoritative write path for user-visible strings (Dedupe / Crowdin reuse / YAML-only).
- **`angular-code-review`:** PR/MR review checklist, output format, style/security/performance gates.
- **Precedence:** When this skill conflicts with `angular-developer`, follow **this skill** (NGXS, project structure). When this skill conflicts with `zyxel-i18n-write` on how to write strings, follow **`zyxel-i18n-write`**.
- **Build verification:** NX monorepos use `nx build <project>` instead of `ng build`.
- Apply only in the Angular domain. Prefer existing project patterns when they already satisfy these principles.

## 1. i18n (write path: `zyxel-i18n-write`; no runtime fallback)

- **Write path:** follow `zyxel-i18n-write` whenever adding or changing user-visible strings. YAML folder rules stay in `apps/gui3/src/i18n/readme.md` (`$`, `$$`, per-module paths).
- **Do not** restate Dedupe / Crowdin-reuse / YAML-only steps here. Do not require `npm run i18n:extract` during implementation.
- **Runtime:** do not add app-level fallback when a key is missing (`translateService.instant` with default text, inline English in templates, or a hidden locale switch). Let `@ngx-translate` show the key or the project’s missing-key behavior.
- **Build pipeline (project standard):** `tools/i18n/translation.build.cjs` fills missing Crowdin strings from `en-us`. That is not a license to skip YAML keys (for non-Dedupe strings) or mask defects — treat `npm run i18n:build -- --validate` (or `npm run i18n:validate`) warnings on untranslated strings as defects to fix via Crowdin, not as something to paper over in component code.
- YAML-backed strings use existing key prefixes (`NUB.*`, `COMMON.*`, etc.) and `| translate` / project translate helpers. Dedupe Terms bind `I18N_DEDUPE_TERMS.*` with no `| translate`.

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
- String write path: `../zyxel-i18n-write/SKILL.md`
- i18n structure and build flow: `apps/gui3/src/i18n/readme.md`
