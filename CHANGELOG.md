# Changelog

All notable changes to this project will be documented in this file.

## [1.4.0] - 2026-06-04

### Added

- Skill `angular-dev-core-rules`: strict i18n, functional programming, declarative patterns, and purposeful comments (with `reference.md`)

### Changed

- `angular-dev-core-rules`: soften absolute bans; clarify scope vs `angular-code-review`; API-agnostic i18n and flexible subscribe/DOM guidance

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
