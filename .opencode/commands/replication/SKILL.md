---
name: replication
description: Plan or execute a replication of a paper, claim, or benchmark. Use when the user asks to replicate results, reproduce an experiment, verify a claim empirically, or build a replication package.
---

# Replication

Run the `/replicate` workflow. The slash command expands the full workflow instructions in the active session; do not try to read a relative prompt-template path from the installed skill directory.

Agents used: `researcher`

Asks the user to choose an execution environment (local, virtual env, cloud, or plan-only) before running any code.

Output: replication plan, scripts, and results saved to disk.
