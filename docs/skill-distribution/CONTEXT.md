# Skill Distribution

How this repo's skills reach a target project, and which Router the user types. Not the handoff documents themselves — those live in the root `CONTEXT.md`.

## Language

**Catalog skill**:
A skill that lives in this repo's `skills/` and is placed by `bin/skill` into `.cursor/skills`.
_Avoid_: 內建 skill, official skill, adam skill

**Agent skill**:
A skill restored by `npx skills` from `mattpocock/skills` into `.agents/skills`, pinned by `skills-lock.json`.
_Avoid_: .agents skill, 同步過來的 skill, SWE Bundle, Catalog skill

**Router**:
The one user-invoked skill that picks which other skill or flow to run. In this repo that is `ask-adam`.
_Avoid_: 入口, dispatcher, 整合 skill, 第二扇門

**Wrap**:
A skill reads another skill's `SKILL.md` and Follows it, without editing that file. The Router Wraps `ask-matt`. A Combo Wraps Automation capabilities. `zyxel-automation` Wraps `pjm-*` and `ext-*` except `ext-mise-file-task`.
_Avoid_: merge, fork, 合成一份, 整合進 SKILL.md, Follow 當另一個動詞

**Menu-first**:
The Router's Catalog tables (Documents / Git / Review / Plan / RM / Automation) win when they match. Review defaults to `angular-code-review`. RM `讀 RM-#####` follows `zyxel-rm-analyze`. Automation follows `zyxel-automation`. Anything else follows the Wrapped `ask-matt`. One sentence that could be a Catalog plan or idea-to-ship → one question.
_Avoid_: 地圖優先, 永遠先問

**Target project**:
A repo that should have both the Router and Agent skills, so `/ask-adam` can Wrap `ask-matt` there.
_Avoid_: 同步目標

**install**:
First-time placement of Catalog skills onto a target with `bin/skill install`. Agent skills are not installed this way. SWE copy is not install.
_Avoid_: 同步, SWE copy

**sync**:
Re-copy Catalog skills that are already installed. Not an Agent-skill update.
_Avoid_: 同步 mattpocock, npx skills update
