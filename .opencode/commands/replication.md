---
name: replication
description: Plan or execute a replication of a paper, claim, or benchmark. Use when the user asks to replicate results, reproduce an experiment, verify a claim empirically, or build a replication package.
---

# Replication

Call the `skill` tool with name `replicate`.

User arguments: `$ARGUMENTS`

After the skill loads, execute its workflow using the user arguments. If no paper, claim, or benchmark was provided, ask one concise question for the replication target before proceeding.

Agents used: `researcher` when delegation is available and useful; otherwise lead-owned degraded mode.

Asks the user to choose an execution environment (local, virtual env, cloud, or plan-only) before running any code.

Output: replication plan, scripts, and results saved to disk.
