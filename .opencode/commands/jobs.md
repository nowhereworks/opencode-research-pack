---
name: jobs
description: Inspect active background research work including running processes and scheduled follow-ups. Use when the user asks what's running, checks on background work, or wants to see scheduled jobs.
---

# Jobs

Call the `skill` tool with name `jobs`.

User arguments: `$ARGUMENTS`

After the skill loads, execute its workflow using the user arguments.

Shows active `pi-processes` and scheduled `pi-schedule-prompt` entries when those process or scheduling tools are available, plus any OpenCode-managed process information exposed in the current runtime.
