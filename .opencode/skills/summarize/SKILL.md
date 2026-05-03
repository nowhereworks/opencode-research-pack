---
name: summarize
description: "Summarize any URL, local file, or PDF using the RLM pattern: source stored on disk, never injected raw into context."
compatibility: opencode
metadata:
  args: <source> [--window-size <chars>] [--overlap <chars>] [--tier1-threshold <chars>] [--tier2-threshold <chars>]
  section: Research Workflows
---

# Summarize

Summarize the user's source.

Derive a short slug from the source filename or URL domain: lowercase, hyphens, no filler words, at most 5 words. Use this slug for all files in this run.

## Why This Uses RLM

Standard summarization injects the full document into context. Above about 15k tokens, early content degrades as the window fills. This workflow keeps the document on disk as an external variable and reads only bounded windows, so context pressure is proportional to the window size, not the document size.

Tier 1 is a deliberate exception: direct injection is safe for short inputs and windowed reading would add unnecessary friction.

## Runtime Knobs

Support both inline flags and environment variables so users can tune context-window behavior per run or globally.

- `--window-size <chars>` or `FEYNMAN_SUMMARIZE_WINDOW_CHARS`, default `6000`
- `--overlap <chars>` or `FEYNMAN_SUMMARIZE_OVERLAP_CHARS`, default `500`
- `--tier1-threshold <chars>` or `FEYNMAN_SUMMARIZE_TIER1_THRESHOLD`, default `8000`
- `--tier2-threshold <chars>` or `FEYNMAN_SUMMARIZE_TIER2_THRESHOLD`, default `60000`

Rules:

- Inline flags override environment variables.
- Validate `window-size > overlap` and `tier1-threshold < tier2-threshold`; if invalid, stop and report a clear configuration error.
- Log resolved values once per run: `[summarize] config window=<w> overlap=<o> tier1=<t1> tier2=<t2>`.

## Step 1: Fetch, Validate, Measure

Run all guards before any tier logic. A failure here is cheap; a failure mid-Tier-3 is not.

- GitHub repo URL (`https://github.com/owner/repo`, exactly 4 slashes): fetch the raw README instead. Try `https://raw.githubusercontent.com/{owner}/{repo}/main/README.md`, then `/master/README.md`. A repo HTML page is not the document the user wants to summarize.
- Remote URL: fetch to disk with a shell command such as `curl -sL -o outputs/.notes/<slug>-raw.txt <url>`. Do not use a fetch tool that returns the full document into context, because that bypasses the RLM external-variable principle.
- Local file or PDF: copy or extract to `outputs/.notes/<slug>-raw.txt`. For PDFs, extract text via `pdftotext` or equivalent before measuring.
- Empty or failed fetch: if the file is less than 50 bytes after fetching, stop and surface the error to the user. Do not proceed to tier selection.
- Binary content: if the file is larger than 1 KB but contains fewer than 100 readable text characters, stop and tell the user the content appears binary or unextracted.
- Existing output: if `outputs/<slug>-summary.md` already exists, ask the user whether to overwrite or use a different slug. Do not proceed until confirmed.

Measure decoded text characters, not bytes. Log: `[summarize] source=<source> slug=<slug> chars=<count>`.

## Step 2: Choose Tier

| Chars | Tier | Strategy |
|---|---|---|
| below `tier1-threshold` | 1 | Direct read: full content enters context, safe for short inputs |
| `tier1-threshold` to `tier2-threshold` | 2 | RLM-lite: windowed extraction, progressive notes to disk |
| above `tier2-threshold` | 3 | Full RLM: chunking plus parallel researcher agents |

Log: `[summarize] tier=<N> chars=<count>`.

## Tier 1: Direct Read

Read `outputs/.notes/<slug>-raw.txt` in full. Summarize directly using the output format. Write to `outputs/<slug>-summary.md`.

## Tier 2: RLM-Lite Windowed Read

The document stays on disk. Extract `<window-size>`-character windows with a shell script or one-off command.

For each window:

1. Extract key claims and evidence.
2. Append to `outputs/.notes/<slug>-notes.md` before reading the next window. This is the checkpoint: if the session is interrupted, processed windows survive.
3. Log: `[summarize] window <N>/<total> done`.

Synthesize `outputs/.notes/<slug>-notes.md` into `outputs/<slug>-summary.md`.

## Tier 3: Full RLM Parallel Chunks

Each chunk gets a fresh researcher agent context window. Context rot is impossible because no agent sees more than `<window-size>` characters.

Overlap matters because academic papers contain multi-sentence arguments that span chunk boundaries. The configured overlap ensures a cross-boundary claim appears fully in at least one adjacent chunk.

### Chunk the Document

Create `outputs/.notes/<slug>-chunk-NNN.txt` files with zero-padded indexes so files sort correctly. Use the configured `window-size` as chunk size and `overlap` as the overlap.

### Dispatch Researcher Agents

Briefly summarize: `Source is ~<chars> chars -> <N> chunks -> <N> researcher agents. This may take several minutes.` Then continue automatically. Do not ask for confirmation or wait for a proceed response unless the user explicitly requested review before launching.

Use the task tool with subagent_type `researcher` for each chunk. Ask each researcher to read only its assigned `outputs/.notes/<slug>-chunk-NNN.txt`, extract key claims, methodology or technical approach, and cited evidence, avoid external search/fetch, mark boundary-partial claims, and write to `outputs/.notes/<slug>-summary-chunk-NNN.md`.

### Aggregate

After all agents return, verify every expected `outputs/.notes/<slug>-summary-chunk-NNN.md` exists. Note any missing chunk indices; they will appear in the Coverage gaps section of the output. Do not abort on partial coverage; a partial summary with gaps noted is more useful than no summary.

When synthesizing:

- Deduplicate: a claim in multiple chunks is one claim; keep the most complete formulation.
- Resolve boundary conflicts: for adjacent-chunk contradictions, prefer the version with more supporting context.
- Remove BOUNDARY PARTIAL markers where a complete version exists in a neighboring chunk.

Write to `outputs/<slug>-summary.md`.

## Output Format

All tiers produce the same artifact at `outputs/<slug>-summary.md`:

```markdown
# Summary: [document title or source filename]

**Source:** [URL or file path]
**Date:** [YYYY-MM-DD]
**Tier:** [1 / 2 (N windows) / 3 (N chunks)]

## Key Claims
[3-7 most important assertions, each as a bullet]

## Methodology
[Approach, dataset, evaluation, baselines; omit for non-research documents]

## Limitations
[What the source explicitly flags as weak, incomplete, or out of scope]

## Verdict
[One paragraph: what this document establishes, its credibility, who should read it]

## Sources
1. [Title or filename] — [URL or file path]

## Coverage gaps *(Tier 3 only; omit if all chunks succeeded)*
[Missing chunk indices and their approximate byte ranges]
```

Before stopping, verify on disk that `outputs/<slug>-summary.md` exists.

Sources contains only the single source confirmed reachable in Step 1. No verifier agent is needed because there are no URLs constructed from memory to verify.
