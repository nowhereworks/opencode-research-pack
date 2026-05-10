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

## Workflow Automation Boundaries

- Move fully deterministic workflow mechanics into scripts when doing so improves predictability, repeatability, or token efficiency.
- Apply this guidance across skills, agents, subagents, commands, prompts, and workflow launchers where applicable.
- Scripts may replace prompt instructions for mechanics that are 100% rule-based: slug derivation, input validation, directory creation, canonical path emission, artifact skeleton creation, repeated boilerplate files, rule-based final candidate selection, delivery copies, and artifact-contract checks.
- Scripts must not replace model-owned judgment: planning substance, scope decisions, research decomposition, search strategy, source selection, evidence sufficiency, synthesis, claim support checks, citation relevance, review findings, or quality verification.
- Treat script checks as mechanical checks unless explicitly documented otherwise. A script can prove that files exist, paths are valid, fields are present, or statuses use allowed values; it cannot prove that sources support claims or that an artifact is correct.
- Keep mechanical artifact checks separate from quality verification. Prefer explicit fields such as `Artifact check: PASS|FAIL` for script-owned checks and `Verification: PASS|PASS WITH NOTES|BLOCKED` for model-owned quality decisions.
- If a script command is named `verify`, document what it verifies. Do not let a passing artifact check imply research quality, citation quality, or task completion quality.
- Skills or commands that rely on scripts must retain degraded-mode behavior when scripts or external tools fail, unless the script is required for safe execution.
- Do not remove existing functionality from `SKILL.md`, agent files, or command files unless the replacement script covers the same deterministic behavior and the remaining prompt still owns all non-deterministic decisions.

## Validation

- No repo-level `npm test`, `npm run lint`, `npm run build`, or `npm run typecheck` scripts are defined.
- After editing agent or command Markdown, verify frontmatter names match file/directory names and referenced agents/commands exist.
- After adding or changing workflow scripts, run syntax checks such as `bash -n` for shell scripts and smoke-test deterministic commands under `/tmp/opencode`.
- After moving behavior from Markdown instructions into scripts, verify the corresponding skill, command, agent, or subagent still documents all model-owned quality checks and degraded-mode paths.
- Use `https://opencode.ai/docs` as the canonical OpenCode reference when checking syntax or behavior.

## External Tooling

- Commands reference external tools not provided here: `alpha`, `docker`, `modal`, `runpodctl`, `pi-autoresearch`, `pi-processes`, and `pi-schedule-prompt`; check availability before relying on them.
- `.opencode/commands/contributing.md` documents upstream Feynman conventions, not this port; do not apply its `src/`, `prompts/`, `skills/`, or `npm test/typecheck/build` assumptions unless working inside upstream Feynman.
