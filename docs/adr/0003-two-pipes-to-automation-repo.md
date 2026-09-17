---
status: accepted
---

# Two pipes to the Automation repo; `bin/skill` does neither

A Target (`web-fe-next`) must use `swpm-automation` without merging repos or copying secrets. We use two pipes: Sibling exec for Automation capabilities (CLI runs in the Automation repo; the human Present is the Target chat), and SWE copy for the SWE Bundle (human follows the Automation repo's reuse docs into the Target `.agents/`). `bin/skill` stays the Catalog installer: it does not install `ext-*` / `pjm-*` / `ekb-*` and does not perform SWE copy.

## Considered Options

- **One pipe: run everything in the Automation repo** — rejected: `swe-implement-*` would edit the wrong codebase
- **`bin/skill install` also copies the SWE Bundle or vendors `ext-*`** — rejected: third landlord on `.agents/` / Catalog sync drift; fights ADR 0001
- **Copy CLI, CA, and API keys into the Target** — rejected: already ADR 0002

## Consequences

- A Target that wants both pipes needs three steps: `npx skills add mattpocock/skills`, `./bin/skill install --project <path> --copy`, then SWE copy from the Automation repo
- SWE skills run when named; unmatched Catalog asks still Wrap `ask-matt` (ADR 0001)
- Automation-capability query tmp stays in the Automation repo; that is not Present
