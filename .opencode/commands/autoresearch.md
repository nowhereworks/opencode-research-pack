---
name: autoresearch
description: Assisted experiment loop that tries ideas, measures results, and keeps the best validated changes when tooling and user approvals allow. Use when the user asks to optimize a metric, run an experiment loop, improve performance iteratively, or automate benchmarking.
---

# Autoresearch

Call the `skill` tool with name `autoresearch`.

User arguments: `$ARGUMENTS`

After the skill loads, execute its workflow using the user arguments. If no idea was provided, ask one concise question for the optimization idea before proceeding.

Tools used when available: `init_experiment`, `run_experiment`, `log_experiment` from pi-autoresearch.

Session files: `autoresearch.md`, `autoresearch.sh`, `autoresearch.jsonl`
