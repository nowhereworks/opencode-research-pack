---
name: jobs
description: Inspect active background research work, including running processes and scheduled follow-ups.
compatibility: opencode
metadata:
  section: Project & Session
---

# Jobs

Inspect active background work for this project.

## Requirements

- Inspect running and finished managed background processes using available OpenCode process tooling, if present.
- If external `pi-processes` is installed, use it to list managed background processes.
- If external `pi-schedule-prompt` is installed, use it to list active recurring or deferred jobs.
- Summarize active background processes, queued or recurring research watches, failures that need attention, and the next concrete command the user should run if they want logs or detailed status.
- Be concise and operational.
