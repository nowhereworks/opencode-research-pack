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

This is an execution request, not a request to explain or implement the workflow instructions. Execute the workflow. Do not answer by describing the protocol, do not explain these instructions, and do not restate the protocol. First action must be: run `.opencode/skills/deepresearch/scripts/deepresearch-artifacts.py init --topic "<topic>"`. Use the emitted `slug` and paths for the rest of the workflow, then update the created plan artifact with the actual plan content. All artifacts for a run must live under the emitted `<slug>/` directory.

## Artifact Contract

Derive a short slug from the topic: lowercase, hyphenated, no filler words, at most 5 words.

Before plan approval, the only required artifact is:

- `<slug>/outputs/.plans/<slug>.md`

After the user approves the plan, the run must leave these files on disk, even if some capabilities fail:

- `<slug>/outputs/.drafts/<slug>-draft.md`
- `<slug>/outputs/.drafts/<slug>-cited.md`
- `<slug>/outputs/.drafts/<slug>-search-log.md`
- `<slug>/outputs/.drafts/<slug>-evidence-matrix.md`
- `<slug>/outputs/.drafts/<slug>-verification.md`
- `<slug>/outputs/<slug>.md` or `<slug>/papers/<slug>.md`
- `<slug>/outputs/<slug>.provenance.md` or `<slug>/papers/<slug>.provenance.md`

If the user does not approve the plan, do not create placeholder draft, cited, final, or provenance files.

After the user approves the plan, if any capability fails, continue in degraded mode and still write a blocked or partial final output and provenance sidecar. Never end with chat-only output after plan approval. Never end with only an explanation in chat after plan approval. Use `Verification: BLOCKED` when quality verification could not be completed.

Script checks are artifact-contract checks only. They prove required files and directories exist; they do not prove source quality, citation support, plan completeness, or research correctness. The model remains responsible for all quality verification.

## Step 1: Plan

Run `.opencode/skills/deepresearch/scripts/deepresearch-artifacts.py init --topic "<topic>"` immediately, then update the emitted plan path, normally `<slug>/outputs/.plans/<slug>.md`. The plan must include:

- Key questions
- Scope defaults
- Evidence needed
- Search coverage matrix
- Scale decision
- Task ledger
- Verification log
- Decision log

Do not ask the user for audience, region, date range, source types, depth, or output destination unless the ambiguity would materially change the answer and no safe default applies. Record assumed defaults in the plan's Decision Log and proceed to approval.

Use these defaults unless the user or topic clearly implies otherwise:

- **Audience:** technically literate generalist; use specialist or academic treatment when the topic or wording implies it.
- **Time range:** current state plus necessary historical context; prioritize the last 24 months for fast-moving topics.
- **Geography:** global; for law, policy, market, tax, healthcare access, or regulation topics, use US/EU/global comparison if no jurisdiction is specified.
- **Source types:** primary sources first, then authoritative secondary analysis.
- **Exclusions:** low-quality SEO pages, unsourced AI-generated content, and social posts unless they are primary evidence.
- **Depth:** infer from request wording; simple explainers use direct mode, while broad/deep/comprehensive/landscape requests use multi-agent mode when useful.
- **Destination:** `outputs`; use `papers` only for paper-style drafts or when the user asks for a manuscript/paper.
- **High-stakes topics:** automatically apply higher scrutiny for medical, legal, finance, safety, security, policy, or welfare-impacting topics.

Before asking for confirmation, run `.opencode/skills/deepresearch/scripts/deepresearch-artifacts.py verify --slug <slug> --phase pre-approval` as an artifact-contract check only.

Make the scale decision before assigning owners in the plan. If the topic is a narrow "what is X" explainer, the plan must use lead-owned direct search tasks only; do not allocate researcher agents in the task ledger.

If a memory tool is available, also save the plan using key `deepresearch.<slug>.plan`. If no memory tool is available, continue without it.

After writing the plan, stop and ask for explicit confirmation before gathering evidence. Summarize the plan briefly and ask:

`Proceed with this deep research plan? Reply "yes" to continue, or tell me what to change.`

Do not run searches, fetch sources, spawn agents, draft, cite, review, or deliver final artifacts until the user confirms. If the user requests changes, update `<slug>/outputs/.plans/<slug>.md` first, then ask for confirmation again.

## Step 2: Scale

Use direct search for:

- Single fact or narrow question, including "what is X" explainers
- Work you can answer with 3-10 tool calls

