---
name: watch
description: Set up a recurring or deferred research watch on a topic, company, paper area, or product surface.
compatibility: opencode
metadata:
  args: <topic>
  section: Research Workflows
---

# Watch

Create a research watch for the user's topic.

Derive a short slug from the watch topic: lowercase, hyphens, no filler words, at most 5 words. Use this slug for all files in this run.

## Requirements

- Before starting, outline the watch plan: what to monitor, what signals matter, what counts as a meaningful change, and the check frequency. Write the plan to `outputs/.plans/<slug>.md`. Briefly summarize the plan to the user and continue immediately. Do not ask for confirmation or wait for a proceed response unless the user explicitly requested plan review.
- Start with a baseline sweep of the topic.
- Use available scheduling tooling to create the recurring or delayed follow-up instead of merely promising to check later. If `pi-schedule-prompt` is installed, use it. If no scheduling tool is available, write the exact blocked scheduling step in the baseline artifact.
- Save exactly one baseline artifact to `outputs/<slug>-baseline.md`.
- End with a `Sources` section containing direct URLs for every source used.
