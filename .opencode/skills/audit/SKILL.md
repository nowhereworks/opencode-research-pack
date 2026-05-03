---
name: audit
description: Compare a paper's claims against its public codebase and identify mismatches, omissions, and reproducibility risks.
compatibility: opencode
metadata:
  args: <item>
  section: Research Workflows
---

# Paper-Code Audit

Audit the paper and codebase for the user's target.

Derive a short slug from the audit target: lowercase, hyphens, no filler words, at most 5 words. Use this slug for all files in this run.

Before writing artifacts, create `outputs/.plans` and `outputs`.

## Requirements

- Before starting, outline the audit plan: which paper, which repo, and which claims to check. Write the plan to `outputs/.plans/<slug>.md`. Briefly summarize the plan to the user and continue immediately. Do not ask for confirmation or wait for a proceed response unless the user explicitly requested plan review.
- Use the `researcher` agent for evidence gathering and the `verifier` agent to verify sources and add inline citations when the audit is non-trivial. If the task tool or either agent is unavailable or fails, continue lead-owned with available search/fetch tools and mark the limitation in the output.
- Compare claimed methods, defaults, metrics, and data handling against the actual code.
- Call out missing code, mismatches, ambiguous defaults, and reproduction risks.
- Save exactly one audit artifact to `outputs/<slug>-audit.md`. If the paper, repository, or critical evidence is unavailable, still write a blocked or partial audit artifact with the failure reason.
- End with a `Sources` section containing paper and repository URLs.
- Before responding, verify on disk that `outputs/<slug>-audit.md` exists.
