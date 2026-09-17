# Target ↔ Automation

How a Target uses the Automation repo: Sibling exec of an Automation capability, a Combo, Present, and SWE copy. Not a handoff document. Not Catalog vs Agent install mechanics. Not one Redmine issue's Scratch issue.

## Language

**Automation repo**:
The repo that owns external-system CLIs, CAs, and API keys. On this team that repo is `swpm-automation`.
_Avoid_: Target project, Catalog, adam_auto_skill

**Automation capability**:
An `ext-*`, `pjm-*`, or `ekb-*` skill that lives in the Automation repo. It reaches Redmine, GitLab, Outline, Teams, Grafana, or company identity maps.
_Avoid_: SWE Bundle, Catalog skill, 全部功能

**SWE Bundle**:
The `swe-*` skills, personas, and rules that originate in the Automation repo. After SWE copy they run in the Target, against the Target's files.
_Avoid_: Automation capability, Sibling exec, Catalog skill, Agent skill

**SWE copy**:
Placing the SWE Bundle into the Target so those skills run there. Distinct from install and from restoring Agent skills.
_Avoid_: install, npx skills, Sibling exec, `bin/skill`

**Sibling exec**:
Running an Automation capability in the Automation repo while the Target remains the edit workspace and the human's Cursor session.
_Avoid_: 互動, 整合, 依賴, copying the CLI or API key into the Target, installing Automation capabilities with `bin/skill`, running the SWE Bundle in the Automation repo

**Combo**:
A Catalog skill that Sibling-execs Automation capabilities, then performs Target-only steps those capabilities do not own. `zyxel-rm-analyze` is one: fetch via `ext-redmine-cli`, then FE verdict, Scratch issue, and Implement gate.
_Avoid_: a second integration with the Automation repo, inlining the CLI, replacing `pjm-redmine-custom`

**Present**:
What the human reads in the Target Cursor session. Automation capability queries stay in chat; their CLI tmp stays in the Automation repo. Combo RM attachments are Target files.
_Avoid_: copying every CLI dump into the Target
