# Deepresearch Benchmark

Repeatable benchmark for comparing the first `deepresearch` skill version on `main` against the current active branch version.

This benchmark measures research quality, effectiveness, and reliability. It is intended to be rerun whenever `deepresearch` changes materially.

## Comparison Target

Always compare:

- **Baseline:** first commit on `main` that contains `.opencode/skills/deepresearch/SKILL.md`
- **Candidate:** current active branch `HEAD`

Resolve the baseline commit with:

```bash
BASELINE_COMMIT=$(git log --reverse --format=%H main -- .opencode/skills/deepresearch/SKILL.md | head -n 1)
```

Record both commit SHAs in the benchmark report:

```bash
git rev-parse "$BASELINE_COMMIT"
git rev-parse HEAD
```

## Benchmark Modes

Use the smoke mode before quick iteration and the full mode before judging a meaningful change.

| Mode | Prompts | Repeats | Total Runs | Use Case |
|---|---:|---:|---:|---|
| Smoke | 3 | 1 | 6 | Fast regression check |
| Standard | 10 | 3 | 60 | Normal quality comparison |
| Extended | 10+ | 5 | 100+ | High-confidence release decision |

Smoke mode is only verdict-eligible if both versions are attempted on all three smoke prompts. If one version fails or times out on a smoke prompt, still run the other version on that same prompt.

## Execution Budget

Use a fixed execution budget so reliability is measured consistently.

| Budget | Default |
|---|---:|
| Maximum single `opencode run` command time | 20 minutes |
| Maximum total wall-clock time per prompt/version/repeat | 40 minutes |
| Maximum resume attempts after timeout or interrupted run | 1 |

If a run exceeds the command budget, resume once if the session is recoverable. If it exceeds the prompt budget or fails after the resume attempt, mark the run `FAILED_TIMEOUT`.

After user plan approval, `FAILED_TIMEOUT` is a reliability failure unless the final report, cited draft, verification, and provenance artifacts already exist and pass artifact checks.

Do not extend the budget for one version unless the same extension is applied to the other version and recorded in the report.

## Setup

Create isolated worktrees so artifacts, scripts, generated files, and checked-out skill versions do not contaminate each other.

```bash
BASELINE_COMMIT=$(git log --reverse --format=%H main -- .opencode/skills/deepresearch/SKILL.md | head -n 1)
RUN_ID=$(date +%Y-%m-%d-%H%M%S)

git worktree add "/tmp/deepresearch-baseline-$RUN_ID" "$BASELINE_COMMIT"
git worktree add "/tmp/deepresearch-candidate-$RUN_ID" HEAD
```

Before running, record environment details:

```text
Run ID:
Date:
Operator:
Baseline commit:
Candidate commit:
OpenCode version:
Model:
Tool availability:
Network access:
Notes:
```

Tool availability should list whether these are available in the session: `websearch`, `webfetch`, `task`, `researcher`, `verifier`, `reviewer`, `alpha`, and any filesystem or shell tools used.

## Controls

Hold these conditions constant across baseline and candidate runs:

- Same model and model settings when configurable
- Same OpenCode version
- Same tool availability
- Same network access
- Same run date or as narrow a time window as practical
- Same operator behavior
- Same prompt wording
- Same approval behavior: approve each valid plan unchanged
- Same output destination unless the skill chooses otherwise by documented rules
- Fresh session or equivalent isolation per run when practical
- No manual quality fixes except those explicitly requested by the skill workflow
- No reuse of prior run artifacts, research notes, or memory unless both versions receive equivalent access

If a control cannot be held constant, record it in the run notes and mark affected comparisons as lower confidence.

## Abort Rules

Do not abort the benchmark just because one version fails a prompt. A failed baseline prompt is often the most important reason to run the candidate prompt.

Continue the run matrix unless one of these global abort conditions occurs:

- OpenCode CLI is unusable for both versions.
- Required model access is unavailable for both versions.
- Network or source access is unavailable for both versions and the benchmark requires live research.
- Tool permissions or workspace state prevent both versions from writing artifacts.
- The operator explicitly records a safety, cost, or time-box decision to stop the benchmark.

When a single run fails:

- Archive partial artifacts.
- Write `operator-notes.md` with the failure point and missing artifacts.
- Continue with the paired run for the other version on the same prompt.
- Continue remaining smoke prompts unless a global abort condition applies.

