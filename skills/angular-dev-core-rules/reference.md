# Angular Dev Core Rules — Reference

Use when the task needs examples or trade-off guidance beyond `SKILL.md`.

## 1. i18n (project: YAML → Crowdin → assets)

### Principles

| Layer | Rule |
|-------|------|
| **Authoring** | English-only YAML under `apps/gui3/src/i18n/`. Place files per `readme.md` (module folders, `$nub` / `$$nub` / `$$nui` merge rules). |
| **Runtime (app)** | No silent fallback in templates or TS — no `instant(key, 'English')`, no inline default copy when a key is missing. |
| **Build** | Missing Crowdin translations are merged from `en-us` in `translation.build.cjs`. Do not duplicate that with extra app-level fallback. |
| **Quality** | Untranslated strings reported by `npm run i18n:build --validate` (or `i18n:validate`) are defects; fix via YAML + Crowdin, not component hacks. |

### Workflow

1. Add or change keys in the correct YAML file(s).
2. `npm run i18n:extract` — updates Crowdin source (`i18n.crowdin/en-us.json`).
3. Translations completed on Crowdin → download to `apps/gui3/src/i18n.crowdin/<lang>.json`.
4. `npm run i18n:build` — per-module JSON under `src/assets/i18n/**/`; Angular loads via `NebulaTranslateLoader` + `@ngx-translate/core`.

### Checks

- New template/service keys exist in YAML (and survive extract/compile), not manually duplicated across every locale JSON.
- Key naming matches existing conventions (`NUB.SwitchStackManagementDetail.TITLE`, `COMMON.Button.Delete`, etc.).
- Interpolation uses `{{0}}` style per `translation.validate.cjs` (see i18n readme).

### Examples

```html
<!-- Prefer explicit keys; no inline English fallback -->
<span>{{ 'NUB.SwitchStackManagementDetail.TITLE' | translate }}</span>
```

```ts
// Avoid: default text when key is missing
const title = translateService.instant('NUB.SomeBlock.TITLE', 'Default title');

// Prefer: rely on translate layer + built locale JSON
const title = translateService.instant('NUB.SomeBlock.TITLE');
```

```yaml
# apps/gui3/src/i18n/.../example.yml (English source)
MESSAGE: Operation completed
TableHeader: Clients
```

### Build-time vs runtime fallback

```text
OK (build):  translatedDict[key] || en-us text  →  assets/i18n/<lang>/<module>.json
Not OK (app): template "{{ key | translate }}" plus hard-coded English if translate returns key
Not OK (app): instant(key, 'English fallback') in component code
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
        return of({error: true} as const);
    }),
);
```

## 3. Comments

```ts
// Why: debounce rapid queryParam churn before hitting the list API.
// Trade-off: 300ms delay is acceptable for filter UX; tighten if SEO pages need instant URL reflect.
const filters$ = this.route.queryParams.pipe(
    debounceTime(300),
    map(params => normalizeFilters(params)),
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
- Existing NUB/page patterns that already use `takeUntil` — align **touched** code with dev-core rules; leave untouched legacy as-is unless the user requests a refactor.
- Always pair with `takeUntil(destroy$)` or `DestroyRef.onDestroy` (both are used in this repo).

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
| New UI string | Add YAML key in correct `i18n/` path; run extract; do not edit all locale JSONs by hand |
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
ctx.patchState({items: state.items});

// Stronger: new collection
ctx.patchState({items: [...ctx.getState().items, newItem]});
```