For "what is X" explainer topics, do not spawn researcher agents unless the user explicitly asks for comprehensive coverage, current landscape, benchmarks, or production deployment. Do not inflate a simple explainer into a multi-agent survey.

Use researcher agents only when decomposition clearly helps:

- Direct comparison of 2-3 items: 2 `researcher` agents
- Broad survey or multi-faceted topic: 2-3 `researcher` agents
- Complex multi-domain research: 3-4 `researcher` agents
- 5-6 `researcher` agents only when the user explicitly asks for exhaustive or comprehensive coverage and is okay waiting longer

## Soft Budget and Checkpoints

Use a default soft research budget of 30 minutes after plan approval unless the user requests exhaustive coverage or explicitly approves a longer run. Treat this as a progress checkpoint, not a hard timeout.

At roughly 20 minutes after approval, or after the first researcher/evidence pass, checkpoint:

- Expected research files exist and are non-empty.
- Search log and evidence matrix have moved beyond skeleton entries.
- Enough supported evidence exists to write at least a partial answer.
- Missing tracks, blocked tools, or slow agents are recorded in the plan ledger.

At roughly 30 minutes after approval, prefer delivery over waiting for missing researcher tracks. If coverage is incomplete, write a partial evidence assessment with caveats, final/provenance artifacts, and `Verification: PASS WITH NOTES` or `Verification: BLOCKED` as appropriate. Do not let slow or missing subagent outputs prevent final artifact delivery after approval.

## Step 3: Gather Evidence

Use only tool names visible in the current tool set. For web work, use available search and fetch tools; never call tool names that are not exposed in the current session.

After approval and before searches, run `.opencode/skills/deepresearch/scripts/deepresearch-artifacts.py quality-files --slug <slug>` to create the search log and evidence matrix skeletons. Update both files throughout evidence gathering.

Maintain `<slug>/outputs/.drafts/<slug>-search-log.md` with every meaningful query or source-discovery action: query/tool, date, search angle, result count when available, accepted sources, rejected sources, and follow-up gaps. Do not treat the log as a final bibliography; it is a reproducibility trail.

Maintain `<slug>/outputs/.drafts/<slug>-evidence-matrix.md` with extracted evidence rows: question/theme, claim, direct quote or locator when available, source URL/DOI/artifact path, source type, confidence, contradiction notes, and verification status.

Prefer primary sources: papers, official docs, standards, datasets, code repositories, filings, benchmark pages, and authoritative institutional publications. Use secondary sources for context or interpretation, not as sole support for critical claims when primary evidence is available. Reject or clearly caveat low-quality sources: undated SEO pages, content aggregators, unsourced AI-generated pages, and social posts without primary links.

For academic or literature-heavy topics, use paper search when available. Check `alpha` availability before relying on it; if unavailable, continue with available web/search tools and record paper-search coverage as degraded. When seed papers or canonical sources are found and citation relationships matter, perform backward and/or forward citation chasing when feasible. If citation chasing is skipped, record why in the search log.

Avoid crash-prone PDF parsing in this workflow. Do not fetch `.pdf` URLs unless the user explicitly asks for PDF extraction. Prefer paper metadata, abstracts, HTML pages, official docs, and web snippets. If only a PDF exists, cite the PDF URL from search metadata and mark full-text PDF parsing as blocked instead of fetching it.

If direct search was chosen:

- Skip researcher spawning entirely.
- Search and fetch sources yourself.
- Use multiple search terms or angles before drafting. Minimum: 3 distinct queries for direct-mode research, covering definition/history, mechanism/formula, and current usage/comparison when relevant.
- Record the exact search terms used in `<slug>/outputs/.drafts/<slug>-research-direct.md`.
- Also record the exact search terms and source decisions in `<slug>/outputs/.drafts/<slug>-search-log.md`.
- Add extracted claims and source support to `<slug>/outputs/.drafts/<slug>-evidence-matrix.md`.
- Write notes to `<slug>/outputs/.drafts/<slug>-research-direct.md`.
- Continue to synthesis.

If researcher agents were chosen:

- After choosing the researcher count, run `.opencode/skills/deepresearch/scripts/deepresearch-artifacts.py researcher-files --slug <slug> --count <N>`, then update each generated `<slug>/outputs/.plans/<slug>-T<N>.md` brief with the actual assignment.
- Use the unique research output paths emitted by the script, such as `<slug>/outputs/.drafts/<slug>-research-T1.md`.
- Keep `task` tool prompts concise and valid.
- Do not name exact tool commands in researcher tasks unless those tool names are visible in the current tool set.
- Prefer broad guidance such as "use paper search and web search"; if a PDF parser or paper fetch fails, the researcher must continue from metadata, abstracts, and web sources and mark PDF parsing as blocked.
- After researcher tasks return, immediately verify that each expected researcher output file exists and is non-empty.
- If a researcher output file is missing or empty, make at most one recovery attempt for that track. If it is still missing, continue lead-owned with available search/fetch tools for that track, record the degraded mode in the plan ledger/search log/evidence matrix, and proceed with a partial evidence assessment.
- If the task tool or researcher agent is unavailable, fails, times out, or remains incomplete near the soft budget, continue lead-owned with available search/fetch tools, record the degraded mode in the plan ledger, and proceed with a blocked or partial draft.
- Require each researcher brief to include search angles, inclusion/exclusion criteria, and the assigned research output path. Each researcher output must include source decisions, an evidence table with stable source IDs, contradictions or missing evidence, and coverage status.

Example task shape:

```text
Use the task tool with subagent_type "researcher". Prompt the agent to read <slug>/outputs/.plans/<slug>-T1.md and write <slug>/outputs/.drafts/<slug>-research-T1.md. Ask it to return only a one-line completion summary.
```

After the first evidence-gathering pass, perform a targeted gap pass before drafting: identify unanswered key questions, single-source critical claims, stale or low-quality sources, and contradictions. Run targeted follow-up searches or clearly record blocked gaps. After evidence gathering, update the plan ledger, search log, evidence matrix, and verification log. If research failed or is incomplete, record exactly what failed and proceed with a blocked or partial draft rather than waiting indefinitely.

## Step 4: Draft

Write the report yourself. Do not delegate synthesis.

Save to `<slug>/outputs/.drafts/<slug>-draft.md`.

Include:

- Executive summary
- Findings organized by question/theme
- Evidence-backed caveats and disagreements
- Open questions
- Methods note summarizing search scope, source-selection defaults, and any degraded coverage
- Partial evidence assessment when any planned track failed, timed out, or was lead-owned fallback
- No invented sources, results, figures, benchmarks, images, charts, or tables

Before citation, sweep the draft:

- Every critical claim, number, figure, table, or benchmark must map to a source URL, research note, raw artifact path, or command/script output.
- Every critical claim should have converging support from primary evidence or be explicitly labeled as single-source, contested, or inferred.
- Remove or downgrade unsupported claims.
- Mark inferences as inferences.

## Step 5: Cite

If direct search/no researcher agents was chosen:

- Do citation yourself.
- Verify reachable HTML/doc URLs with available fetch/search tools.
- Copy or rewrite `<slug>/outputs/.drafts/<slug>-draft.md` to `<slug>/outputs/.drafts/<slug>-cited.md` with inline citations and a Sources section.
- Do not spawn the `verifier` agent for simple direct-search runs.

If researcher agents were used, run the `verifier` agent after the draft exists. This step is mandatory when the task tool and verifier agent are available, and must complete before any reviewer runs. Do not run the `verifier` and `reviewer` in the same parallel task call. If the task tool or verifier agent is unavailable or fails, do citation yourself with available search/fetch tools, write `<slug>/outputs/.drafts/<slug>-cited.md`, and mark verification as `BLOCKED` or `PASS WITH NOTES`.

Use the task tool with subagent_type `verifier`. Ask the agent to add inline citations to `<slug>/outputs/.drafts/<slug>-draft.md` using the research files as source material, verify every URL, and write the complete cited brief to `<slug>/outputs/.drafts/<slug>-cited.md`.

After the verifier returns, verify on disk that `<slug>/outputs/.drafts/<slug>-cited.md` exists. If the verifier wrote elsewhere, find the cited file and move or copy it to `<slug>/outputs/.drafts/<slug>-cited.md`.

## Step 6: Review

If direct search/no researcher agents was chosen:

- Review the cited draft yourself.
- Write `<slug>/outputs/.drafts/<slug>-verification.md` with FATAL / MAJOR / MINOR findings and the checks performed.
- Include a quality checklist covering placeholder removal, search-angle coverage, claim support, citation relevance/reachability, provenance completeness, and remaining caveats.
- Include a claim support sample of 5-10 critical claims mapped to source URLs or artifact paths with support status.
- Fix FATAL issues before delivery.
- Do not spawn the `reviewer` agent for simple direct-search runs.