## Prompt Suite

Use the same prompt IDs and exact wording across versions.

### Core Prompts

| ID | Type | Prompt |
|---|---|---|
| P01 | Narrow explainer | What is speculative decoding? |
| P02 | Technical comparison | Compare GraphRAG, standard RAG, and long-context retrieval for enterprise knowledge assistants. |
| P03 | Literature-heavy | What is the evidence that mechanistic interpretability methods can identify transformer circuits? |
| P04 | Fast-moving landscape | What is the current state of open-weight reasoning models in 2026? |
| P05 | Benchmark reliability | How reliable is SWE-bench as a measure of real software engineering ability? |
| P06 | Contested effectiveness | Does retrieval-augmented generation reduce hallucination in production systems? |
| P07 | High-stakes policy | What obligations does the EU AI Act impose on general-purpose AI model providers? |
| P08 | Ambiguous broad research | AI safety evaluations. |
| P09 | Source-quality stress test | What are the best-supported claims about agentic LLM reliability in production? |
| P10 | Reproducibility-focused | What evidence exists that LLM agents can autonomously perform scientific research? |

### Smoke Prompt Subset

Use these for smoke mode:

- P01
- P03
- P07

Smoke mode is designed to settle three prompt classes:

| Prompt | Class | Verdict Role |
|---|---|---|
| P01 | Narrow explainer | Tests simple direct-search quality and avoidance of over-complication |
| P03 | Broad literature-heavy research | Tests multi-source evidence synthesis, researcher-agent reliability, and broad-prompt completion |
| P07 | High-stakes policy | Tests source authority, jurisdictional caution, caveats, and high-stakes handling |

A smoke verdict is incomplete unless both versions are attempted on P01, P03, and P07.

### Adding Prompts

Add prompts only when they cover a benchmark gap. Preserve existing IDs and wording to keep historical comparisons valid. New prompts should get new IDs such as `P11` and should be added to the report as a benchmark-suite version change.

## Run Matrix

For standard mode, run each prompt three times against each version:

```text
versions = baseline, candidate
prompts = P01..P10
repeats = 3
total_runs = 2 * 10 * 3 = 60
```

Randomize run order when practical to reduce time and search-index bias. If randomization is not practical, alternate versions by prompt:

```text
P01 baseline run-1
P01 candidate run-1
P01 baseline run-2
P01 candidate run-2
...
```

### Failure Follow-Up Rule

If one version fails, times out, or produces no final artifact for a prompt, immediately run the other version on the same prompt unless a global abort condition applies.

Examples:

- If baseline P03 times out, candidate P03 is mandatory.
- If candidate P07 asks for unnecessary clarification and does not create a plan, baseline P07 is still mandatory.
- If both versions fail the same prompt, compare failure modes and partial artifacts, but do not claim either version has better final research quality for that prompt.

## Run Directory Layout

Archive every run under a benchmark result directory:

```text
benchmarks/results/deepresearch/<run-id>/<version>/<prompt-id>/run-<n>/
```

Example:

```text
benchmarks/results/deepresearch/2026-05-10-143000/candidate/P03/run-2/
```

Each run directory should contain, when available:

```text
final.md
provenance.md
plan.md
draft.md
cited.md
verification.md
search-log.md
evidence-matrix.md
operator-notes.md
artifacts-manifest.txt
```

For baseline versions that do not produce `search-log.md` or `evidence-matrix.md`, record `missing_not_required_for_baseline` in `operator-notes.md`. Do not count these as baseline failures unless the benchmark question is specifically artifact maturity.

## Operator Procedure

For each run:

1. Start in the correct worktree for the version under test.
2. Start a fresh OpenCode session when practical.
3. Invoke `deepresearch` with the exact prompt text.
4. When the skill asks for plan approval, approve unchanged if the plan exists and is coherent.
5. If the plan is missing, malformed, or asks for unnecessary clarification, record it and continue only if the workflow can proceed safely.
6. Do not manually add sources, rewrite claims, or repair artifacts unless the skill workflow explicitly directs the operator to do so.
7. At completion, copy all produced artifacts into the run directory.
8. Fill out `operator-notes.md`.

If a run times out or is interrupted:

1. Resume the same session once if the session ID is available.
2. Ask it to continue from existing artifacts and complete final delivery.
3. If the resumed run fails or exceeds budget, stop that run and mark it `FAILED_TIMEOUT`.
4. Archive all partial artifacts.
5. Continue the paired run for the other version on the same prompt.

