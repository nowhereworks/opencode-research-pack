---
name: summarize
description: Summarize any URL, local file, or PDF using the RLM pattern. Use when the user asks to summarize a long source while keeping raw source content on disk.
---

# Summarize

Invoke the `summarize` skill. The skill expands the full workflow instructions in the active session; do not try to read a relative prompt-template path from the installed skill directory.

Agents used: `researcher` for large chunked sources.

Output: summary in `outputs/` with raw and intermediate notes in `outputs/.notes/`.
