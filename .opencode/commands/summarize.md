---
name: summarize
description: Summarize any URL, local file, or PDF using the RLM pattern. Use when the user asks to summarize a long source while keeping raw source content on disk.
---

# Summarize

Call the `skill` tool with name `summarize`.

User arguments: `$ARGUMENTS`

After the skill loads, execute its workflow using the user arguments. If no source was provided, ask one concise question for the URL or file path before proceeding.

Agents used: `researcher` for large chunked sources.

Output: summary in `outputs/` with raw and intermediate notes in `outputs/.notes/`.
