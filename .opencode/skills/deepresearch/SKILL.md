---
name: deepresearch
description: Run a thorough, source-heavy investigation on a topic and produce a durable research brief with inline citations.
compatibility: opencode
metadata:
  args: <topic>
  section: Research Workflows
---

# Deep Research

Run deep research for the user's topic.

This is an execution request, not a request to explain or implement the workflow instructions. Execute the workflow. Do not answer by describing the protocol, do not explain these instructions, and do not restate the protocol. First action must be: run `.opencode/skills/deepresearch/scripts/deepresearch-artifacts.sh init --topic "<topic>"`. Use the emitted `slug` and paths for the rest of the workflow, then update the created plan artifact with the actual plan content.

## Artifact Contract

Derive a short slug from the topic: lowercase, hyphenated, no filler words, at most 5 words.

Before plan approval, the only required artifact is:

- `outputs/.plans/<slug>.md`

After the user approves the plan, the run must leave these files on disk, even if some capabilities fail:

- `outputs/.drafts/<slug>-draft.md`
- `outputs/.drafts/<slug>-cited.md`
- `outputs/<slug>.md` or `papers/<slug>.md`
- `outputs/<slug>.provenance.md` or `papers/<slug>.provenance.md`

If the user does not approve the plan, do not create placeholder draft, cited, final, or provenance files.

After the user approves the plan, if any capability fails, continue in degraded mode and still write a blocked or partial final output and provenance sidecar. Never end with chat-only output after plan approval. Never end with only an explanation in chat after plan approval. Use `Verification: BLOCKED` when verification could not be completed.

## Step 1: Plan

Run `.opencode/skills/deepresearch/scripts/deepresearch-artifacts.sh init --topic "<topic>"` immediately, then update `outputs/.plans/<slug>.md`. The plan must include:

- Key questions
- Evidence needed
- Scale decision
- Task ledger
- Verification log
- Decision log

Before asking for confirmation, run `.opencode/skills/deepresearch/scripts/deepresearch-artifacts.sh verify --slug <slug> --phase pre-approval`.

Make the scale decision before assigning owners in the plan. If the topic is a narrow "what is X" explainer, the plan must use lead-owned direct search tasks only; do not allocate researcher agents in the task ledger.

If a memory tool is available, also save the plan using key `deepresearch.<slug>.plan`. If no memory tool is available, continue without it.

After writing the plan, stop and ask for explicit confirmation before gathering evidence. Summarize the plan briefly and ask:

`Proceed with this deep research plan? Reply "yes" to continue, or tell me what to change.`

Do not run searches, fetch sources, spawn agents, draft, cite, review, or deliver final artifacts until the user confirms. If the user requests changes, update `outputs/.plans/<slug>.md` first, then ask for confirmation again.

## Step 2: Scale

Use direct search for:

- Single fact or narrow question, including "what is X" explainers
- Work you can answer with 3-10 tool calls

For "what is X" explainer topics, do not spawn researcher agents unless the user explicitly asks for comprehensive coverage, current landscape, benchmarks, or production deployment. Do not inflate a simple explainer into a multi-agent survey.

Use researcher agents only when decomposition clearly helps:

- Direct comparison of 2-3 items: 2 `researcher` agents
- Broad survey or multi-faceted topic: 3-4 `researcher` agents
- Complex multi-domain research: 4-6 `researcher` agents

## Step 3: Gather Evidence

Use only tool names visible in the current tool set. For web work, use available search and fetch tools; never call tool names that are not exposed in the current session.

Avoid crash-prone PDF parsing in this workflow. Do not fetch `.pdf` URLs unless the user explicitly asks for PDF extraction. Prefer paper metadata, abstracts, HTML pages, official docs, and web snippets. If only a PDF exists, cite the PDF URL from search metadata and mark full-text PDF parsing as blocked instead of fetching it.

If direct search was chosen:

- Skip researcher spawning entirely.
- Search and fetch sources yourself.
- Use multiple search terms or angles before drafting. Minimum: 3 distinct queries for direct-mode research, covering definition/history, mechanism/formula, and current usage/comparison when relevant.
- Record the exact search terms used in `outputs/.drafts/<slug>-research-direct.md`.
- Write notes to `outputs/.drafts/<slug>-research-direct.md`.
- Continue to synthesis.

If researcher agents were chosen:

- After choosing the researcher count, run `.opencode/skills/deepresearch/scripts/deepresearch-artifacts.sh researcher-files --slug <slug> --count <N>`, then update each generated `outputs/.plans/<slug>-T<N>.md` brief with the actual assignment.
- Use the unique research output paths emitted by the script, such as `outputs/.drafts/<slug>-research-T1.md`.
- Keep `task` tool prompts concise and valid.
- Do not name exact tool commands in researcher tasks unless those tool names are visible in the current tool set.
- Prefer broad guidance such as "use paper search and web search"; if a PDF parser or paper fetch fails, the researcher must continue from metadata, abstracts, and web sources and mark PDF parsing as blocked.
- If the task tool or researcher agent is unavailable or fails, continue lead-owned with available search/fetch tools, record the degraded mode in the plan ledger, and proceed with a blocked or partial draft.

Example task shape:

