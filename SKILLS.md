# Skills Catalog

Auto-generated from `skills/manifest.json`. Do not edit manually.

*Generated at: 2026-07-24 06:13:13 UTC*

| Skill | Version | Tags | Description |
|-------|---------|------|-------------|
| `angular-code-review` | 1.1.1 | angular, code-review, typescript | Review Angular PRs/MRs with team gates plus angular-dev-core-rules (i18n, FP, declarative UI). NGXS, inject(), TypeScript, style, security, performance. |
| `angular-dev-core-rules` | 1.1.0 | angular, ngxs, rxjs, i18n, typescript | Guides Angular implementation toward project i18n (YAML/Crowdin, no runtime fallback), FP, declarative UI/data flow, and purposeful comments. Use for dev/refactor; use angular-code-review for PR review. |
| `angular-developer` | 1.0.0 | imported, angular | Generates Angular code and provides architectural guidance. Trigger when creating projects, components, or services, or for best practices on reactivity (signals, linkedSignal, resource), forms, dependency injection, routing, SSR, accessibility (ARIA), animations, styling (component styles, Tailwind CSS), testing, or CLI tooling. |
| `architect-first-gate` | 1.0.0 | architecture, workflow, gate, mermaid | Assumes system-architect role before coding: designs macro component communication (participants, data flow, NGXS/IO/service/API), confirms existing architecture with mermaid, then waits for explicit user approval (gate) before writing code. Use when fixing bugs, implementing features, refactoring cross-component flows, or when the user mentions 宏觀組件溝通, 架構設計, or 閘門. |
| `generate-mr-content` | 1.0.0 | merge-request, mr, workflow, documentation | Generate English MR description from git staged changes when user says 產生MR內容 (Title, Root Cause, How to Fix). |
| `knowledge-implementation-guideline` | 1.0.0 | architecture, frontend-backend, decision-tree, documentation | Determines whether hard-coded frontend business/domain knowledge should be frontend-only, backend-only, or both, using a Q1/Q2/Q3 decision tree (SSOT mutation, UX validation, catalog/aggregation/performance/cross-client consistency). Classifies knowledge attributes and produces standardized knowledge-entry writeups. |
| `write-implementation-plan` | 1.2.0 | planning, workflow, documentation, mermaid | Write structured implementation plans to a user-specified markdown file. Overview mode splits scope by Phase; detailed mode splits by PR for implementation handoff. Strongly recommends mermaid diagrams. Use when planning a requirement, 規劃實作計畫, 概覽模式, or 詳盡模式. |

## Install

```bash
./bin/skill install --global <skill-name>
```

