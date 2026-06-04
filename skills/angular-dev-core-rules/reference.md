# Angular Dev Core Rules — Reference

Use when the task needs examples or trade-off guidance beyond `SKILL.md`.

## 1. i18n (strict mode)

### Principles

- Do not add silent default-language fallback in app code or i18n config unless the project already standardizes it globally.
- Treat missing translations as visible defects during development, not as something to mask in production.
- Add keys to all supported locale files before wiring templates/services.

### Checks

- CI or build-time missing-key detection when the project supports it.
- Same key tree structure across locale JSON/files.

### Examples (API-agnostic)

```html
<!-- Prefer explicit keys; avoid inline fallback copy in templates -->
<span>{{ 'user.profile.title' | translate }}</span>
```

```ts
// Avoid: third argument or option that supplies English when key is missing
// Prefer: let the project's translate layer expose the missing key or error
const title = translateService.instant('user.profile.title');
```

## 2. Functional programming

### Pure functions

Extract non-trivial mapping/filtering into named pure functions when it improves tests and reuse.

```ts
interface User {
    id: string;
    isActive: boolean;
}

const filterActiveUsers = (users: ReadonlyArray<User>): ReadonlyArray<User> =>
    users.filter(user => user.isActive);
```

### Immutability

| Context | Guidance |
|---------|----------|
| Local variables | Spread / `map` / `filter` as default |
| NGXS state | Use `patchState`, `setState`, or immutable operators — avoid mutating `ctx.getState()` in place |
| Performance hot paths | Pragmatic mutation is OK if documented and scoped (e.g. internal buffer) |

```ts
// NGXS-friendly
ctx.patchState({
    items: [...ctx.getState().items, newItem],
});
```

### RxJS

- Compose with `pipe`; keep subscriptions thin in components.
- Handle errors explicitly: log, map to error state, rethrow, or use `EMPTY` — avoid swallowing errors with `of(null)` unless the UI truly treats "no data" and "failed" the same way.

```ts
readonly user$ = this.route.params.pipe(
    map(params => params['id']),
    switchMap(id => this.userService.getUser(id)),
    catchError(err => {
        console.error(err);
        return of({ error: true } as const);
    })
);
```

## 3. Comments

```ts
// Why: debounce rapid queryParam churn before hitting the list API.
// Trade-off: 300ms delay is acceptable for filter UX; tighten if SEO pages need instant URL reflect.
const filters$ = this.route.queryParams.pipe(
    debounceTime(300),
    map(params => normalizeFilters(params))
);
```

## 4. Declarative UI

### State → template (preferred)

```ts
readonly items$ = this.store.select(ItemsState.items);
```

```html
@if (items$ | async; as items) {
    @for (item of items; track item.id) {
        <app-item [item]="item" />
    }
}
```

### Signals vs store streams

| Source | Typical approach |
|--------|------------------|
| NGXS / shared store | `select` + `async` pipe (or project store helpers) |
| Local UI-only state | `signal` / `computed` in the component |
| Mixed | Do not duplicate store data into signals without a clear reason |

### When `subscribe` in a component is reasonable

- One-off imperative integration (analytics, legacy callback) with proper teardown.
- Coordinating multiple streams where a small facade method is clearer than template syntax.
- Always pair with `takeUntil(destroy$)` or `DestroyRef.onDestroy`.

```ts
// Prefer for view data
readonly user$ = this.userService.getUser(id);

// Acceptable when imperative side effect is required
this.actions$.pipe(takeUntil(this.destroy$)).subscribe(action => this.telemetry.track(action));
```

### DOM / Renderer

Default: state + template bindings. If DOM access is required, isolate in a directive or small helper and document **Why** template-only approaches were insufficient.

## Decision guide

| Situation | Suggestion |
|-----------|------------|
| Transform + side effect in one method | Split pure transform from effect |
| Logic reused across components | Move to service or NGXS |
| PR review / security / style gates | Apply `angular-code-review` |
| Existing file uses older patterns | Improve touched code; avoid drive-by rewrites unless asked |

## Quick contrasts

```ts
// Weaker: subscribe only to feed the template
this.userService.getUser().subscribe(user => (this.user = user));

// Stronger: stream for template
readonly user$ = this.userService.getUser(id);
```

```ts
// Weaker: in-place NGXS mutation
const state = ctx.getState();
state.items.push(newItem);
ctx.patchState({ items: state.items });

// Stronger: new collection
ctx.patchState({ items: [...ctx.getState().items, newItem] });
```
