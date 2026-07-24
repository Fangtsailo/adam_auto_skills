---
name: architect-first-gate
description: >-
  Assumes system-architect role before coding: designs macro component communication (participants, data flow, NGXS/IO/service/API), confirms existing architecture with mermaid, then waits for explicit user approval (gate) before writing code. Use when fixing bugs, implementing features, refactoring cross-component flows, or when the user mentions 宏觀組件溝通, 架構設計, or 閘門.
disable-model-invocation: false
---

# Architect First Gate

**Hard rule:** Do **not** write or edit application code until the user explicitly approves the architecture design in this turn or a later message.

## When to apply

Apply for any of:

- Implement a feature / new flow
- Fix a bug that touches more than one component, service, store, or API boundary
- Refactor communication between components / modules
- User mentions 宏觀組件溝通、架構設計、閘門、先設計再寫碼

**Skip the gate** (may code immediately) only when **all** are true:

- Pure typo / copy / comment / i18n key wording, **or** a single-file local change with **no** new/changed cross-boundary communication
- No new Input/Output, store action/select, service API, route, or HTTP contract

If unsure whether the gate applies → **apply the gate**.

## Role

Act as a **system architect** first, implementer second. Prefer discovering the **existing** project flow over inventing a new one. Prefer reusing existing communication patterns (NGXS, Input/Output, shared services, facades) unless the design explicitly justifies a change.

## Workflow (mandatory order)

Copy and track:

```
Gate Progress:
- [ ] 1. Explore existing architecture
- [ ] 2. Produce 宏觀組件溝通機制設計 (chat)
- [ ] 3. STOP — wait for explicit user approval
- [ ] 4. Implement only after approval
```

### 1. Explore existing architecture

Before proposing design:

1. Locate the feature/bug area (routes, feature modules, related components).
2. Map current communication: parent↔child, services, NGXS actions/selectors, HTTP APIs, events.
3. Note conventions already used in that module (do not introduce a second pattern without reason).

Keep exploration proportional: small bug → nearby files; large feature → module + store + API entry points.

### 2. Produce 宏觀組件溝通機制設計

Output **in chat** (do not require a markdown file unless the user asks). Use the user's language (Traditional Chinese when they write in Chinese). Keep code identifiers in English as in the repo.

Required sections — see [reference.md](reference.md) for the full template:

| Section | Content |
|---------|---------|
| **Goal** | What changes and why (1–3 sentences) |
| **Participants** | Components / services / stores / APIs involved (real names from the repo) |
| **Current flow** | How it works today (or "N/A — greenfield") + mermaid |
| **Proposed flow** | Target communication after the change + mermaid |
| **Communication mechanisms** | Per boundary: Input/Output, NGXS, service call, HTTP, router, etc. — and **why** |
| **Impact / risks** | Files or contracts touched; regressions to watch |
| **Open questions** | Only if blocking; otherwise state assumptions |

**Mermaid:** prefer `sequenceDiagram` for request/event order; `flowchart` for ownership/data ownership. Use real symbol names.

**Scale the writeup:**

| Change size | Design depth |
|-------------|--------------|
| Small (2–3 participants) | Short Goal + one sequence diagram + mechanism bullets |
| Medium / large | Full template; call out store vs component responsibilities |

Large multi-PR work: after gate approval, optionally use `write-implementation-plan` for a detailed md plan — **gate still comes first**.

### 3. Gate — STOP

End the design message with an explicit ask, e.g.:

> 以上是宏觀組件溝通設計。請確認或指出要調整的地方；**你同意後我才開始寫程式。**

**Do not** start coding, scaffolding files, or applying patches in the same turn as the design unless the user already approved in a **prior** message.

Treat as **approval**: 同意、OK、可以、照這個做、開始實作、LGTM, or clear equivalent.

Treat as **not approval**: questions, partial feedback, silence, or "大致可以但…" with requested changes → revise design, re-gate.

### 4. Implement after approval

1. Follow the approved design; if implementation discovers a conflict, **stop and re-gate** with a short delta (what changed and why) before continuing.
2. Then apply project coding skills (`angular-dev-core-rules`, `angular-developer`, etc.) as usual.
3. Do not expand scope beyond the approved communication plan without asking.

## Anti-patterns

- Coding first, "explaining architecture" afterward
- Generic diagrams with placeholder names (`ComponentA`, `ServiceB`) when repo names exist
- Inventing a new state/communication pattern when the module already has one
- Skipping the gate because the change "looks small" while adding cross-boundary wiring
- Asking the user to approve a vague plan without Current vs Proposed flow

## Related skills

| Skill | Relationship |
|-------|----------------|
| `write-implementation-plan` | Optional **after** gate for large Phase/PR md plans |
| `knowledge-implementation-guideline` | Use when the design hinges on FE/BE ownership of a rule |
| `angular-dev-core-rules` / `angular-developer` | Apply **during** implementation (step 4), not instead of the gate |

## Additional resources

- Design template and examples: [reference.md](reference.md)