If researcher agents were used, only after `<slug>/outputs/.drafts/<slug>-cited.md` exists, run the `reviewer` agent against it when the task tool and reviewer agent are available. If the task tool or reviewer agent is unavailable or fails, review the cited draft yourself and record the limitation in `<slug>/outputs/.drafts/<slug>-verification.md`.

Use the task tool with subagent_type `reviewer`. Ask the agent to verify `<slug>/outputs/.drafts/<slug>-cited.md`, flag unsupported claims, logical gaps, single-source critical claims, and overstated confidence, then write `<slug>/outputs/.drafts/<slug>-verification.md`.

Whether review is self-owned or delegated, `<slug>/outputs/.drafts/<slug>-verification.md` must contain the model-owned quality decision: `Verification: PASS`, `Verification: PASS WITH NOTES`, or `Verification: BLOCKED`. This decision must be based on evidence quality and claim support, not on the script artifact check. Before the final artifact-contract check runs, use `Artifact check: PENDING` in this verification file.

Every verification file must include:

- `Verification: PASS`, `Verification: PASS WITH NOTES`, or `Verification: BLOCKED`
- `Artifact check: PENDING` before the final artifact-contract check, then `Artifact check: PASS` or `Artifact check: FAIL` after it runs
- `Blocked checks:` with `none` or a concrete list
- FATAL / MAJOR / MINOR findings
- Claim support sample for direct runs, or reviewer findings for researcher-agent runs

If the reviewer flags FATAL issues, fix them before delivery and run one more review pass. Note MAJOR issues in Open Questions. Accept MINOR issues.

When applying reviewer fixes, do not issue one giant edit with many replacements. Use small localized edits only for 1-3 simple corrections. For section rewrites, table rewrites, or more than 3 substantive fixes, write a corrected full file to `<slug>/outputs/.drafts/<slug>-revised.md` instead.

After applying reviewer, verifier, audit, or PI-style fixes, run an explicit on-disk verification before saying the fixes landed. Use targeted reads or shell checks to prove the old unsupported wording is gone and the replacement wording exists. Provenance may only say an issue was fixed when this post-edit verification passed.

The final candidate is `<slug>/outputs/.drafts/<slug>-revised.md` if it exists; otherwise it is `<slug>/outputs/.drafts/<slug>-cited.md`.

## Step 7: Deliver

Use `.opencode/skills/deepresearch/scripts/deepresearch-artifacts.py provenance --slug <slug> --dest outputs|papers --verification PASS|PASS_WITH_NOTES|BLOCKED`, using the model-owned quality verification status from `<slug>/outputs/.drafts/<slug>-verification.md`, then fill in the provenance details with `Artifact check: PENDING`. Use `.opencode/skills/deepresearch/scripts/deepresearch-artifacts.py deliver --slug <slug> --dest outputs|papers` to copy the final candidate to:

- `<slug>/papers/<slug>.md` for paper-style drafts
- `<slug>/outputs/<slug>.md` for everything else

Write provenance next to it as `<slug>.provenance.md`:

```markdown
# Provenance: [topic]

- **Date:** [date]
- **Rounds:** [number of research rounds]
- **Sources consulted:** [count and/or list]
- **Sources accepted:** [count and/or list]
- **Sources rejected:** [dead, unverifiable, or removed]
- **Verification:** [PASS / PASS WITH NOTES / BLOCKED]
- **Artifact check:** [PENDING before final check, then PASS / FAIL]
- **Plan:** <slug>/outputs/.plans/<slug>.md
- **Research files:** [files used]
```

Before responding, run `.opencode/skills/deepresearch/scripts/deepresearch-artifacts.py verify --slug <slug> --phase post-approval --dest outputs|papers --allow-pending-artifact-check` as the pre-final artifact-contract check. If the artifact check passes, update both `<slug>/outputs/.drafts/<slug>-verification.md` and the provenance sidecar to `Artifact check: PASS`. If it fails and cannot be fixed, update both files to `Artifact check: FAIL`, set `Verification: BLOCKED` or `PASS WITH NOTES` as appropriate, and list the missing checks. Then run `.opencode/skills/deepresearch/scripts/deepresearch-artifacts.py verify --slug <slug> --phase post-approval --dest outputs|papers` again without the pending flag as the final artifact-contract check.

Final response should be brief: link the final file, provenance file, and any blocked checks.
