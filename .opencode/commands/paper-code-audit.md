---
name: paper-code-audit
description: Compare a paper's claims against its public codebase. Use when the user asks to audit a paper, check code-claim consistency, verify reproducibility of a specific paper, or find mismatches between a paper and its implementation.
---

# Paper-Code Audit

Call the `skill` tool with name `audit`.

User arguments: `$ARGUMENTS`

After the skill loads, execute its workflow using the user arguments. If no paper or repository was provided, ask one concise question for the audit target before proceeding.

Agents used: `researcher`, `verifier` when delegation is available and useful; otherwise lead-owned degraded mode.

Output: audit report in `outputs/`.
