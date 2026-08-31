---
name: generate-mr-content
description: Generate an English MR description (Title, Root Cause, How to Fix) from git staged changes.
disable-model-invocation: true
---

# Generate MR Content

Produce MR description content **only** from the current git **staged** diff.

## Trigger

Apply this skill when the user says **產生MR內容** (or clearly equivalent wording, e.g.「產生 MR 內容」).

## Workflow

1. Run `git diff --staged` (and `git status --short` if helpful for file context).
2. Use **only** staged changes as the source of truth—ignore unstaged changes, prior chat, and assumptions not supported by the staged diff.
3. If there are **no** staged changes, stop and tell the user to stage files first; do not generate MR content from unstaged work.
4. Draft Title, Root Cause, and How to Fix from what the staged diff actually does.
5. Verify **Title** length ≤ 80 characters (spaces and punctuation count).
6. Write **Title**, **Root Cause**, and **How to Fix** in **English** only (see Language)—even if the user asked in Chinese.
7. Reply with **one** ` ```markdown ` fenced block only (see Output Format)—never bare `###` headings in chat.

## Scope Rules

| Allowed | Not allowed |
|---------|-------------|
| `git diff --staged` output | `git diff` (unstaged) |
| Staged file paths and hunks | User narrative unrelated to staged diff |
| Inferring problem/fix **implied by** the staged change | Inventing bugs or fixes not reflected in staged code |

**Root Cause:** Why this change was needed—the problem or gap the staged diff addresses (inferred from the change, stated concisely).

**How to Fix:** What the staged changes do to resolve it—aligned with the actual diff, not a wish list.

## Language

| Rule | Detail |
|------|--------|
| **MR body** | **English only** for Title, Root Cause, and How to Fix |
| **User locale** | Trigger phrases may be Chinese (e.g. 產生MR內容); still output English inside the fence |
| **Identifiers** | Keep code symbols as in the repo (`applyDiscount`, file paths, API names) |
| **Not allowed** | Traditional/Simplified Chinese (or any non-English prose) in the fenced MR block |

Status messages *outside* the fence (e.g.「請先 stage 變更」) may match the user's language; the copy-paste MR block must remain English.

## Output Format (copy-paste)

The user pastes this into GitLab/GitHub MR description fields. **Do not render MR headings in chat**—wrap the **entire** deliverable in **one** fenced code block so they can copy raw markdown in one action.

Rules:

- **No** preamble, explanation, or text outside the fence (except a one-line hint like「以下可直接複製貼到 MR」*before* the fence is optional; prefer fence-only).
- Use a `markdown` language tag on the fence: ` ```markdown ` … ` ``` `.
- Inside the fence, use exactly this structure (headings are plain text inside the block, not live chat markdown):

```markdown
### Title
<single line, max 80 characters>

### Root Cause
<concise bullets or 1–2 short sentences; key facts only>

### How to Fix
<concise bullets or 1–2 short sentences; actionable fix steps>
```

**Wrong** (renders in chat; hard to copy):

### Title
Some title

**Right** (single copyable block):

```markdown
### Title
Some title
```

## Section Rules

| Section | Rules |
|---------|--------|
| **Title** | One line; ≤ 80 characters; **English**; summarizes the staged change intent; not a raw file list |
| **Root Cause** | 1–3 bullets or ≤ 2 sentences; **English**; problem/gap implied by the diff |
| **How to Fix** | 1–3 bullets or ≤ 2 sentences; **English**; matches what is actually staged |

## Quality

- **Title**: Specific to the change (e.g. `Fix cart duplicate items on rapid add` not `Bug fix`).
- **Root Cause**: Mechanism or requirement the diff addresses—not generic filler.
- **How to Fix**: Describes staged implementation; mention tests only if they appear in the staged diff.
- Omit filler and content not grounded in staged changes.

## Example

**Staged diff:** Adds a session lock in `applyDiscount` and returns an error when a second coupon is applied.

**Output:**

```markdown
### Title
Fix duplicate coupon application race in checkout

### Root Cause
- `applyDiscount` had no guard when two requests ran concurrently
- Second request could read stale cart state before the first write completed

### How to Fix
- Add per-cart-session lock during discount application
- Reject a second coupon with a clear error when one is already applied
```
