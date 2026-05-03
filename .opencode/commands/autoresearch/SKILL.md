---
name: autoresearch
description: Autonomous experiment loop that tries ideas, measures results, keeps what works, and discards what doesn't. Use when the user asks to optimize a metric, run an experiment loop, improve performance iteratively, or automate benchmarking.
---

# Autoresearch

Run the `/autoresearch` workflow. The slash command expands the full workflow instructions in the active session; do not try to read a relative prompt-template path from the installed skill directory.

Tools used: `init_experiment`, `run_experiment`, `log_experiment` (from pi-autoresearch)

Session files: `autoresearch.md`, `autoresearch.sh`, `autoresearch.jsonl`
