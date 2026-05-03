---
name: alpha-research
description: Search, read, and query research papers with alpha when available, with web-backed fallback when unavailable.
compatibility: opencode
metadata:
  args: <paper-or-query>
  section: Research Tools
---

# Alpha Research CLI

Handle the user's academic paper research request.

## Requirements

- Treat the user arguments as the paper, arXiv ID, DOI, URL, or research query.
- First check whether the `alpha` CLI is available with `command -v alpha` before relying on it.
- If `alpha` is available, use it via bash for paper search, paper reading, paper Q&A, code inspection, and annotations.
- If `alpha` is unavailable, say that the dependency is missing and continue with available web and fetch tools instead of pretending alpha ran.
- For mixed academic and current-product topics, combine paper sources with web sources.
- Never fabricate paper metadata, repository links, benchmark results, or annotations.

## Alpha Commands

Use these only after confirming `alpha` is installed:

| Command | Purpose |
|---|---|
| `alpha search "<query>"` | Search papers. Prefer `--mode semantic`; use `--mode keyword` for exact terms and `--mode agentic` for broad retrieval. |
| `alpha get <arxiv-id-or-url>` | Fetch paper content and local annotation. |
| `alpha get --full-text <arxiv-id>` | Fetch raw full text. |
| `alpha ask <arxiv-id> "<question>"` | Ask about a paper. |
| `alpha code <github-url> [path]` | Read files from a paper repository. Use `/` for an overview. |
| `alpha annotate <paper-id> "<note>"` | Save an annotation. |
| `alpha annotate --clear <paper-id>` | Remove an annotation. |
| `alpha annotate --list` | List annotations. |

## Output

- Answer inline unless the user asks for an artifact.
- Include direct URLs or paper IDs for every named paper, dataset, code repository, or benchmark.
- Mark missing CLI, authentication, PDF parsing, or unreachable-source issues explicitly.