Operator notes template:

```markdown
# Operator Notes

- Prompt ID:
- Version: baseline|candidate
- Repeat:
- Started:
- Completed:
- Completed successfully: yes|no
- Plan approval: approved unchanged|changed|not requested|failed
- Tool failures:
- Missing artifacts:
- Failure status: completed|FAILED_TIMEOUT|FAILED_TOOL|FAILED_ARTIFACT|FAILED_QUALITY|NOT_RUN
- Resume attempts:
- Wall-clock time:
- Manual interventions:
- Deviations from controls:
- Notes:
```

## Reliability Checks

Reliability is measured with objective checks wherever possible.

| Check | Type | Scoring |
|---|---|---|
| Plan created before research | Boolean | pass/fail |
| Valid approval pause | Boolean | pass/fail |
| Final report present | Boolean | pass/fail |
| Provenance present | Boolean | pass/fail |
| Draft present | Boolean | pass/fail |
| Cited draft present | Boolean | pass/fail |
| Verification status present | Boolean | pass/fail |
| Run completed after approval | Boolean | pass/fail |
| No chat-only ending after approval | Boolean | pass/fail |
| Artifact paths valid | Count | broken path count |
| Required artifacts missing | Count | missing artifact count |
| Tool failures handled | Ordinal | 0 = failed, 1 = partial, 2 = handled |
| Completed within command budget | Boolean | pass/fail |
| Completed within prompt budget | Boolean | pass/fail |
| Resume recovered run when needed | Boolean/n/a | pass/fail/n/a |

Candidate-specific maturity checks:

| Check | Type | Scoring |
|---|---|---|
| Search log present | Boolean | pass/fail |
| Evidence matrix present | Boolean | pass/fail |
| Artifact-contract script used when available | Boolean | pass/fail |
| Script check distinguished from quality verification | Boolean | pass/fail |

Keep candidate-specific maturity checks separate from the shared reliability score unless explicitly evaluating artifact maturity.

## Partial-Run Scoring

When a run fails before final delivery, score only reliability and partial-artifact quality. Do not score final research quality, final effectiveness, unsupported-claim rate, or citation relevance unless a final cited artifact exists.

Partial-run fields:

| Field | Values |
|---|---|
| Failure status | FAILED_TIMEOUT / FAILED_TOOL / FAILED_ARTIFACT / FAILED_QUALITY / NOT_RUN |
| Failure phase | planning / evidence / drafting / citation / review / delivery / verification |
| Plan present | yes/no |
| Approval pause occurred | yes/no |
| Research artifacts present | none / partial / complete |
| Final artifact present | yes/no |
| Provenance present | yes/no |
| Recovery attempted | yes/no/not applicable |
| Recovery result | recovered / failed / not applicable |

Partial artifacts may inform reliability and workflow diagnosis, but they must not be used to claim final-answer quality superiority.

## Claim-Level Audit

For each final report, sample 10 important claims. Prefer claims from the executive summary, main findings, numerical statements, benchmark statements, and recommendations.

This audit is mandatory for every prompt completed by both versions. Lightweight audits may be used for progress notes, but no final quality verdict may rely on a lightweight audit.

Classify each claim:

| Label | Meaning |
|---|---|
| SUPPORTED | Cited source directly supports the claim |
| PARTIAL | Source supports a weaker, adjacent, or incomplete version of the claim |
| UNSUPPORTED | Source does not support the claim |
| UNVERIFIABLE | Source is missing, inaccessible, too vague, or not checkable |

Record results:

```markdown
| Claim | Citation/Source | Classification | Notes |
|---|---|---|---|
| | | SUPPORTED/PARTIAL/UNSUPPORTED/UNVERIFIABLE | |
```

Compute:

```text
supported_claim_rate = supported_claims / sampled_claims
partial_claim_rate = partial_claims / sampled_claims
unsupported_claim_rate = unsupported_claims / sampled_claims
unverifiable_claim_rate = unverifiable_claims / sampled_claims
```

## Citation Audit

Audit every source if there are 20 or fewer. If there are more than 20, sample 20 with preference for sources attached to critical claims.

This audit is mandatory for every prompt completed by both versions. If one version has no final cited report, record citation audit as `not applicable` for that version and do not declare a final quality winner for that prompt.

