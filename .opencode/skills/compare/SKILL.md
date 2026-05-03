---
name: compare
description: Compare multiple sources on a topic and produce a source-grounded matrix of agreements, disagreements, and confidence.
compatibility: opencode
metadata:
  args: <topic>
  section: Research Workflows
---

# Source Comparison

Compare sources for the user's topic.

Derive a short slug from the comparison topic: lowercase, hyphens, no filler words, at most 5 words. Use this slug for all files in this run.

Before writing artifacts, create `outputs/.plans` and `outputs`.

## Requirements

- Before starting, outline the comparison plan: which sources to compare, which dimensions to evaluate, and expected output structure. Write the plan to `outputs/.plans/<slug>.md`. Briefly summarize the plan to the user and continue immediately. Do not ask for confirmation or wait for a proceed response unless the user explicitly requested plan review.
- Use the `researcher` agent to gather source material when the comparison set is broad, and the `verifier` agent to verify sources and add inline citations to the final matrix. If the task tool or either agent is unavailable or fails, continue lead-owned with available search/fetch tools and mark the limitation in the output.
- Build a comparison matrix covering source, key claim, evidence type, caveats, and confidence.
- Generate charts only when the comparison involves source-backed quantitative metrics and an explicit charting tool is available. Use Mermaid for method or architecture comparisons only when source-supported.
- Distinguish agreement, disagreement, and uncertainty clearly.
- Save exactly one comparison to `outputs/<slug>-comparison.md`. If required evidence cannot be gathered, still write a blocked or partial comparison artifact with the failure reason.
- End with a `Sources` section containing direct URLs for every source used.
- Before responding, verify on disk that `outputs/<slug>-comparison.md` exists.
