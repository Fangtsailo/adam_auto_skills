# Changelog

All notable changes to this project will be documented in this file.

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
- Project specification in `initial.md`
- README with quick start guide
