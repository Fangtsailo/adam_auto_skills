# Automations & CI Integration

Use `adam_auto_skill` in CI pipelines, GitHub Actions, or Cursor SDK automations to install and validate skills.

## Install Skills in CI (External Project)

Copy this pattern into your project workflow to install skills from this repo:

```yaml
- name: Install Cursor skills
  run: |
    git clone --depth 1 https://github.com/YOUR_USER/adam_auto_skill.git /tmp/adam_auto_skill
    /tmp/adam_auto_skill/bin/skill install --all --project "${{ github.workspace }}" --copy
```

Or install specific skills only:

```yaml
- name: Install selected skills
  run: |
    git clone --depth 1 https://github.com/YOUR_USER/adam_auto_skill.git /tmp/adam_auto_skill
    /tmp/adam_auto_skill/bin/skill install --project "${{ github.workspace }}" \
      angular-code-review git-commit-helper --copy
```

## Validate This Repository (CI)

This repo's workflow (`.github/workflows/validate.yml`) runs:

```bash
./scripts/validate-skill.sh --all -v
./scripts/generate-skills-md.sh
# fails if SKILLS.md is out of date
```

## Local Script for Other Repos

See [`examples/install-skills-ci.sh`](../examples/install-skills-ci.sh) for a reusable bash script.

## Cursor SDK / Automations

For programmatic Cursor agents (outside the IDE), use the Cursor SDK with a local runtime and point `cwd` at your project:

**TypeScript (one-shot install + prompt):**

```typescript
import { Agent } from "@cursor/sdk";

// 1. Install skills via shell before agent run (CI or setup script)
// 2. Run agent against project with skills in .cursor/skills/

const result = await Agent.prompt(
    "Review this PR using angular-code-review standards",
    {
        apiKey: process.env.CURSOR_API_KEY!,
        model: { id: "composer-2.5" },
        local: { cwd: process.cwd() },
    },
);
```

**Python:**

```python
import os
import subprocess
from cursor_sdk import Agent, AgentOptions, LocalAgentOptions

subprocess.run(
    [
        "/path/to/adam_auto_skill/bin/skill",
        "install",
        "--all",
        "--project",
        os.getcwd(),
        "--copy",
    ],
    check=True,
)

result = Agent.prompt(
    "Review this PR using angular-code-review standards",
    AgentOptions(
        api_key=os.environ["CURSOR_API_KEY"],
        model="composer-2.5",
        local=LocalAgentOptions(cwd=os.getcwd()),
    ),
)
```

### Recommended Automation Flow

1. **Setup:** Clone `adam_auto_skill` or cache it in CI
2. **Install:** `bin/skill install --project <workspace> --copy` (or `--global` for runner-wide)
3. **Validate (optional):** `bin/skill validate --all` in the skills repo
4. **Agent run:** SDK `Agent.prompt` / `agent.send` with `local.cwd` set to the target project
5. **Sync on update:** Re-run install or `bin/skill sync` when skills repo changes

## Pull Third-Party Skills

Register a remote skills repository, then pull individual skills:

```bash
./bin/skill remote add cursor-community https://github.com/org/community-skills.git
./bin/skill pull cursor-community/some-skill
./bin/skill validate some-skill
```

## Submodule Skills (Team Sharing)

For skills maintained in separate repos, use submodules:

```bash
./bin/skill submodule add https://github.com/org/shared-skill.git shared-skill
git add .gitmodules skills/shared-skill skills/manifest.json
```

Team members run:

```bash
git submodule update --init --recursive
./bin/skill install --project . --copy
```
