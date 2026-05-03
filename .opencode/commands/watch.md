---
name: watch
description: Set up a recurring research watch on a topic, company, paper area, or product surface. Use when the user asks to monitor a field, track new papers, watch for updates, or set up alerts on a research area.
---

# Watch

Call the `skill` tool with name `watch`.

User arguments: `$ARGUMENTS`

After the skill loads, execute its workflow using the user arguments. If no watch topic was provided, ask one concise question for the topic to monitor before proceeding.

Agents used: lead-owned by default; use `researcher` only if the loaded skill explicitly delegates.

Output: baseline survey in `outputs/`, with recurring checks via `pi-schedule-prompt` when that external tool is installed.