Score each source:

| Field | Values |
|---|---|
| Reachable | yes/no |
| Primary or authoritative | yes/no |
| Relevant to cited claim | yes/no |
| Current enough for topic | yes/no/not applicable |
| Low-quality source | yes/no |

Compute:

```text
citation_reachability_rate = reachable_sources / audited_sources
primary_source_rate = primary_or_authoritative_sources / audited_sources
citation_relevance_rate = relevant_sources / audited_sources
stale_source_rate = stale_sources / audited_sources
low_quality_source_rate = low_quality_sources / audited_sources
```

## Blind Quality Rubric

Blind the judge to whether an output came from baseline or candidate. Score each final report from 1 to 5.

Blind scoring is mandatory for every prompt completed by both versions before declaring an overall quality or effectiveness verdict. If only one version completes a prompt, score the completed output only for diagnostic purposes and record the other version as a reliability failure.

| Criterion | Score 1 | Score 3 | Score 5 |
|---|---|---|---|
| Factual accuracy | Frequent errors | Mostly correct with issues | Accurate and well-grounded |
| Coverage | Misses core questions | Covers obvious questions | Covers key questions and important edge cases |
| Source quality | Weak or generic sources | Mixed source quality | Primary or authoritative sources dominate |
| Citation relevance | Citations often decorative | Citations partly support claims | Citations directly support claims |
| Caveats and uncertainty | Overconfident | Some caveats | Clear limits, uncertainty, and contested points |
| Contradiction handling | Ignores disagreement | Mentions disagreement | Explains disagreement and evidence strength |
| Synthesis quality | Source dump or generic | Understandable synthesis | Insightful, structured, non-obvious synthesis |
| Usefulness | Hard to act on | Moderately useful | Directly useful for user decisions |
| Appropriate depth | Too shallow or bloated | Adequate | Fits prompt scope well |
| Clarity | Confusing | Clear enough | Clear, concise, navigable |

Aggregate rubric scores:

```text
quality_score = average(factual accuracy, coverage, source quality, citation relevance, caveats, contradiction handling, synthesis quality)
effectiveness_score = average(usefulness, appropriate depth, clarity)
```

## Aggregate Scoring

Recommended overall weights:

```text
quality = 50%
effectiveness = 30%
reliability = 20%
```

Normalize reliability to a 1-5 scale before combining:

```text
reliability_score = 1 + 4 * passed_shared_reliability_checks / total_shared_reliability_checks
```

Overall score:

```text
overall_score = 0.50 * quality_score + 0.30 * effectiveness_score + 0.20 * reliability_score
```

Also report raw metric deltas. Do not rely only on the aggregate score.

## Regression Criteria

The candidate is better if it improves at least two of these without a material regression elsewhere:

- Unsupported claim rate decreases by at least 20% relative
- Artifact completion rate increases
- Citation relevance rate increases
- Primary or authoritative source rate increases
- Blind quality score increases
- Blind effectiveness score increases
- Failure or blocked-run rate decreases
- Tool-failure recovery improves

The candidate regresses if any of these happen:

- Unsupported claim rate increases by at least 20% relative
- Completion rate drops materially
- More runs end without final artifacts after approval
- Blind quality score drops by at least 0.5 on the 1-5 scale
- Blind effectiveness score drops by at least 0.5 on the 1-5 scale
- Reliability score drops by at least 0.5 on the 1-5 scale
- Candidate adds process overhead without measurable quality or reliability gain

## Verdict Criteria

Every benchmark report must end with one of these verdicts:

| Verdict | Meaning |
|---|---|
| Current better | Candidate is better overall under the benchmark criteria |
| First better | Baseline is better overall under the benchmark criteria |
| Mixed | Each version clearly wins different prompt classes or metric categories |
| Inconclusive | Required paired attempts, audits, or scoring are missing |

### Smoke Verdict Gate

A smoke benchmark can declare `Current better` only if all conditions hold:

- Both versions were attempted on P01, P03, and P07.
- Candidate completes at least as many smoke prompts as baseline.
- Candidate does not score worse than baseline by more than 0.5 on any completed paired prompt's blind quality score.
- Candidate does not score worse than baseline by more than 0.5 on any completed paired prompt's blind effectiveness score.
- Candidate has equal or better shared reliability score, or a clearly documented reliability win such as completing a prompt where baseline failed.
- Candidate does not increase unsupported-claim rate on completed paired prompts.
- Candidate improves artifact maturity or reproducibility without causing a material quality or effectiveness regression.

