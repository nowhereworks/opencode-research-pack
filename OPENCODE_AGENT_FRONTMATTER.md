# OpenCode Agent Frontmatter

This documents the YAML parameters that can be placed between `---` markers at the top of an OpenCode Markdown agent file.

Canonical docs checked:

- `https://opencode.ai/docs/agents/`
- `https://opencode.ai/docs/permissions/`
- `https://opencode.ai/docs/tools/`
- `https://opencode.ai/config.json`

Markdown agents live in `.opencode/agents/<agent-name>.md` for project agents or `~/.config/opencode/agents/<agent-name>.md` for global agents. OpenCode docs say the Markdown file name becomes the agent name, so `review.md` creates the `review` agent.

## Minimal Agent

```markdown
---
description: Reviews code for quality and best practices
mode: subagent
permission:
  edit: deny
  bash: ask
---

You are in code review mode. Focus on bugs, regressions, tests, security, and maintainability.
```

## Documented Parameters

| Parameter | Values | Default | Notes |
|---|---|---|---|
| `description` | String | Required by docs | Brief description of what the agent does and when to use it. Primary agents use this for selection context; subagents use it for routing and `@` autocomplete. |
| `mode` | `primary`, `subagent`, `all` | `all` | `primary` agents are directly selectable. `subagent` agents can be invoked by primary agents or via `@mention`. `all` can be used both ways. |
| `model` | String in `provider/model-id` format | Primary agents use global `model`; subagents inherit the invoking primary agent model | Examples: `anthropic/claude-sonnet-4-20250514`, `opencode/gpt-5.1-codex`. Run `opencode models` to inspect local availability. |
| `variant` | String | None | Model variant to use when the agent has a configured `model`. Common built-ins include Anthropic `high`, `max`; OpenAI `none`, `minimal`, `low`, `medium`, `high`, `xhigh`; Google `low`, `high`. Exact values are provider/model-specific. |
| `temperature` | Number, commonly `0.0` through `1.0` | Model-specific; docs say usually `0`, Qwen usually `0.55` | Lower values are more deterministic. Docs describe `0.0-0.2` focused, `0.3-0.5` balanced, `0.6-1.0` more varied. |
| `top_p` | Number `0.0` through `1.0` | Model/provider default | Alternative diversity control. Lower is more focused; higher is more diverse. |
| `steps` | Positive integer | Unlimited until model stops or user interrupts | Maximum number of agentic iterations before OpenCode forces a text-only response. |
| `disable` | Boolean: `true`, `false` | `false` | Set `true` to disable the agent. |
| `prompt` | String | Markdown body after frontmatter | In JSON config this can be inline text or a file variable such as `{file:./prompts/review.txt}`. For Markdown agents, the body below frontmatter is normally the system prompt. |
| `permission` | Action string or permission object | Global/default permissions | Preferred way to control tool access. Replaces deprecated `tools`. Detailed below. |
| `tools` | Object of tool or wildcard name to boolean | Deprecated | Deprecated since permissions merged tool enablement. `true` maps to allow, `false` maps to deny. Prefer `permission`. |
| `hidden` | Boolean: `true`, `false` | `false` | Only applies to `mode: subagent`. Hides the subagent from `@` autocomplete, but other agents can still invoke it via Task if permissions allow. |
| `color` | Hex `#RRGGBB` or theme color | UI default | Theme colors: `primary`, `secondary`, `accent`, `success`, `warning`, `error`, `info`. |
| `options` | Object | None | Provider/model-specific options. The schema accepts arbitrary keys and values. |
| `maxSteps` | Positive integer | Deprecated | Deprecated legacy field. Use `steps`. |

## Additional Provider Options

OpenCode docs state that any other options in an agent configuration are passed directly to the provider as model options. The current schema also allows additional top-level agent properties.

Examples from the docs:

```yaml
reasoningEffort: high
textVerbosity: low
```

These are provider-specific, so possible values depend on the selected provider and model. Check the provider documentation and OpenCode model configuration docs before relying on them.

## Permission Values

`permission` can be one action string for everything:

```yaml
permission: ask
```

Or an object keyed by permission/tool names:

```yaml
permission:
  edit: deny
  bash:
    "*": ask
    "git diff*": allow
    "git log*": allow
    "git push*": deny
```

Permission actions:

