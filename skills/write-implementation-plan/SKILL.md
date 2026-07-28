---
name: write-implementation-plan
description: >-
  Write structured implementation plans to a user-specified markdown file.
  Supports overview mode (Phase-based scope alignment) and detailed mode
  (PR-based executable handoff). Enforces reviewable unit size (≤3 files /
  ≤200 lines) and human checkpoints between units. Strongly recommends mermaid
  diagrams. Use when the user asks to plan a requirement, create an
  implementation plan, 規劃實作計畫, 概覽模式, 詳盡模式, or write a plan to an md file.
disable-model-invocation: false
---

# Write Implementation Plan

Produce or update a **user-specified markdown file** with a structured implementation plan for a requirement.

**Section structure and templates live only in the mode reference files.** Do not invent headings from memory—read the matching reference before writing.

## Reviewability & human checkpoints

Human review quality drops when a unit exceeds **cognitive load** limits. Plans must **split work so each reviewable unit stays inside those limits**, and must encode **progressive human approval** between units—not dump one oversized change for a single pass.

| Constraint | Rule |
|------------|------|
| **Files per unit** | **≤ 3 files** touched per Detailed **PR** (prefer fewer). Count production + test + i18n that the reviewer must read as part of the same review. |
| **Lines per unit** | **≤ ~200 lines** net diff per Detailed **PR** (additions + deletions the reviewer must understand). Prefer smaller. |
| **If over limit** | **Must split** into additional PRs (or further Phases that expand into such PRs). Do not ship a "reviewable size" checkbox while planning an oversized unit. |
| **Progressive review** | Units are ordered; each unit is meant to be implemented and **human-reviewed before** starting the next (unless the user explicitly waives). |
| **Human checkpoint** | Every unit's **Verification** must include an explicit human sign-off step before the next unit (e.g. approve / LGTM / merge). Agent or implementer **stops** at that gate. |

**Mode application:**

- **Detailed:** Limits apply to each **PR**. List the expected files in Scope; if more than 3 files or likely >200 lines, split further.
- **Overview:** Each **Phase** must be small enough that it can expand into one or more PRs that each satisfy the limits above. Prefer 1–3 Phases; do not hide a large rewrite inside one Phase.
- **Exempt from file count (still keep line budget):** pure one-line config / lockfile-only churn may be called out as non-review focus, but do not use that to bury logic changes.

## Trigger

Apply when the user asks to:

- Plan a requirement into a markdown file (e.g. `docs/feature-x-plan.md`)
- Create an implementation plan / 實作計畫 / 規劃 plan
- Split work into **Phases** (overview) or **PRs** (detailed, ready to implement)
- Use **概覽模式** or **詳盡模式**

## Mode Selection

Determine mode **before** writing. Default: **detailed** unless the user asks for overview.

| | Overview 概覽 | Detailed 詳盡 |
|---|---------------|---------------|
| **Purpose** | Early alignment, stakeholder skim, scope boundaries | Handoff for implementation—each unit maps to a mergeable PR |
| **Split term** | **Phase** only (`Phase 1`, …) | **PR** only (`PR 1`, …) |
| **Section heading** | `## Implementation Phases` (or `## 實作階段`) | `## Implementation PRs` (or `## 實作 PR 拆分`) |
| **Requirement depth** | Summary + Goals required; Out of scope / Assumptions optional and brief | Full Requirement subsections (or explicit "None") |
| **Per unit** | Scope + Implementation (high-level) + Verification + human checkpoint | Full Scope / Implementation / Verification + human checkpoint |
| **Unit count** | Prefer 1–3 Phases; each Phase expandable into ≤3-file / ≤200-line PRs | Prefer 2–5 PRs; **must** split if a PR would exceed **≤3 files** or **≤~200 lines** |
| **Codebase depth** | Module/area names; no exhaustive file lists unless critical | Real file paths (cap ≤3 per PR), patterns, APIs from the repo |
| **Diagrams** | At least one flow or Phase-overview mermaid | Multiple diagrams; PR dependency chart when order matters |
| **Template (mandatory read)** | [reference-overview.md](reference-overview.md) | [reference-detailed.md](reference-detailed.md) |

**Trigger terms:**

- Overview: 概覽、大綱、high-level、quick plan、先對齊、Phase
- Detailed: 詳盡、完整、可執行、handoff、開始實作、PR 拆分

**Terminology rules (strict):**

