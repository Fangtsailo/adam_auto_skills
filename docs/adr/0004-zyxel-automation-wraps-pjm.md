---
status: accepted
---

# `zyxel-automation` Wraps pjm and ext; the RM Combo does not

The Target needs GitLab / Outline / Teams / Redmine *queries* from a FE Cursor session, without a second typed Router. We add Catalog skill `zyxel-automation`, reached by the Router's Automation table (and by its own description). It Sibling-execs `pjm-*` and `ext-*` except `ext-mise-file-task`, and it Wraps `pjm-redmine-custom`. `zyxel-rm-analyze` stays Adam's Combo for `讀 RM-#####` (FE verdict, Scratch issue, Implement gate) and still does not Wrap `pjm-redmine-custom` — ADR 0002's last bullet is Combo-scoped, not a ban on every Catalog skill.

## Considered Options

- **Delete the Combo; queries and `讀 RM-#####` share one skill** — rejected: Scratch issue and Implement gate are easy to skip inside a query menu
- **Drop Scratch issue and Implement gate** — rejected: those Target-only steps are the Combo
- **Second typed door `/ask-swpm`** — rejected: ADR 0001, one Router
- **Thin Catalog stub per capability** — rejected: Catalog sprawl
- **Include `ext-mise-file-task`** — rejected: Sibling exec cwd would edit mise files in the Automation repo

## Consequences

- `讀 RM-#####` → `zyxel-rm-analyze`; to-be-pulled and other pjm queries → `zyxel-automation`
- Combo RM attachments still land in the Target `tmp/RM-<digits>/`
- `ekb-username-shorthand` is a Wrap dependency of pjm, not its own menu row
