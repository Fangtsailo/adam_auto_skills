# Angular Code Review — Reference

Use with `SKILL.md` for PR/MR reviews. Implementation principles live in **`angular-dev-core-rules`** — cite that skill instead of redefining rules here.

## Skill split

| Topic | Skill |
|-------|--------|
| i18n, FP, comments, declarative UI | `angular-dev-core-rules` |
| Checklist severity, output format, TS/style/security/performance gates | `angular-code-review` (this skill) |

## Review gates (from angular-dev-core-rules)

### i18n

- **Critical:** runtime fallback in app code (`instant` with default text, inline English masking missing keys).
- **Critical:** template/service keys with no matching YAML source (or not produced by extract/compile).
- **Not required:** manually editing every `i18n.crowdin/<lang>.json` for each new key — Crowdin + `npm run i18n:build` handles locales; build merges `en-us` for gaps.
- **Suggestions:** untranslated strings surfaced by `npm run i18n:build -- --validate` (or `npm run i18n:validate`) until Crowdin catches up.
- Details: `angular-dev-core-rules` and `apps/gui3/src/i18n/readme.md`.

### Declarative UI & subscriptions

```typescript
// Suggestion: subscribe only to feed the template (see dev-core-rules)
this.userService.getUser().subscribe(user => (this.user = user));

// Preferred for review feedback
readonly user$ = this.store.select(UserState.user);
```

```html
@if (user$ | async; as user) {
    <app-profile [user]="user" />
}
```

### NGXS immutability

```typescript
// Critical: in-place mutation
const state = ctx.getState();
state.items.push(newItem);
ctx.patchState({ items: state.items });

// Preferred
ctx.patchState({ items: [...ctx.getState().items, newItem] });
```

### Comments

Approve purposeful **why** comments; suggest removing noise that restates the code.

## NGXS patterns (team gates)

```typescript
readonly user$ = this.store.select(UserState.user);
```

```typescript
// When subscribe is justified — always teardown
private readonly destroy$ = new Subject<void>();

ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
}
```

Prefer `DestroyRef.onDestroy` when the project already uses it; both satisfy the review gate.

## inject() pattern

```typescript
export class UserService {
    private readonly http = inject(HttpClient);
    private readonly store = inject(Store);
}
```

## Module vs Standalone

Default to Module-based components unless Standalone is explicitly required by the project.

## Style & accessibility (team gates)

- **Suggestions:** import order, Prettier drift, or missing `track` on lists the PR already touches.
- **Suggestions:** new interactive controls without semantic elements or ARIA when a native pattern exists (`button`, `label`, `aria-*`).
- Target repo may define more in `.vscode/code_style_guide.md` and `.prettierrc.yaml`.

## Severity quick reference

| Situation | Severity |
|-----------|----------|
| Missing YAML keys / runtime i18n fallback in app | Critical |
| Crowdin gaps (build validate only) | Suggestions |
| Shared NGXS state mutated in place | Critical |
| New code uses `any` or bypasses NGXS without reason | Critical |
| Subscribe-for-template in touched component | Suggestions |
| Legacy pattern in untouched lines | Omit or note only |
| Formatting / import order | Suggestions |

## Further reading

- [angular-dev-core-rules/reference.md](../angular-dev-core-rules/reference.md) — examples, RxJS error handling, Signals vs store streams, decision guide
