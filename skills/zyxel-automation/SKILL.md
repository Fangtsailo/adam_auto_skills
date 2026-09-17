---
name: zyxel-automation
description: >-
  Automation: Sibling-exec GitLab, Outline, Teams, Grafana, to-be-pulled.
---

# Zyxel Automation

Read [CONTEXT.md](CONTEXT.md) for **Sibling exec**, **Automation capability**, **Present**, **Combo**.

Chat: Traditional Chinese. Identifiers: English. Output shape: `/i-have-adhd`.

## Workflow

Copy and track:

```
Automation Progress:
- [ ] 1. Combo hand-off
- [ ] 2. Match
- [ ] 3. Sibling exec
- [ ] 4. Present
```

Done: Combo path → `zyxel-rm-analyze`'s completion criterion. Else → the Wrapped skill is complete, step 4's chat is sent, and this run's Target diff has no application code and no new dump under Target `tmp/`.

### 1. Combo hand-off

`讀 RM` or `RM-#####` as one-issue analyze → read [zyxel-rm-analyze](../zyxel-rm-analyze/SKILL.md) and Follow it to **that** skill's completion criterion. Skip steps 2–4.

Done: Combo complete, or this ask is not Combo.

### 2. Match

Pick exactly one Wrap below. Two rows fit → ask **one** question. A pjm row and its ext CLI both fit → the pjm row.

| Need | Wrap |
|---|---|
| Redmine query: to be pulled, RM↔MR, open bugs, target versions | `pjm-redmine-custom` |
| GitLab / MR | `pjm-glab-custom` |
| Outline | `pjm-outline-custom` |
| To-be-pulled Teams notify | `pjm-notify-to-be-pulled-teams` |
| MR-reviewer Teams notify | `pjm-notify-mr-reviewers-teams` |
| Grafana | `ext-debug-with-grafana` |

No pjm/Grafana row, but the user asked a listed CLI → Wrap that CLI: `ext-redmine-cli`, `ext-glab-cli`, `ext-outline-cli`, `ext-send-teams-workflow`.

No row → say so. Stop.

Done: one Wrap name, or a question and stop.

### 3. Sibling exec

Automation root, first match:

1. `$SWPM_AUTOMATION_ROOT` if it contains `.agents/skills/<Wrap>/SKILL.md`
2. `../swpm-automation` from the workspace root, same file present

No match → tell the user to set `SWPM_AUTOMATION_ROOT`. Stop.

Read that `SKILL.md` and Follow it. Cwd = the automation root. Further Follows it names (`ext-*`, `ekb-username-shorthand`) use the same root.

CLI or auth error → stop with the error.

Done: Wrapped skill complete, or an error and stop.

### 4. Present

Lead with the answer in this Target chat.

Done: that chat is sent.
