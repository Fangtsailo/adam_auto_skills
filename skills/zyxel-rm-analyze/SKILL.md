---
name: zyxel-rm-analyze
description: >-
  RM: Scratch issue from one Redmine issue, then Implement gate. Use when the
  user says 讀 RM or RM-#####.
---

# Zyxel RM Analyze

Read [CONTEXT.md](CONTEXT.md) for **RM**, **Scratch issue**, **Implement gate**, **Sibling exec**.

Scratch issue and chat: Traditional Chinese. Identifiers: English.

## Workflow

Copy and track:

```
RM Progress:
- [ ] 1. Resolve one RM id
- [ ] 2. Sibling exec fetch
- [ ] 3. FE verdict
- [ ] 4. Write Scratch issue
- [ ] 5. Implement gate
```

Done when the Scratch issue has every template heading, step 5's chat is sent, and this run's diff has no application code.

### 1. Resolve one RM id

Parse `RM-<digits>` or `/issues/<digits>`. Drop `RM-00000`.

- Zero ids → ask for one RM. Stop.
- Two or more distinct ids → ask which one. Stop.

Done: exactly one id, or a question and stop.

### 2. Sibling exec fetch

Automation root, first match:

1. `$SWPM_AUTOMATION_ROOT` if it contains `.agents/skills/ext-redmine-cli/SKILL.md`
2. `../swpm-automation` from the workspace root, same file present

No match → tell the user to set `SWPM_AUTOMATION_ROOT`. Stop.

Read that `ext-redmine-cli/SKILL.md` and Follow it for get, journals, and attachments. Cwd = the automation root.

Download attachments to workspace `tmp/RM-<digits>/` (absolute path). Read every file there (images included) before step 3. Empty dir = none.

CLI or auth error → stop with the error. The RM body comes from this fetch.

Done: issue body in hand; every attachment read, or none.

### 3. FE verdict

Search the workspace for the behavior the RM describes.

- **FE:** at least one path in this repo that explains the defect.
- **不是 FE:** backend-only, infra-only, or no such path — with the reason.

Done: one of those two, with paths or the reason.

### 4. Write Scratch issue

Path: `.scratch/RM-<digits>/issues/01-analyze.md`.

Exists → keep the body; append under `## Comments` what this fetch changed. Change `Status:` only when the FE verdict changed.

New file:

```markdown
# RM-<digits>: <subject>

Status: <needs-triage | wontfix>
Source: <redmine issue URL>

## FE 判定
<FE | 不是 FE> — <one-paragraph why>

## RM 事實
- Subject:
- Status:
- Description:
- Journals that change the conclusion:
- Attachments: <tmp/RM-<digits>/ paths or none>

## 嫌疑路徑
- <workspace paths, or 「無（不是 FE）」>

## 未知項
- <missing repro, missing env, unread attachment, or 「無」>

## Implement gate
尚未 `/implement`
```

- FE → `Status: needs-triage` and at least one workspace path.
- 不是 FE → `Status: wontfix` and 嫌疑路徑 `無（不是 FE）`.

Done: that path exists; every heading present; `Status:` matches the verdict.

### 5. Implement gate

This skill ends here. `/implement` is a later turn, including when the same message already asked to fix.

Lead with: 若要改碼，下 `/implement`；否則停在這裡.

Then: Scratch issue path, FE 判定, 嫌疑路徑, 未知項.

不是 FE → 到這裡結束；下一步是換票或停.

Done: that chat is sent.
