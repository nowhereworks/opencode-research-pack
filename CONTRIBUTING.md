# Contributing

Thanks for contributing.

## Repo Shape

- This repo is an OpenCode configuration port, not an app or library.
- Primary source files live under `.opencode/agents/`, `.opencode/commands/`, and `.opencode/skills/`.
- Treat `.opencode/node_modules/`, `.opencode/package*.json`, and `.opencode/.gitignore` as install artifacts unless you are intentionally changing the OpenCode plugin dependency.

## File Conventions

- Agents live at `.opencode/agents/<name>.md` and should use YAML frontmatter with `name: <name>`.
- Commands live at `.opencode/commands/<command-name>.md` and should use YAML frontmatter with `name` and `description`.
- Keep command launchers thin when they map to local OpenCode skills.
- Keep durable repo guidance in `AGENTS.md` or another clearly discoverable Markdown file.

## Validation

- Verify that frontmatter names match file and directory names.
- Verify that referenced agents, commands, and skills actually exist.
- Use `https://opencode.ai/docs` as the canonical OpenCode reference when checking syntax or behavior.

## Local Checks

- There are currently no repo-level `npm test`, `npm run lint`, `npm run build`, or `npm run typecheck` scripts.
- When applicable, validate changes with relevant OpenCode debug commands such as `opencode debug config`, `opencode debug skill`, or `opencode debug agent`.

## Pull Requests

- Keep changes narrowly scoped.
- Explain the user-visible behavior change and any repo-structure implications.
- Mention any external tooling assumptions or degraded-mode fallbacks introduced by the change.
- When adapting upstream Feynman material, preserve attribution and license context.
