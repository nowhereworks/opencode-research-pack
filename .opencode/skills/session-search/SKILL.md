---
name: session-search
description: Search past OpenCode sessions and exports to recover prior work, decisions, and research context.
compatibility: opencode
metadata:
  args: <query>
  section: Project & Session
---

# Session Search

Search prior OpenCode session context for the user's query.

## Requirements

- Treat the user arguments as the search query.
- Check `command -v opencode` before relying on OpenCode CLI session tooling.
- Use OpenCode session tooling when available, starting with `opencode session list`.
- Use `opencode export <sessionID>` for sessions that need detailed inspection.
- OpenCode data is typically under `~/.local/share/opencode`; confirm with `opencode debug paths` before searching files directly.
- Do not reference Feynman-only paths such as `~/.feynman/sessions/` unless the user explicitly asks about legacy Feynman data.
- If the OpenCode CLI or a session subcommand is unavailable, use `opencode debug paths` when possible, then search only relevant OpenCode data or exported JSON files and avoid dumping large transcripts into chat. If no session source is reachable, report the blocked lookup.

## Output

- Return matching session IDs, dates or titles when available, and short evidence snippets.
- Suggest the exact `opencode export <sessionID>` command when the user needs the full transcript.
