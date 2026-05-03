# AGENTS.md

## Repo Shape

- This repo is an OpenCode configuration/port, not an app or library; source lives under `.opencode/`.
- Current source files are `.opencode/agents/*.md` and `.opencode/commands/*.md`; `.vscode/` is editor cosmetics.
- Treat `.opencode/node_modules/`, `.opencode/package*.json`, and `.opencode/.gitignore` as install artifacts unless intentionally changing the OpenCode plugin dependency.
- Porting map from Feynman: `agents` -> OpenCode agents, `prompts` -> OpenCode skills, `skills` -> OpenCode commands.

## File Conventions

- Agents live at `.opencode/agents/<name>.md` with YAML frontmatter `name: <name>`; migrated Feynman metadata is usually left commented until OpenCode equivalents are confirmed.
- Commands live at `.opencode/commands/<command-name>.md` with YAML frontmatter `name` and `description`.
- Most workflow commands are thin launchers for OpenCode skills such as `autoresearch`, `deepresearch`, `lit`, `audit`, `draft`, `review`, `replicate`, `compare`, `watch`, `jobs`, and `log`; do not inline or chase relative prompt-template paths from installed skill directories.
- Keep durable user-provided project/session guidance in `AGENTS.md` or another discoverable Markdown file when the user asks to persist it.

## Validation

- No repo-level `npm test`, `npm run lint`, `npm run build`, or `npm run typecheck` scripts are defined.
- After editing agent or command Markdown, verify frontmatter names match file/directory names and referenced agents/commands exist.
- Use `https://opencode.ai/docs` as the canonical OpenCode reference when checking syntax or behavior.

## External Tooling

- Commands reference external tools not provided here: `alpha`, `docker`, `modal`, `runpodctl`, `pi-autoresearch`, `pi-processes`, and `pi-schedule-prompt`; check availability before relying on them.
- `.opencode/commands/contributing.md` documents upstream Feynman conventions, not this port; do not apply its `src/`, `prompts/`, `skills/`, or `npm test/typecheck/build` assumptions unless working inside upstream Feynman.