| Action | Meaning |
|---|---|
| `allow` | Run without approval. |
| `ask` | Prompt before running. |
| `deny` | Block the action or hide it from the model where applicable. |

Permission keys documented for agents and permissions:

| Key | Values | Gates / matches |
|---|---|---|
| `read` | Action or pattern object | File reads; patterns match file paths. |
| `edit` | Action or pattern object | File modifications: `write`, `edit`, `apply_patch`; patterns match file paths. |
| `glob` | Action or pattern object | File globbing; patterns match glob inputs. |
| `grep` | Action or pattern object | Content search; patterns match regex inputs. |
| `list` | Action or pattern object | Directory listing/list tool access. Listed in the current agents docs/schema. |
| `bash` | Action or pattern object | Shell commands; patterns match parsed commands such as `git status --porcelain`. |
| `task` | Action or pattern object | Subagent launches; patterns match subagent names. Use this to control which subagents an agent can invoke. |
| `external_directory` | Action or pattern object | Any tool touching paths outside the project worktree; patterns match external paths. |
| `todowrite` | Action | Todo tools: `todowrite`, `todoread`. Disabled for subagents by default unless enabled manually. |
| `question` | Action | Asking the user questions during execution. |
| `webfetch` | Action | Fetching URLs. The permissions page describes URL matching, but the agents docs show shorthand-only. Prefer shorthand unless verified locally. |
| `websearch` | Action | Web search. The permissions page describes query matching, but the agents docs show shorthand-only. Prefer shorthand unless verified locally. |
| `lsp` | Action or pattern object in schema | LSP tool access. The permissions page says this is currently non-granular, so prefer shorthand. |
| `skill` | Action or pattern object | Loading skills; patterns match skill names. |
| `doom_loop` | Action | Recovery prompts when an agent repeats the same tool call 3 times with identical input. |
| Custom tool or MCP tool name | Action or pattern object | Permission keys are matched as wildcard patterns against tool names. Example: `mymcp_*: deny`. |

Pattern object values use wildcard matching:

```yaml
permission:
  bash:
    "*": ask
    "git status*": allow
    "git commit*": ask
    "git push*": deny
  task:
    "*": deny
    "researcher": allow
    "reviewer": ask
```

Pattern rules are evaluated in order and the last matching rule wins. Put broad catch-all rules first and specific overrides after.

Wildcard syntax:

| Pattern | Meaning |
|---|---|
| `*` | Matches zero or more characters. |
| `?` | Matches exactly one character. |
| Any other character | Matches literally. |

## Deprecated `tools`

`tools` is still supported for backwards compatibility but should not be used for new agents.

```yaml
tools:
  write: false
  bash: true
  mymcp_*: false
```

Values are booleans:

| Value | Equivalent permission meaning |
|---|---|
| `true` | Allow the matching tool. |
| `false` | Deny the matching tool. |

Built-in tool names include `bash`, `edit`, `write`, `read`, `grep`, `glob`, `lsp`, `apply_patch`, `skill`, `todowrite`, `webfetch`, `websearch`, and `question`. Prefer permission keys where `edit` covers `write`, `edit`, and `apply_patch`.

## Repo-Local Notes

This repo's current agent files include:

```yaml
name: researcher
```

`name` is a repo convention carried over from the port, not a documented OpenCode agent option in the current docs. The OpenCode docs say the file name is the agent name. If `name` is kept in frontmatter for readability, keep it identical to the file stem, for example `.opencode/agents/researcher.md` uses `name: researcher`.

The currently commented fields in this repo, such as `thinking`, `output`, and `defaultProgress`, are not documented OpenCode agent fields. If uncommented, they would be treated as additional provider/model options or inert metadata depending on OpenCode/provider behavior; verify before relying on them.

## Recommended Template

```markdown
---
name: example
description: Short description of when to use this agent.
mode: subagent
model: opencode/gpt-5.1-codex
variant: high
temperature: 0.1
steps: 20
color: accent
permission:
  read: allow
  grep: allow
  glob: allow
  edit: deny
  bash:
    "*": ask
    "git diff*": allow
    "git log*": allow
  webfetch: allow
  task:
    "*": deny
    "researcher": allow
---

Agent system prompt goes here.
```

For strict canonical OpenCode docs compliance, omit `name` and let the file name define the agent name.