```text
Use the task tool with subagent_type "researcher". Prompt the agent to read outputs/.plans/<slug>-T1.md and write outputs/.drafts/<slug>-research-T1.md. Ask it to return only a one-line completion summary.
```

After evidence gathering, update the plan ledger and verification log. If research failed, record exactly what failed and proceed with a blocked or partial draft.

## Step 4: Draft

Write the report yourself. Do not delegate synthesis.

Save to `outputs/.drafts/<slug>-draft.md`.

Include:

- Executive summary
- Findings organized by question/theme
- Evidence-backed caveats and disagreements
- Open questions
- No invented sources, results, figures, benchmarks, images, charts, or tables

Before citation, sweep the draft:

- Every critical claim, number, figure, table, or benchmark must map to a source URL, research note, raw artifact path, or command/script output.
- Remove or downgrade unsupported claims.
- Mark inferences as inferences.

## Step 5: Cite

If direct search/no researcher agents was chosen:

- Do citation yourself.
- Verify reachable HTML/doc URLs with available fetch/search tools.
- Copy or rewrite `outputs/.drafts/<slug>-draft.md` to `outputs/.drafts/<slug>-cited.md` with inline citations and a Sources section.
- Do not spawn the `verifier` agent for simple direct-search runs.

If researcher agents were used, run the `verifier` agent after the draft exists. This step is mandatory when the task tool and verifier agent are available, and must complete before any reviewer runs. Do not run the `verifier` and `reviewer` in the same parallel task call. If the task tool or verifier agent is unavailable or fails, do citation yourself with available search/fetch tools, write `outputs/.drafts/<slug>-cited.md`, and mark verification as `BLOCKED` or `PASS WITH NOTES`.

Use the task tool with subagent_type `verifier`. Ask the agent to add inline citations to `outputs/.drafts/<slug>-draft.md` using the research files as source material, verify every URL, and write the complete cited brief to `outputs/.drafts/<slug>-cited.md`.

After the verifier returns, verify on disk that `outputs/.drafts/<slug>-cited.md` exists. If the verifier wrote elsewhere, find the cited file and move or copy it to `outputs/.drafts/<slug>-cited.md`.

## Step 6: Review

If direct search/no researcher agents was chosen:

- Review the cited draft yourself.
- Write `outputs/.drafts/<slug>-verification.md` with FATAL / MAJOR / MINOR findings and the checks performed.
- Fix FATAL issues before delivery.
- Do not spawn the `reviewer` agent for simple direct-search runs.

If researcher agents were used, only after `outputs/.drafts/<slug>-cited.md` exists, run the `reviewer` agent against it when the task tool and reviewer agent are available. If the task tool or reviewer agent is unavailable or fails, review the cited draft yourself and record the limitation in `outputs/.drafts/<slug>-verification.md`.

Use the task tool with subagent_type `reviewer`. Ask the agent to verify `outputs/.drafts/<slug>-cited.md`, flag unsupported claims, logical gaps, single-source critical claims, and overstated confidence, then write `outputs/.drafts/<slug>-verification.md`.

If the reviewer flags FATAL issues, fix them before delivery and run one more review pass. Note MAJOR issues in Open Questions. Accept MINOR issues.

When applying reviewer fixes, do not issue one giant edit with many replacements. Use small localized edits only for 1-3 simple corrections. For section rewrites, table rewrites, or more than 3 substantive fixes, write a corrected full file to `outputs/.drafts/<slug>-revised.md` instead.

After applying reviewer, verifier, audit, or PI-style fixes, run an explicit on-disk verification before saying the fixes landed. Use targeted reads or shell checks to prove the old unsupported wording is gone and the replacement wording exists. Provenance may only say an issue was fixed when this post-edit verification passed.

The final candidate is `outputs/.drafts/<slug>-revised.md` if it exists; otherwise it is `outputs/.drafts/<slug>-cited.md`.

## Step 7: Deliver

Use `.opencode/skills/deepresearch/scripts/deepresearch-artifacts.sh provenance --slug <slug> --dest outputs|papers --verification PASS|PASS_WITH_NOTES|BLOCKED`, then fill in the provenance details. Use `.opencode/skills/deepresearch/scripts/deepresearch-artifacts.sh deliver --slug <slug> --dest outputs|papers` to copy the final candidate to:

- `papers/<slug>.md` for paper-style drafts
- `outputs/<slug>.md` for everything else

Write provenance next to it as `<slug>.provenance.md`:

```markdown
# Provenance: [topic]

- **Date:** [date]
- **Rounds:** [number of research rounds]
- **Sources consulted:** [count and/or list]
- **Sources accepted:** [count and/or list]
- **Sources rejected:** [dead, unverifiable, or removed]
- **Verification:** [PASS / PASS WITH NOTES / BLOCKED]
- **Plan:** outputs/.plans/<slug>.md
- **Research files:** [files used]
```

Before responding, run `.opencode/skills/deepresearch/scripts/deepresearch-artifacts.sh verify --slug <slug> --phase post-approval --dest outputs|papers`. If verification could not be completed, set `Verification: BLOCKED` or `PASS WITH NOTES` and list the missing checks.

Final response should be brief: link the final file, provenance file, and any blocked checks.
