# Implementation Plan Template — Detailed Mode

Use for **詳盡模式** (ready to implement). Split work with **PR** only—never Phase.

Copy and adapt when writing a plan. Replace placeholders; remove sections marked optional if not needed.

```markdown
# <Feature or requirement title>

## Requirement

### Summary
<What is being built and why, in one paragraph.>

### Goals
- <Measurable outcome 1>
- <Measurable outcome 2>

### Out of scope
- <Explicitly excluded item, or "None for this iteration.">

### Assumptions / dependencies
- <Prerequisite, external API, or team dependency, or "None.">

### Flow overview (recommended — use mermaid)

<One-line caption describing the diagram.>

```mermaid
flowchart TD
    A[<Actor or entry point>] --> B[<Step or component>]
    B --> C[<Outcome>]
```

## Implementation PRs

### PR overview (recommended — use mermaid when multiple PRs)

<One-line caption describing merge order and dependencies.>

```mermaid
flowchart LR
    R1[PR 1: <title>] --> R2[PR 2: <title>]
    R2 --> R3[PR 3: <title>]
```

### PR 1: <short title>

#### Scope
- <Deliverable and boundaries>
- <Files or areas: `path/to/module`, `path/to/component`>
- <Merge dependency: none / requires PR N merged first>

#### Implementation
1. <Step with approach and key changes>
2. <Step referencing existing patterns or modules>
3. <Step>

#### Verification
- [ ] <Command, test, or manual check>
- [ ] <Observable outcome>
- [ ] <PR is reviewable size; CI green>

### PR 2: <short title>

#### Scope
...

#### Implementation
1. ...

#### Verification
- [ ] ...

<!-- Repeat PR N as needed -->

## Risks and mitigations (optional)

| Risk | Mitigation |
|------|------------|
| <risk> | <mitigation> |

## Open questions (optional)

- <Unresolved decision or stakeholder input needed>
```

## Minimal example (small change)

```markdown
# Add discount badge to product card

## Requirement

### Summary
Show an active discount percentage on the product card when a promotion applies, so shoppers see savings without opening the detail page.

### Goals
- Badge visible when `product.discountPercent > 0`
- No extra API call on the listing page

### Out of scope
- Cart-level coupons; checkout discount summary

### Assumptions / dependencies
- `ProductDto` already includes `discountPercent` from the listing API

### Flow overview

Data path from API to badge on the listing card:

```mermaid
flowchart LR
    API[Listing API] --> DTO[ProductDto.discountPercent]
    DTO --> Card[ProductCardComponent]
    Card -->|> 0| Badge[Discount badge + i18n aria-label]
    Card -->|otherwise| Hidden[No badge]
```

## Implementation PRs

### PR overview

Stacked UI-first delivery; state PR only if DTO is insufficient:

```mermaid
flowchart LR
    R1[PR 1: UI and i18n] --> R2[PR 2: NGXS selector]
    R2 -.optional.-> R1
```

### PR 1: UI and i18n

#### Scope
- `product-card.component` template and styles only
- `apps/gui3/src/i18n/en.yaml`, `zh-TW.yaml` under `product.card.*`
- Reuse existing `NgOptimizedImage`; no NGXS changes in this PR

#### Implementation
1. Add `@if (product.discountPercent > 0)` badge in template with `aria-label` from i18n
2. Add `product.card.discount-badge` key to `en.yaml` and `zh-TW.yaml`
3. Style badge per design tokens in `_product-card.scss`

#### Verification
- [ ] `npm run test -- product-card` passes
- [ ] Manual: listing page shows badge only for discounted products
- [ ] Screen reader announces discount via `aria-label`

### PR 2: NGXS selector (if needed)

#### Scope
- `product.state.ts` and related selectors only
- Requires PR 1 merged; skip entire PR if DTO binding in PR 1 is sufficient

#### Implementation
1. Add selector for effective discount percent with null/0 edge cases
2. Wire `ProductCardComponent` to selector only if template cannot use DTO directly

#### Verification
- [ ] Unit tests for selector edge cases (0%, null)
- [ ] No duplicate API calls introduced
```

## Mermaid quick reference

| Scenario | Diagram type | Example snippet |
|----------|--------------|-----------------|
| API / UI sequence | `sequenceDiagram` | `User->>Component: action` |
| Component data flow | `flowchart` | `A --> B` |
| NGXS / state transitions | `stateDiagram-v2` | `[*] --> Idle` |
| DB tables / relations | `erDiagram` | `USER ||--o{ ORDER : places` |
| PR merge order | `flowchart` | `R1[PR 1] --> R2[PR 2]` with `R2 -.depends on.-> R1` |

Prefer **mermaid** over ASCII art or bullet-only prose when the reader needs to grasp structure at a glance.
