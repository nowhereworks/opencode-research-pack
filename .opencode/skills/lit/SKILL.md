---
name: lit
description: Run a literature review on a topic using paper search and primary-source synthesis.
compatibility: opencode
metadata:
  args: <topic>
  section: Research Workflows
---

# Literature Review

Investigate the user's topic as a literature review.

Derive a short slug from the topic: lowercase, hyphens, no filler words, at most 5 words. Use this slug for all files in this run.

Before writing artifacts, create `outputs/.plans`, `outputs/.drafts`, and `outputs`.

## Workflow

1. Plan: outline the scope, key questions, source types to search, time period, expected sections, a small task ledger, and a verification log. Write the plan to `outputs/.plans/<slug>.md`. Briefly summarize the plan to the user and continue immediately. Do not ask for confirmation or wait for a proceed response unless the user explicitly requested plan review.
2. Gather: use the `researcher` agent via the task tool when the sweep is wide enough to benefit from delegated paper triage before synthesis. Use unique researcher output paths such as `outputs/.drafts/<slug>-research-T1.md`. For narrow topics, or if the task tool or researcher agent is unavailable or fails, search directly and record the degraded path in the verification log. Do not silently skip assigned questions; mark them `done`, `blocked`, or `superseded`.
3. Synthesize: separate consensus, disagreements, and open questions. When useful, propose concrete next experiments or follow-up reading. Generate charts only when an explicit charting tool is available and the quantitative data is source-backed. Use Mermaid diagrams for taxonomies or method pipelines only when the structure is supported by sources. Before finishing the draft, sweep every strong claim against the verification log and downgrade anything that is inferred or single-source critical.
4. Cite: use the `verifier` agent to add inline citations and verify every source URL in the draft. If the task tool or verifier agent is unavailable or fails, do citation yourself with available search/fetch tools and mark verification as `BLOCKED` or `PASS WITH NOTES`.
5. Verify: use the `reviewer` agent to check the cited draft for unsupported claims, logical gaps, zombie sections, and single-source critical findings. If the task tool or reviewer agent is unavailable or fails, do the review yourself and record the limitation. Fix FATAL issues before delivering. Note MAJOR issues in Open Questions. If FATAL issues were found, run one more verification pass after the fixes when possible.
6. Deliver: save the final literature review to `outputs/<slug>.md`. Write a provenance record alongside it as `outputs/<slug>.provenance.md` listing date, sources consulted vs. accepted vs. rejected, verification status, and intermediate research files used. Before stopping, verify on disk that both files exist; do not stop at an intermediate cited draft alone.
