---
name: preview
description: Preview or export Markdown, PDF, LaTeX, and report artifacts using available local tools.
compatibility: opencode
metadata:
  args: <file>
  section: Project & Session
---

# Preview

Preview the user's artifact using available tools.

## Requirements

- Treat the user arguments as the file to preview or export.
- If no file is provided, inspect likely artifact directories such as `outputs/`, `papers/`, and `notes/`; ask only if there is no clear candidate.
- Do not call nonexistent `/preview-browser`, `/preview-pdf`, or `/preview-clear-cache` commands.
- Check for local tools before using them, such as `pandoc`, `pdflatex`, `xdg-open`, or browser CLIs.
- If no viewer or exporter is available, report the artifact path and the blocked preview step.
- Do not modify source content unless the user asks for an export or conversion.

## Output

- For browser or app previews, report the command used.
- For exports, write generated files next to the source or under `outputs/` and report the path.
- If blocked, include the missing command and a concrete install or fallback suggestion.
