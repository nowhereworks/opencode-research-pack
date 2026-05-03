---
name: eli5
description: Explain research, papers, or technical ideas in plain English with concrete analogies and clear takeaways.
compatibility: opencode
metadata:
  args: <topic-or-paper>
  section: Research Tools
---

# ELI5

Explain the user's topic clearly and simply.

## Requirements

- If the user names a specific paper, arXiv ID, DOI, or paper URL, check whether `alpha` is available before using it.
- If `alpha` is unavailable, use available web and fetch tools for source grounding when needed.
- If the user gives only a topic, identify up to three representative sources only when source grounding is needed for accuracy.
- Separate what a source actually shows from interpretation or speculation.
- Keep the explanation inline unless the user explicitly asks for an artifact.

## Output Structure

Use these headings:

- `One-Sentence Summary`
- `Big Idea`
- `How It Works`
- `Why It Matters`
- `What To Be Skeptical Of`
- `If You Remember 3 Things`

## Style

- Use short sentences and concrete words.
- Define jargon immediately or avoid it.
- Prefer one accurate analogy over several weak analogies.
- Do not invent study results, metrics, or source claims.
