# RM analyze

Reading one Redmine issue into a Target project's Scratch issue, then stopping at the Implement gate. Not a handoff document. Not Catalog vs Agent install mechanics.

**Sibling exec**, **Combo**, **Present**: [Target ↔ Automation](../target-automation/CONTEXT.md).

## Language

**RM**:
A Nebula Redmine issue identified as `RM-<digits>`.
_Avoid_: 需求規格（給後端）, Outline page, Scratch issue

**Scratch issue**:
The markdown work item at `.scratch/RM-<digits>/issues/01-analyze.md` in the Target project. It is the analysis SSOT.
_Avoid_: RM, spec.md, 把 RM 當成本地工單

**Implement gate**:
The stop after the Scratch issue is written. Application code changes wait for a later `/implement`.
_Avoid_: 讀完直接改碼
