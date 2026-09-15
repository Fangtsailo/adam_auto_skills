# Context Map

## Contexts

- [Handoff documents](./CONTEXT.md): names of documents this repo's skills produce, their readers, and the shared writing rules
- [Skill distribution](./docs/skill-distribution/CONTEXT.md): Catalog vs Agent skills, the Router, and how a target project gets both
- [RM analyze](./docs/rm-analyze/CONTEXT.md): RM, Scratch issue, Implement gate, Sibling exec

## Relationships

- **Handoff documents → Skill distribution**: the Router (`ask-adam`) uses the Handoff glossary to match Documents rows; unmatched asks Wrap `ask-matt`
- **Skill distribution does not own document names**: 畫面操作說明 / 測試項目 / 需求規格（給後端） / TD Detail stay in the Handoff context
- **RM analyze → Skill distribution**: `zyxel-rm-analyze` is a Catalog skill; the Router's RM table Matches it; install places it on a Target project
- **RM analyze ↛ Handoff documents**: RM is not 需求規格（給後端）
- **Skill distribution Menu-first tables**: Documents / Git / Review / Plan / RM
