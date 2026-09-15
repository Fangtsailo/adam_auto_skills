---
status: accepted
---

# ask-adam Wraps ask-matt; Agent skills stay on npx

A target project needs one Router and always-fresh mattpocock skills. Merging `ask-matt` into `ask-adam` would be overwritten by `npx skills update`. Copying `.agents/skills` through `bin/skill` would make every target one sync behind. We Wrap: `/ask-adam` is the only door, Menu-first, and each target project runs `npx skills add|update` itself. `bin/skill` remains the Catalog installer only.

## Considered Options

- **Merge** the two SKILL.md files — rejected: fights always-fresh Agent skills
- **Central copy** via `skill sync --project` — rejected: the target lags the upstream
- **CLI shells out to npx** — rejected: caches two known commands

## Consequences

- A new target needs two commands: `npx skills add mattpocock/skills`, then `./bin/skill install --project <path> --copy`
- `ask-matt` stays untouched; Wrap lives only in `ask-adam`
- After Wrap ships, `/ask-adam` in a target project is a no-op for Agent flows unless that project has `.agents/skills/ask-matt`
