---
name: generate-mr-content
description: >-
  Generate merge request / MR description content in a fixed markdown template
  (Title, Root Cause, How to Fix). Use when the user asks for MR content, merge
  request description, MR title and summary, or mentions generate-mr-content.
---

# Generate MR Content

Produce merge request description content from the user's context (bug report, diff, discussion, or stated problem).

## Workflow

1. Gather context: what broke, symptoms, affected area, and the fix (or proposed fix).
2. If code/diff is available, read enough to state the real cause—not symptoms only.
3. Draft all three sections in the exact format below.
4. Verify **Title** length ≤ 80 characters (count letters only; spaces and punctuation count).

## Output Format

Return **only** this markdown structure—no preamble, no extra sections:

```markdown
### Title
<single line, max 80 characters>

### Root Cause
<concise bullets or 1–2 short sentences; key facts only>

### How to Fix
<concise bullets or 1–2 short sentences; actionable fix steps>
```

## Section Rules

| Section | Rules |
|---------|--------|
| **Title** | One line; ≤ 80 characters; states what the MR does (fix/feature), not file names; imperative or past tense as team prefers |
| **Root Cause** | Why it failed; 1–3 bullets or ≤ 2 sentences; no stack traces unless essential |
| **How to Fix** | What changed or should change; 1–3 bullets or ≤ 2 sentences; concrete actions |

## Quality

- **Title**: Specific (e.g. `Fix cart duplicate items on rapid add` not `Bug fix`).
- **Root Cause**: Underlying mechanism, not only user-visible symptom.
- **How to Fix**: Maps to the cause; mention tests or config only if relevant.
- Omit filler (`please`, `we should consider`, long background).
- If context is insufficient, ask one focused question—otherwise infer from available evidence.

## Example

**Input:** Checkout fails when user applies two coupons; race on `applyDiscount`.

**Output:**

```markdown
### Title
Fix duplicate coupon application race in checkout

### Root Cause
- `applyDiscount` had no guard when two requests ran concurrently
- Second request read stale cart state before the first write completed

### How to Fix
- Add idempotent lock per cart session during discount application
- Reject second coupon with clear error if one is already applied
```