- Overview mode: use **Phase** only—never PR—for work units.
- Detailed mode: use **PR** only—never Phase—for work units.
- Do not mix Phase and PR in the same document.

When expanding overview → detailed later, Phases are planning boundaries; PRs are delivery units—a Phase may map to one or more PRs. Regenerate the split using PR terminology; do not only rename headings.

## Hard rules

1. Write (or update) the plan **on disk** at the path the user gave—do not only paste the plan in chat unless the user explicitly asks for chat-only output.
2. **Before writing**, read the template for the chosen mode (`reference-overview.md` or `reference-detailed.md`). Copy and adapt that structure; do not invent section layout from memory.
3. Every plan must include **Requirement** and the mode work-split section (`## Implementation Phases` **or** `## Implementation PRs`). Each unit must have **Scope**, **Implementation**, and **Verification**.
4. Prefer **mermaid** over long prose for flows, architecture, and Phase/PR dependencies. Use real module/service names; one diagram per concern; one-line caption under each diagram. Details and diagram-type hints are in the mode reference.
5. Optional sections (risks, open questions, appendix, etc.) may be added from the reference examples but must **not** replace required sections.
6. **Reviewability:** Detailed PRs must target **≤ 3 files** and **≤ ~200 lines** net diff. If the natural change is larger, add more PRs. Overview Phases must be scoped so later PR expansion can meet the same limits.
7. **Human checkpoint:** Each unit's Verification must include a human approval gate before the next unit. Do not plan "implement all units then review once" unless the user explicitly requests a single review pass.

## Workflow

1. **Select mode** (see [Mode Selection](#mode-selection)); ask if unclear.
2. **Clarify inputs** (only if missing): target file path (required); requirement summary or source.
3. **Read** the matching reference template for that mode.
4. **Explore the codebase** as needed—lighter for overview, thorough for detailed.
5. **Write or update** the target markdown file using the reference structure.
6. **Validate** against [Pre-delivery Checklist](#pre-delivery-checklist).
7. Reply briefly: confirm file path, mode, unit count (Phase or PR count), diagram count (if any), and assumptions—not the full document body.

## Language

| Rule | Detail |
|------|--------|
| **Plan document** | Match the user's language (Traditional Chinese if they asked in Chinese; English if they asked in English) |
| **Headings** | Consistent within one document; localized labels are fine (`## 需求`, `### Phase 1`, `### PR 1`) |
| **Unit labels** | Keep **Phase** / **PR** as English terms in headings even in Chinese documents, unless the user explicitly requests full localization |
| **Identifiers** | Keep code symbols, file paths, and API names as in the repo |

## Quality

| Principle | Overview | Detailed |
|-----------|----------|----------|
| **Grounded** | Real modules and areas—not generic placeholders | Real files, conventions, and patterns from the codebase |
| **Actionable** | Clear boundaries and outcomes per Phase | Steps specific enough for another developer or agent to open a PR |
| **Verifiable** | Observable outcomes per Phase | Concrete commands, test names, or checklists per PR |
| **Proportional** | Shorter units; skip exhaustive detail | Clear PR boundaries; **≤3 files / ≤~200 lines** per PR |
| **Progressive** | Human checkpoint after each Phase (or demo sign-off) | Human approve / merge before next PR |
| **Visual** | At least one mermaid when flows or Phase dependencies exist | Mermaid for flows, PR order, or cross-component interaction |

## Pre-delivery Checklist

Before completing:

- [ ] Matching mode reference was read before writing
- [ ] Target file written or updated at the path the user gave
- [ ] Mode is clear (overview or detailed) and terminology is consistent (Phase **or** PR, not both)
- [ ] `## Requirement` (or equivalent) present with required subsections for the mode
- [ ] `## Implementation Phases` **or** `## Implementation PRs` with every unit having Scope, Implementation, Verification
- [ ] Units ordered and non-overlapping where possible
- [ ] Detailed: each PR Scope lists ≤3 files (or is split further); no planned PR likely over ~200 lines
- [ ] Every unit Verification includes a **human checkpoint** before the next unit
- [ ] Flows or dependencies explained with **mermaid** where a diagram clarifies faster than text
- [ ] Optional sections only add value; required sections unchanged

## Additional Resources

- Overview template: [reference-overview.md](reference-overview.md)
- Detailed template: [reference-detailed.md](reference-detailed.md)
