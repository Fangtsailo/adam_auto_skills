---
name: write-implementation-plan
description: >-
  Write structured implementation plans to a user-specified markdown file.
  Supports overview mode (Phase-based scope alignment) and detailed mode
  (PR-based executable handoff). Strongly recommends mermaid diagrams. Use when
  the user asks to plan a requirement, create an implementation plan, 規劃實作計畫,
  概覽模式, 詳盡模式, or write a plan to an md file.
disable-model-invocation: false
---

# Write Implementation Plan

Produce or update a **user-specified markdown file** with a structured implementation plan for a requirement.

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
| **Split term** | **Phase** (`Phase 1`, `Phase 2`, …) | **PR** (`PR 1`, `PR 2`, …) |
| **Section heading** | `## Implementation Phases` (or `## 實作階段`) | `## Implementation PRs` (or `## 實作 PR 拆分`) |
| **Requirement** | Summary + Goals required; Out of scope / Assumptions optional and brief | Full Requirement subsections |
| **Per unit** | Scope + Verification bullets; Implementation = high-level bullets only | Full Scope / Implementation / Verification |
| **Unit count** | Prefer 1–3 Phases | Prefer 2–5 PRs; split when a PR would be too large to review |
| **Codebase depth** | Module/area names; no exhaustive file lists unless critical | Real file paths, patterns, APIs from the repo |
| **Diagrams** | At least one flow or Phase-overview mermaid | Multiple diagrams; PR dependency chart when order matters |
| **Template** | [reference-overview.md](reference-overview.md) | [reference-detailed.md](reference-detailed.md) |

**Trigger terms:**

- Overview: 概覽、大綱、high-level、quick plan、先對齊、Phase
- Detailed: 詳盡、完整、可執行、handoff、開始實作、PR 拆分

**Terminology rules (strict):**

- Overview mode: use **Phase** only—never PR—for work units.
- Detailed mode: use **PR** only—never Phase—for work units.
- Do not mix Phase and PR in the same document.

When expanding overview → detailed later, Phases are planning boundaries; PRs are delivery units—a Phase may map to one or more PRs. Regenerate the split using PR terminology; do not only rename headings.

## Workflow

