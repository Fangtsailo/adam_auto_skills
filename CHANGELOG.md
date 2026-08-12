# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added

- Skill `i-have-adhd` (imported from [ayghri/i-have-adhd](https://github.com/ayghri/i-have-adhd)): ADHD-friendly output — lead with next action, numbered steps, no preamble/tangents
- Skill `architect-first-gate`: system-architect role before coding; macro component communication design with mermaid; hard gate waits for explicit user approval before writing code
- Skill `write-implementation-plan`: structured requirement + phased implementation plans written to user-specified markdown files

### Changed

- `knowledge-implementation-guideline` (1.0.1): slim `SKILL.md`—Q3①②③ detailed criteria live only in `reference.md`; SKILL keeps decision tree, Q1/Q2, and Q3 one-line summary
- `write-implementation-plan` (1.2.1): slim `SKILL.md`—drop duplicated section templates; require reading mode reference before writing; keep mode table, hard rules, and checklist
- `write-implementation-plan` (1.2.0): dual modes—overview (Phase-based scope) and detailed (PR-based handoff); split templates into `reference-overview.md` and `reference-detailed.md`
- `write-implementation-plan` (1.1.0): strongly recommend mermaid diagrams for flows, architecture, and phase dependencies; workflow, checklist, and reference templates updated

## [1.4.1] - 2026-06-04

### Changed

- `angular-dev-core-rules` (1.1.0): align manifest description with SKILL (project i18n, no runtime fallback); unify `npm run` i18n script wording
- `angular-code-review` (1.1.1): authoritative-source note for dev-core shorthand; `npm run` i18n commands; style gates (`.vscode/code_style_guide.md`, SASS quotes, semantic HTML/ARIA)
- `README.md`, `PROJECT_PLAN.md`, `SKILLS.md`: sync versions and descriptions with `skills/manifest.json`

## [1.4.0] - 2026-06-04

### Added

- Skill `angular-dev-core-rules`: strict i18n, functional programming, declarative patterns, and purposeful comments (with `reference.md`)

### Changed

- `angular-dev-core-rules`: soften absolute bans; clarify scope vs `angular-code-review`; API-agnostic i18n and flexible subscribe/DOM guidance
- `angular-code-review` (1.1.0): align checklist with `angular-dev-core-rules`; add scope split, severity guidance, and cross-links; avoid duplicating dev-core content

## [1.3.0] - 2026-06-03

### Added

- Remote skill registry: `config/remotes.json` and `scripts/remotes.py`
- Commands: `remote`, `pull`, `submodule` (add/update/remove/list)
- CI/SDK integration guide: `docs/automations.md`
- Examples: `examples/install-skills-ci.sh`, `examples/github-action-install-skills.yml`

## [1.2.0] - 2026-06-03

### Added

- GitHub Actions workflow: `.github/workflows/validate.yml`
- Pre-commit hook: `scripts/hooks/pre-commit`
- Hook installer: `./bin/skill hooks install`
- Skill scaffold: `./bin/skill new <name>`
- Manifest consistency validation in `validate --all`

## [1.1.0] - 2026-06-03

### Added

- Unified CLI entry point: `bin/skill`
- Install manifest tracking via `.adam-manifest.json` and `scripts/manifest.py`
- Commands: `list`, `info`, `sync`, `uninstall`, `generate`
- Auto-generated `SKILLS.md` catalog
- `scripts/list.sh`, `scripts/info.sh`, `scripts/sync.sh`, `scripts/uninstall.sh`, `scripts/generate-skills-md.sh`

### Changed

- `install.sh` now records installs to the install manifest
- README updated for Phase 2 CLI usage

## [1.0.0] - 2026-06-03

### Added

- Initial repository structure with `skills/` directory
- Example skills: `angular-code-review`, `git-commit-helper`
- `skills/manifest.json` skill index
- `scripts/validate-skill.sh` — validate SKILL.md frontmatter and structure
- `scripts/install.sh` — install skills to personal or project directories (symlink/copy)
- Project specification in `PROJECT_PLAN.md`
- README with quick start guide
