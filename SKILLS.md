# Skills Catalog

Auto-generated from `skills/manifest.json`. Do not edit manually.

*Generated at: 2026-08-31 05:33:12 UTC*

| Skill | Version | Tags | Description |
|-------|---------|------|-------------|
| `angular-code-review` | 1.1.1 | angular, code-review, typescript | Review Angular PRs/MRs with team gates plus angular-dev-core-rules (i18n, FP, declarative UI). NGXS, inject(), TypeScript, style, security, performance. |
| `angular-dev-core-rules` | 1.1.0 | angular, ngxs, rxjs, i18n, typescript | Guides Angular implementation toward project i18n (YAML/Crowdin, no runtime fallback), FP, declarative UI/data flow, and purposeful comments. Use for dev/refactor; use angular-code-review for PR review. |
| `angular-developer` | 1.0.0 | imported, angular | Generates Angular code and provides architectural guidance. Trigger when creating projects, components, or services, or for best practices on reactivity (signals, linkedSignal, resource), forms, dependency injection, routing, SSR, accessibility (ARIA), animations, styling (component styles, Tailwind CSS), testing, or CLI tooling. |
| `architect-first-gate` | 1.0.0 | architecture, workflow, gate, mermaid | Assumes system-architect role before coding: designs macro component communication (participants, data flow, NGXS/IO/service/API), confirms existing architecture with mermaid, then waits for explicit user approval (gate) before writing code. Use when fixing bugs, implementing features, refactoring cross-component flows, or when the user mentions 宏觀組件溝通, 架構設計, or 閘門. |
| `fe-code-to-api-requirement` | 1.0.0 | requirements, backend-handoff, api-design, documentation | Convert frontend code into a Traditional Chinese requirement spec for backend API design discussions. Bans existing API endpoints/fields, current-behavior narration, and frontend variable/function names; enforces minimum-background-knowledge wording and removes ambiguous jargon. |
| `generate-mr-content` | 1.0.0 | merge-request, mr, workflow, documentation | Generate English MR description from git staged changes when user says 產生MR內容 (Title, Root Cause, How to Fix). |
| `git-commit` | 1.0.0 | git, commit, workflow, cocogitto | Commit staged changes via mise exec -- cog commit (Cocogitto). Infers TYPE from branch, runs generate-mr-content (shows full MR block; MESSAGE=Title), sets SCOPE from prompt ID (e.g. commit 71166 → RM-71166) or omits it, and always waits for explicit confirmation before committing. Use when the user says commit, commit <id>, 產生commit, 幫我 commit, git:commit, or 送出 commit. |
| `i-have-adhd` | 1.0.0 | imported, i-have-adhd | Shape output for a reader with ADHD: lead with the next action, number multi-step work, restate state across turns, suppress tangents, give specific time estimates, make wins visible. Invoke with /i-have-adhd; stays on until "stop adhd mode". |
| `knowledge-implementation-guideline` | 1.1.1 | architecture, frontend-backend, decision-tree, documentation | Determines FE/BE/Shared Ownership for a Business Rule using a Q1/Q2/Q3 decision tree (SSOT mutation, UX Validate, Reverse Lookup, Data Aggregation, Conditional Mapping). Classifies Rule Type and produces standardized writeups. |
| `td-detail-fillin` | 1.0.0 | workflow, documentation, inventory, tech-debt | Fill or rewrite the「給 BE RD」Detail block of Inventory tech-debt (TD) entries using product language, real API field paths, and clear Consume-vs-FE-推算 separation. Use when the user asks to 寫 TD Detail、填寫給 BE RD、補 TD Detail、改寫 Detail、對齊 td_fillin_guideline, or mentions TD-00x Detail / 篩選集合 / 直通 API vs FE 推算 for BE handoff. |
| `ui-operation-desc` | 1.0.0 | documentation, requirements, workflow, handoff | Generate a Traditional Chinese UI-operation description from user-specified code so cross-team readers understand what the user does on screen. Documents may only mark which code to read; every claim is grounded in that code, then API and code vocabulary are stripped. Use when the user asks to 產生畫面操作說明、用人話講畫面、去實作化描述畫面、寫使用者操作目的／使用者操作流程, mentions ui-operation-desc, or wants a screen walkthrough for PM / QA / another unit — not an API spec and not a TD Detail. |
| `write-implementation-plan` | 1.3.0 | planning, workflow, documentation, mermaid | Write structured implementation plans to a user-specified markdown file. Overview mode splits scope by Phase; detailed mode splits by PR for implementation handoff. Enforces reviewable unit size (≤3 files / ≤200 lines) and human checkpoints between units. Strongly recommends mermaid diagrams. Use when planning a requirement, 規劃實作計畫, 概覽模式, or 詳盡模式. |

## Install

```bash
./bin/skill install --global <skill-name>
```

