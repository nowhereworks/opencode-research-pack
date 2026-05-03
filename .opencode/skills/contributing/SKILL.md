---
name: contributing
description: Apply this OpenCode port's repository conventions when changing commands, agents, skills, docs, or config.
compatibility: opencode
metadata:
  section: Project & Session
---

# Contributing

Work on this OpenCode configuration port using the local repo conventions.

## Requirements

- Read repo-root `AGENTS.md` before making project changes if it has not already been read in the current session.
- Treat this repository as an OpenCode configuration port, not upstream Feynman.
- Source lives primarily under `.opencode/agents/`, `.opencode/commands/`, and `.opencode/skills/`.
- Do not apply upstream Feynman assumptions about `src/`, `prompts/`, `skills/`, `npm test`, `npm run typecheck`, or `npm run build` unless explicitly working inside upstream Feynman.
- Keep command files as thin launchers when they map to skills.
- Keep skill names lowercase and matching `.opencode/skills/<name>/SKILL.md`.
- Keep agent names matching `.opencode/agents/<name>.md` and use `mode: subagent` for callable subagents.

## Validation

- After editing commands, agents, or skills, run OpenCode discovery checks such as `opencode debug config` and `opencode debug skill` when available.
- Verify frontmatter names match filenames or containing directories.
- Verify every referenced skill, agent, subagent, and external tool either exists or has an explicit degraded-mode path.
