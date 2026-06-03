# Angular Code Review — Reference

## NGXS Patterns

```typescript
// Prefer selectors over direct state access
readonly user$ = this.store.select(UserState.user);

// Unsubscribe with takeUntil
private readonly destroy$ = new Subject<void>();

ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
}
```

## inject() Pattern

```typescript
export class UserService {
    private readonly http = inject(HttpClient);
    private readonly store = inject(Store);
}
```

## Module vs Standalone

Default to Module-based components unless Standalone is explicitly required by the project.
