---
status: accepted
---

# Sibling exec for Redmine; do not copy the CLI into the FE repo

`zyxel-rm-analyze` runs in a Target project (`web-fe-next`) but must fetch RM bodies from Nebula Redmine. Putting `redmine`, the CA, and `REDMINE_API_KEY` into the FE repo would duplicate toolchain and secrets. Inlining the CLI command table in the Catalog skill would drift from `ext-redmine-cli`. We Sibling-exec: resolve `SWPM_AUTOMATION_ROOT` (else `../swpm-automation`), Wrap that repo's `ext-redmine-cli/SKILL.md`, and keep file edits in the Target project.

## Considered Options

- **Copy CLI + key into `web-fe-next`** — rejected: second mise tool and secret surface
- **Inline `redmine issues get` in the Catalog skill** — rejected: forks from `ext-redmine-cli`
- **Vendor `ext-redmine-cli` into this Catalog** — rejected: two SSOT
- **Multi-root Cursor workspace** — rejected: brittle session layout

## Consequences

- The automation repo must be on disk next to the Target project, or `SWPM_AUTOMATION_ROOT` must be set
- Attachments download into the Target project's `tmp/RM-<digits>/`, not the automation `tmp/`
- `pjm-redmine-custom` stays in the automation repo; this skill does not Wrap it
