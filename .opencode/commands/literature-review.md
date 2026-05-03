---
name: literature-review
description: Run a literature review using paper search and primary-source synthesis. Use when the user asks for a lit review, paper survey, state of the art, or academic landscape summary on a research topic.
---

# Literature Review

Call the `skill` tool with name `lit`.

User arguments: `$ARGUMENTS`

After the skill loads, execute its workflow using the user arguments. If no topic was provided, ask one concise question for the literature-review topic before proceeding.

Agents used: `researcher`, `verifier`, `reviewer` when delegation is available and useful; otherwise lead-owned degraded mode.

Output: literature review in `outputs/` with `.provenance.md` sidecar.
