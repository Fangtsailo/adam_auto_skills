# Context Map

## Contexts

- [Handoff documents](./CONTEXT.md): names of documents this repo's skills produce, their readers, and the shared writing rules
- [Skill distribution](./docs/skill-distribution/CONTEXT.md): Catalog vs Agent skills, the Router, and how a target project gets both
- [RM analyze](./docs/rm-analyze/CONTEXT.md): RM, Scratch issue, Implement gate
- [Target ↔ Automation](./docs/target-automation/CONTEXT.md): Sibling exec, Combo, Present, SWE copy

## Relationships

- **Handoff documents → Skill distribution**: the Router (`ask-adam`) uses the Handoff glossary to match Documents rows; unmatched asks Wrap `ask-matt`
- **Skill distribution does not own document names**: 畫面操作說明 / 測試項目 / 需求規格（給後端） / TD Detail stay in the Handoff context
- **RM analyze → Skill distribution**: `zyxel-rm-analyze` is a Catalog skill; the Router's RM table Matches it; install places it on a Target project
- **RM analyze Combo → Target ↔ Automation**: `zyxel-rm-analyze` Sibling-execs `ext-redmine-cli`, then writes a Target Scratch issue and stops at the Implement gate
- **Automation table → `zyxel-automation`**: Catalog skill that Sibling-execs `pjm-*` and `ext-*` except `ext-mise-file-task`; it Wraps `pjm-redmine-custom`; it is not the RM Combo
- **SWE copy is a human step** following the Automation repo's SWE Bundle reuse docs; `bin/skill` does not do it
- **Skill distribution Menu-first tables**: Documents / Git / Review / Plan / RM / Automation
- **SWE Bundle → Target**: SWE copy into the Target; not Sibling exec, not install, not an Agent skill restore
- **Skill distribution ↛ Automation repo**: `bin/skill` does not place `ext-*` / `pjm-*` / `ekb-*` and does not perform SWE copy
- **Router stays `ask-adam`**: Catalog menus win; unmatched Wrap `ask-matt`; SWE skills run when named; SWE rules may be always-on after SWE copy
- **RM analyze ↛ Handoff documents**: RM is not 需求規格（給後端）

## Decisions

- [0001](./docs/adr/0001-ask-adam-wraps-ask-matt.md): Router Wraps `ask-matt`; Agent skills stay on npx
- [0002](./docs/adr/0002-sibling-exec-redmine.md): Combo Sibling-execs Redmine CLI; does not Wrap `pjm-redmine-custom`
- [0003](./docs/adr/0003-two-pipes-to-automation-repo.md): two pipes; `bin/skill` does neither
- [0004](./docs/adr/0004-zyxel-automation-wraps-pjm.md): `zyxel-automation` Wraps pjm and ext except mise
