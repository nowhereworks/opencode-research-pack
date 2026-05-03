---
name: paper-writing
description: Turn research findings into a polished paper-style draft with sections, equations, and citations. Use when the user asks to write a paper, draft a report, write up findings, or produce a technical document from collected research.
---

# Paper Writing

Call the `skill` tool with name `draft`.

User arguments: `$ARGUMENTS`

After the skill loads, execute its workflow using the user arguments. If no topic or source material was provided, ask one concise question for the draft target before proceeding.

Agents used: `writer`, `verifier`

Output: paper draft in `papers/`.