1. **Select mode** (see [Mode Selection](#mode-selection)); ask if unclear.
2. **Clarify inputs** (only if missing):
   - Target file path (required before writing)
   - Requirement summary or source (ticket, user story, chat context)
3. **Explore the codebase** as needed—lighter for overview, thorough for detailed.
4. **Add visual explanations** where they clarify flows or concepts—prefer **mermaid** (see [Visual Explanation](#visual-explanation-highly-recommended)).
5. **Write or update** the target markdown file on disk—do not only paste the plan in chat unless the user explicitly asks for chat-only output.
6. **Validate** against [Required Sections](#required-sections) for the chosen mode.
7. Reply briefly: confirm file path, mode, unit count (Phase or PR count), diagram count (if any), and assumptions—not the full document body.

## Required Sections

Every plan **must** include these two parts. Do not omit or rename them.

### 1. Requirement

A dedicated section that states **what** is being built and **why**.

| Subsection | Overview | Detailed |
|------------|----------|----------|
| **Summary** | Required | Required |
| **Goals** | Required | Required |
| **Out of scope** | Optional, brief | Required (or explicit "None") |
| **Assumptions / dependencies** | Optional, brief | Required (or explicit "None") |

Suggested heading: `## Requirement` (or equivalent in the user's language).

### 2. Work Split (mode-specific)

#### Overview — Implementation Phases

Split work into **Phase 1, Phase 2, …** (order matters). Each Phase **must** include:

| Subsection | Content |
|------------|---------|
| **Scope** | What this Phase delivers; areas/modules touched; boundaries vs other Phases |
| **Implementation** | High-level approach bullets—not step-by-step code changes |
| **Verification** | How to confirm this Phase is done: checks or observable outcomes |

```markdown
## Implementation Phases

### Phase 1: <short title>

#### Scope
...

#### Implementation
- ...

#### Verification
- ...
```

**Phase rules:**

- Each Phase should be independently verifiable before moving on.
- Prefer 1–3 Phases; add more only when scope is large or dependencies are clear.
- State cross-Phase dependencies in Scope when relevant.

#### Detailed — Implementation PRs

Split work into **PR 1, PR 2, …** (merge order matters). Each PR **must** include:

| Subsection | Content |
|------------|---------|
| **Scope** | What this PR delivers; files/areas touched; boundaries vs other PRs; merge dependency |
| **Implementation** | Concrete steps: approach, key changes, patterns to follow, APIs/modules involved |
| **Verification** | How to confirm this PR is merge-ready: tests, manual checks, commands, observable outcomes |

```markdown
## Implementation PRs

### PR 1: <short title>

#### Scope
...

#### Implementation
1. ...

#### Verification
- [ ] ...
```

**PR rules:**

- Each PR should be independently reviewable and mergeable (or clearly stacked with dependency noted).
- Prefer 2–5 PRs; split further when a single PR would be hard to review.
- Later PRs may depend on earlier ones—state dependencies in Scope when relevant.
- Scope should be small enough that one developer (or agent) can complete one PR in a focused session.

## Visual Explanation (Highly Recommended)

**Prefer diagrams over long prose** when explaining flows, architecture, state transitions, or unit dependencies. **Mermaid** is the default—it renders in GitLab, GitHub, and most markdown viewers.

| Use a diagram when… | Suggested mermaid type |
|---------------------|------------------------|
| User or data flow across components | `flowchart` / `sequenceDiagram` |
| Phase or PR order and dependencies | `flowchart` (top-down or left-right) |
| State or lifecycle changes | `stateDiagram-v2` |
| Entity relationships or schema | `erDiagram` |
| Decision branches / error paths | `flowchart` with labeled edges |

**Placement:**

- **Requirement**: high-level context diagram (current vs target flow, actors involved).
- **Work split section**: Phase-overview or PR-dependency diagram when multiple units exist.
- **Per unit**: diagram when steps are easier to see than to read (detailed mode).
- **Optional `## Architecture` / `## Flow`**: dedicated section for larger features.

**Rules:**

- Keep node labels short; use real module/service names from the codebase.
- One diagram per concern—split overloaded diagrams rather than one giant chart.
- Add a one-line caption below each diagram explaining what it shows.
- Plain ASCII diagrams are acceptable only when mermaid is impractical.

## Optional Sections

Add any extra sections that help the specific requirement. Examples:

- Background / context
- Architecture, data-flow, or sequence diagrams (**mermaid strongly preferred**)
- Risks and mitigations
- Rollback plan
- Open questions
- Appendix (links, API notes)

Optional sections must **not** replace the required Requirement and work-split sections.

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
| **Proportional** | Shorter units; skip exhaustive detail | Clear PR boundaries; no oversized PRs |
| **Visual** | At least one mermaid when flows or Phase dependencies exist | Mermaid for flows, PR order, or cross-component interaction |

## Pre-delivery Checklist

Before completing:

- [ ] Target file written or updated at the path the user gave
- [ ] Mode is clear (overview or detailed) and terminology is consistent (Phase **or** PR, not both)
- [ ] `## Requirement` (or equivalent) present with required subsections for the mode
- [ ] `## Implementation Phases` **or** `## Implementation PRs` with every unit having Scope, Implementation, Verification
- [ ] Units ordered and non-overlapping where possible
- [ ] Flows or dependencies explained with **mermaid** where a diagram clarifies faster than text
- [ ] Optional sections only add value; required sections unchanged

## Additional Resources

- Overview template: [reference-overview.md](reference-overview.md)
- Detailed template: [reference-detailed.md](reference-detailed.md)
