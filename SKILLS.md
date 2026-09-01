# Skills Catalog

Auto-generated from `skills/manifest.json`. Do not edit manually.

*Generated at: 2026-09-01 02:38:07 UTC*

| Skill | Version | Tags | Description |
|-------|---------|------|-------------|
| `angular-code-review` | 1.2.0 | angular, code-review, typescript | Review Angular PRs/MRs with team gates, angular-dev-core-rules (FP, declarative UI), and zyxel-i18n-write (string write path). NGXS, inject(), TypeScript, style, security, performance. |
| `angular-dev-core-rules` | 1.2.0 | angular, ngxs, rxjs, i18n, typescript | Guides Angular implementation toward FP, declarative UI/data flow, purposeful comments, and i18n runtime rules. String write path is zyxel-i18n-write. Use for dev/refactor; use angular-code-review for PR review. |
| `angular-developer` | 1.0.0 | imported, angular | Generates Angular code and provides architectural guidance. Trigger when creating projects, components, or services, or for best practices on reactivity (signals, linkedSignal, resource), forms, dependency injection, routing, SSR, accessibility (ARIA), animations, styling (component styles, Tailwind CSS), testing, or CLI tooling. |
| `architect-first-gate` | 1.0.0 | architecture, workflow, gate, mermaid | Assumes system-architect role before coding: designs macro component communication (participants, data flow, NGXS/IO/service/API), confirms existing architecture with mermaid, then waits for explicit user approval (gate) before writing code. Use when fixing bugs, implementing features, refactoring cross-component flows, or when the user mentions 宏觀組件溝通, 架構設計, or 閘門. |
| `ask-adam` | 1.0.0 | workflow, router | Pick which hand-fired skill to follow, then do that work. |
| `fe-code-to-api-requirement` | 1.0.0 | requirements, backend-handoff, api-design, documentation | Convert frontend code into a Traditional Chinese backend-facing requirement spec that does not design the API. |
| `generate-mr-content` | 1.0.0 | merge-request, mr, workflow, documentation | Generate an English MR description (Title, Root Cause, How to Fix) from git staged changes. |
| `git-commit` | 1.0.0 | git, commit, workflow, cocogitto | Commit staged changes with Cocogitto via mise, after showing the MR block and waiting for confirmation. |
| `i-have-adhd` | 1.0.0 | imported, i-have-adhd | Shape output for a reader with ADHD: lead with the next action, number multi-step work, restate state across turns, suppress tangents, give specific time estimates, make wins visible. Invoke with /i-have-adhd; stays on until "stop adhd mode". |
| `knowledge-implementation-guideline` | 1.1.1 | architecture, frontend-backend, decision-tree, documentation | Decide FE/BE/Shared ownership for a Business Rule with the Q1/Q2/Q3 tree and produce the standard writeup. |
| `td-detail-fillin` | 1.0.0 | workflow, documentation, inventory, tech-debt | Fill or rewrite the 給 BE RD Detail block of an Inventory tech-debt entry. |
| `test-item` | 1.0.1 | documentation, workflow, handoff, testing | Write a Traditional Chinese 測試項目 from a specified branch's 畫面改動 for the testing department. |
| `ui-operation-desc` | 1.0.0 | documentation, requirements, workflow, handoff | Write a Traditional Chinese UI-operation description from specified code for readers who do not write that code. |
| `write-implementation-plan` | 1.3.0 | planning, workflow, documentation, mermaid | Write a structured implementation plan to a user-specified markdown file, split by Phase or by PR. |
| `zyxel-i18n-write` | 1.0.0 | angular, i18n, gui3 | Writes gui3 user-visible strings via Dedupe Terms, Crowdin translation reuse, or YAML-only. Use whenever adding or changing UI copy in templates, YAML, menus, placeholders, aria, toasts, or dialogs — including i18n, translate, Crowdin, I18N_DEDUPE_TERMS, or apps/gui3/src/i18n. |

## Install

```bash
./bin/skill install --global <skill-name>
```

