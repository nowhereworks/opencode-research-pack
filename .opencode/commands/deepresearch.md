---
name: deepresearch
description: Run a thorough, source-heavy investigation on any topic. Use when the user asks for deep research, a comprehensive analysis, an in-depth report, or a multi-source investigation. Produces a cited research brief with provenance tracking.
---

# Deep Research

Call the `skill` tool with name `deepresearch`.

User arguments: `$ARGUMENTS`

After the skill loads, execute its workflow using the user arguments. If no topic was provided, ask one concise question for the topic before proceeding.

Agents used: `researcher`, `verifier`, `reviewer`

Output: cited brief in `outputs/` with `.provenance.md` sidecar.