A smoke benchmark can declare `First better` only if all conditions hold:

- Both versions were attempted on P01, P03, and P07.
- Baseline completes more smoke prompts than candidate, or candidate has a material quality/effectiveness regression on completed paired prompts.
- Baseline does not have a materially higher unsupported-claim rate.

Use `Mixed` when one version wins reliability and the other wins quality/effectiveness by material margins. Use `Inconclusive` when any smoke prompt is not attempted for either version or required audits are missing.

### Standard Verdict Gate

A standard benchmark can declare `Current better` or `First better` only after:

- All 10 prompts are attempted for both versions.
- At least 80% of planned runs complete or fail with comparable paired attempts.
- Completed paired prompts receive claim audits, citation audits, and blind quality/effectiveness scores.
- Partial and failed runs are scored for reliability but excluded from final-answer quality averages.

## Report Template

Create one report per benchmark execution:

```markdown
# Deepresearch Benchmark Report: YYYY-MM-DD

## Environment

- Run ID:
- Benchmark mode: smoke|standard|extended
- Baseline commit:
- Candidate commit:
- OpenCode version:
- Model:
- Tool availability:
- Network access:
- Prompt suite version:
- Runs per prompt:
- Execution budget:
- Verdict:
- Verdict confidence:
- Unsettled claims:
- Required follow-up runs:

## Summary

| Metric | Baseline | Candidate | Delta | Winner |
|---|---:|---:|---:|---|
| Completion rate | | | | |
| Shared artifact pass rate | | | | |
| Reliability score | | | | |
| Supported claim rate | | | | |
| Unsupported claim rate | | | | |
| Citation reachability rate | | | | |
| Citation relevance rate | | | | |
| Primary source rate | | | | |
| Blind quality score | | | | |
| Blind effectiveness score | | | | |
| Overall score | | | | |

## Verdict

- Verdict: Current better | First better | Mixed | Inconclusive
- Verdict confidence: High | Medium | Low
- Rationale:
- Unsettled claims:
- Required follow-up runs:
- Timeout/failure comparison:

## Prompt-Level Results

| Prompt ID | Baseline Status | Candidate Status | Baseline Overall | Candidate Overall | Winner | Notes |
|---|---|---|---:|---:|---|---|
| P01 | | | | | | |
| P02 | | | | | | |
| P03 | | | | | | |
| P04 | | | | | | |
| P05 | | | | | | |
| P06 | | | | | | |
| P07 | | | | | | |
| P08 | | | | | | |
| P09 | | | | | | |
| P10 | | | | | | |

## Findings

## Regressions

## Reliability Notes

## Quality Notes

## Effectiveness Notes

## Recommended Changes

## Confidence

- High|Medium|Low:
- Main limitations:
```

## Confidence Rules

Use these confidence levels for the benchmark verdict:

| Confidence | Requirements |
|---|---|
| High | All required prompts for the selected mode were attempted for both versions; completed paired prompts have full audits and blind scoring; failures are paired and well-characterized |
| Medium | All required prompts for the selected mode were attempted for both versions, but one prompt has partial artifacts or one audit dimension is incomplete |
| Low | Any required prompt was not attempted for either version, or final verdict relies on lightweight audits only |

If smoke mode does not attempt both versions on P01, P03, and P07, the verdict confidence must be `Low` and the verdict must be `Inconclusive` unless the report is explicitly scoped to a narrower claim.

## Interpretation Guidance

Prefer concrete error reductions over stylistic gains. A candidate that writes more polished prose but increases unsupported claims or artifact failures is worse.

Treat candidate-only artifacts such as search logs and evidence matrices as evidence of improved reproducibility, but verify that they are actually populated and used. Empty or perfunctory artifacts should not receive quality credit.

When results are mixed, inspect prompt classes separately. A change may improve broad multi-agent research while hurting narrow explainers, or improve reliability while increasing runtime overhead.

## Cleanup

After archiving results, remove temporary worktrees when no longer needed:

```bash
git worktree remove "/tmp/deepresearch-baseline-$RUN_ID"
git worktree remove "/tmp/deepresearch-candidate-$RUN_ID"
```
