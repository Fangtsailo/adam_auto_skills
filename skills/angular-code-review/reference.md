# Angular Code Review — Reference

Examples for **team gates** in `SKILL.md` only.

Implementation rules and NGXS / subscribe / i18n examples live in [angular-dev-core-rules/reference.md](../angular-dev-core-rules/reference.md). String write path: [zyxel-i18n-write](../zyxel-i18n-write/SKILL.md).

## inject()

```typescript
export class UserService {
    private readonly http = inject(HttpClient);
    private readonly store = inject(Store);
}
```
