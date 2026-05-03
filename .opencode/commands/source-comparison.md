---
name: source-comparison
description: Compare multiple sources on a topic and produce a grounded comparison matrix. Use when the user asks to compare papers, tools, approaches, frameworks, or claims across multiple sources.
---

# Source Comparison

Call the `skill` tool with name `compare`.

User arguments: `$ARGUMENTS`

After the skill loads, execute its workflow using the user arguments. If no topic or sources were provided, ask one concise question for the comparison target before proceeding.

Agents used: `researcher`, `verifier`

Output: comparison matrix in `outputs/`.
