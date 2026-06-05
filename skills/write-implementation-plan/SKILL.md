---
name: write-implementation-plan
description: >-
  Write structured implementation plans to a user-specified markdown file with
  required requirement and phased scope/implementation/verification sections.
  Strongly recommends mermaid diagrams for flows and concepts. Use when the user
  asks to plan a requirement, create an implementation plan, 規劃實作計畫, or
  write a plan to an md file.
disable-model-invocation: false
---

# Write Implementation Plan

Produce or update a **user-specified markdown file** with a structured implementation plan for a requirement.

## Trigger

Apply when the user asks to:

- Plan a requirement into a markdown file (e.g. `docs/feature-x-plan.md`)
- Create an implementation plan / 實作計畫 / 規劃 plan
- Split work into phases with scope and verification steps

## Workflow

1. **Clarify inputs** (only if missing):
   - Target file path (required before writing)
   - Requirement summary or source (ticket, user story, chat context)
2. **Explore the codebase** as needed so phases reflect real files, patterns, and constraints.
3. **Add visual explanations** where they clarify flows or concepts—prefer **mermaid** diagrams (see [Visual Explanation](#visual-explanation-highly-recommended)).
4. **Write or update** the target markdown file on disk—do not only paste the plan in chat unless the user explicitly asks for chat-only output.
5. **Validate** the document against [Required Sections](#required-sections) before finishing.
6. Reply briefly: confirm the file path, phase count, diagram count (if any), and any assumptions—not the full document body.

## Required Sections

Every plan **must** include these two parts. Do not omit or rename them.

### 1. Requirement

A dedicated section that states **what** is being built and **why**.

| Subsection | Content |
|------------|---------|
| **Summary** | One-paragraph overview of the requirement |
| **Goals** | Measurable outcomes or acceptance intent |
| **Out of scope** | What this plan explicitly does **not** cover (if any) |
| **Assumptions / dependencies** | Prerequisites, blockers, or external systems (if any) |

Suggested heading: `## Requirement` (or equivalent in the user's language).

### 2. Implementation Phases

Split implementation into **Phase 1, Phase 2, …** (order matters). Each phase **must** include:

| Subsection | Content |
|------------|---------|
| **Scope** | What this phase delivers; files/areas touched; boundaries vs other phases |
| **Implementation** | Concrete steps: approach, key changes, patterns to follow, APIs/modules involved |
| **Verification** | How to confirm this phase is done: tests, manual checks, commands, observable outcomes |

Suggested structure:

```markdown
## Implementation Phases

### Phase 1: <short title>

#### Scope
...

#### Implementation
...

#### Verification
...

### Phase 2: <short title>
...
```

**Phase rules:**

- Each phase should be independently verifiable before moving on.
- Prefer 2–5 phases; split further only when scope is large or dependencies are clear.
- Later phases may depend on earlier ones—state dependencies in Scope when relevant.

## Visual Explanation (Highly Recommended)

**Prefer diagrams over long prose** when explaining flows, architecture, state transitions, or phase dependencies. **Mermaid** is the default and strongly recommended—it renders in GitLab, GitHub, and most markdown viewers.

| Use a diagram when… | Suggested mermaid type |
|---------------------|------------------------|
| User or data flow across components | `flowchart` / `sequenceDiagram` |
| Phase order and dependencies | `flowchart` (top-down or left-right) |
| State or lifecycle changes | `stateDiagram-v2` |
| Entity relationships or schema | `erDiagram` |
| Decision branches / error paths | `flowchart` with labeled edges |

**Placement:**

- **Requirement section**: high-level context diagram (e.g. current vs target flow, actors involved).
- **Implementation Phases**: per-phase or end-to-end diagram when steps are easier to see than to read.
- **Optional `## Architecture` / `## Flow`**: dedicated section for larger features.

**Rules:**

- Keep node labels short; use real module/service names from the codebase.
- One diagram per concern—split overloaded diagrams rather than one giant chart.
- Add a one-line caption below each diagram explaining what it shows.
- Plain ASCII diagrams are acceptable only when mermaid is impractical (e.g. terminal-only viewers).

````markdown
## Flow overview

End-to-end discount badge display on the listing page:

```mermaid
flowchart LR
    API[Listing API] --> DTO[ProductDto]
    DTO --> Card[ProductCardComponent]
    Card -->|discountPercent > 0| Badge[Discount badge]
```
````

## Optional Sections

Add any extra sections that help the specific requirement. Examples:

- Background / context
- Architecture, data-flow, or sequence diagrams (**mermaid strongly preferred**)
- Risks and mitigations
- Rollback plan
- Open questions
- Appendix (links, API notes)

Optional sections must **not** replace the required Requirement and Implementation Phases sections.

## Language

| Rule | Detail |
|------|--------|
| **Plan document** | Match the user's language (Traditional Chinese if they asked in Chinese; English if they asked in English) |
| **Headings** | Consistent within one document; localized labels are fine (`## 需求`, `#### 驗證方式`) |
| **Identifiers** | Keep code symbols, file paths, and API names as in the repo |

## Quality

- **Grounded**: Reference real modules, conventions, and files from the codebase—not generic placeholders.
- **Actionable**: Implementation steps are specific enough for another developer (or agent) to execute.
- **Verifiable**: Verification lists concrete commands, test names, or checklists—not vague "make sure it works."
- **Proportional**: Small requirements may use shorter phases; large ones need clearer boundaries.
- **Visual**: Include at least one mermaid diagram when the requirement involves multi-step flows, cross-component interaction, or non-trivial phase dependencies; more diagrams are welcome when they reduce ambiguity.

## Pre-delivery Checklist

Before completing:

- [ ] Target file written or updated at the path the user gave
- [ ] `## Requirement` (or equivalent) present with clear what/why
- [ ] `## Implementation Phases` (or equivalent) with every phase having Scope, Implementation, Verification
- [ ] Phases ordered and non-overlapping where possible
- [ ] Flows or architecture explained with **mermaid** where a diagram would clarify faster than text (strongly recommended)
- [ ] Optional sections only add value; required sections unchanged

## Additional Resources

- Full document template: [reference.md](reference.md)
