# Angular Code Review — Reference

Use with `SKILL.md` for PR/MR reviews. Implementation principles live in **`angular-dev-core-rules`** — cite that skill instead of redefining rules here.

## Skill split

| Topic | Skill |
|-------|--------|
| i18n, FP, comments, declarative UI | `angular-dev-core-rules` |
| Checklist severity, output format, TS/style/security/performance gates | `angular-code-review` (this skill) |

## Review gates (from angular-dev-core-rules)

### i18n

- Flag silent default-language fallback in app code unless project-wide standard.
- Flag new template/service keys missing from any supported locale file.
- Flag inline English (or other) fallback strings masking missing keys.

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

## Severity quick reference

| Situation | Severity |
|-----------|----------|
| Missing keys / silent i18n fallback | Critical |
| Shared NGXS state mutated in place | Critical |
| New code uses `any` or bypasses NGXS without reason | Critical |
| Subscribe-for-template in touched component | Suggestions |
| Legacy pattern in untouched lines | Omit or note only |
| Formatting / import order | Suggestions |

## Further reading

- [angular-dev-core-rules/reference.md](../angular-dev-core-rules/reference.md) — examples, RxJS error handling, Signals vs store streams, decision guide
