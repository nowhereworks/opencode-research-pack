# Feynman OpenCode Configuration

> Attribution: this repository is an independent OpenCode-optimized port of workflows and related assets from [Feynman](https://feynman.is), the open source AI research agent by Companion. See the upstream project at [getcompanion-ai/feynman](https://github.com/getcompanion-ai/feynman). This repository is not the official upstream Feynman project.

This repository contains an OpenCode configuration port for Feynman-style research workflows. It packages reusable agents, commands, and skills for research-heavy OpenCode sessions.

Source lives primarily under `.opencode/agents/`, `.opencode/commands/`, and `.opencode/skills/`.

## Quick Start

This repo is meant to be used from inside an OpenCode workspace. A good first run looks like this:

1. Clone the repository.
2. Open a shell in the repo.
3. Start OpenCode with `OPENCODE_ENABLE_EXA=1` enabled so research commands can use `websearch`.
4. Verify that the bundled `researcher` agent resolves `websearch` support.
5. Start with one of the included slash commands such as `/deepresearch`, `/literature-review`, or `/eli5`.

```bash
git clone https://github.com/nowhereworks/opencode-research-pack.git
cd opencode-research-pack
export OPENCODE_ENABLE_EXA=1
opencode
```

In a second shell, or before opening a session, verify the agent setup with:

```bash
opencode debug agent researcher
```

The resolved `researcher` agent should include `websearch: true`.

Once OpenCode is running in this repo, try one of these:

```text
/deepresearch mechanistic interpretability
/literature-review retrieval augmented generation evaluation
/eli5 diffusion models
```

Expected behavior:

- research-heavy commands write output files to `outputs/`
- many workflows also write a matching `.provenance.md` sidecar
- if optional external tools are missing, commands should degrade explicitly rather than fail silently

## What This Repo Contains

- OpenCode agents under `.opencode/agents/`
- OpenCode commands under `.opencode/commands/`
- OpenCode skills under `.opencode/skills/`
- Repo-specific contribution guidance in `AGENTS.md`

## Included Workflows

- Research and literature review workflows such as `/deepresearch`, `/literature-review`, and `/source-comparison`
- Audit, replication, and review workflows such as `/paper-code-audit`, `/replication`, and `/peer-review`
- Support workflows such as `/summarize`, `/session-search`, `/session-log`, `/jobs`, and `/watch`
- Optional compute-oriented workflows for Docker, Modal, and RunPod environments

## Porting Map

- Feynman `agents` -> OpenCode agents
- Feynman `prompts` -> OpenCode skills
- Feynman `skills` -> OpenCode commands

This repo is a configuration and workflow port, not an application or general-purpose library.

## Attribution

This repository is an independent OpenCode-focused port of workflows, commands, skills, and agent patterns inspired by and adapted from [Feynman](https://feynman.is).

Upstream project:

- Website: `https://feynman.is`
- Source: `https://github.com/getcompanion-ai/feynman`

This repository is not the upstream Feynman project. It repackages and adapts selected Feynman concepts and workflow structures for OpenCode.

## Operational Requirements

Research workflows such as `/deepresearch` depend on OpenCode's native `websearch` tool for source discovery.

If `websearch` is unavailable, workflows can still fetch known URLs with `webfetch`, but general source discovery will be degraded or blocked.

## Repository Layout

```text
.opencode/
  agents/      OpenCode subagents used by command workflows
  commands/    User-facing slash commands
  skills/      Reusable local skill implementations
docs/          Supporting repository documentation
AGENTS.md      Repo-specific contributor and agent guidance
```

## Tool Inventory

The workflows intentionally keep references to optional external tools. Missing external tools should be checked at runtime and handled with a blocked or degraded path, not silently removed.

| Tool / Command | Provider | Used by | Purpose | Notes / Fallback |
|---|---|---|---|---|
| `skill` | OpenCode | All command launchers | Load local skills from `.opencode/skills/` | Required for command-to-skill dispatch. |
| `task` | OpenCode | Research, review, summarize workflows | Spawn subagents such as `researcher`, `writer`, `verifier`, `reviewer` | If unavailable, workflows should continue lead-owned and record degraded mode. |
| Optional memory tool | OpenCode runtime, if configured | `deepresearch` | Persist plan state between steps | Referenced conditionally; workflows must continue if unavailable. |
| `read`, `grep`, `glob`, `edit`, `list`, `bash` | OpenCode | Agents and lead workflow execution | File inspection, edits, shell execution, directory listings | Availability depends on current agent permissions. |
| `websearch` | OpenCode | Research and verification workflows | Discover current web sources | Requires `OPENCODE_ENABLE_EXA=1`; degrade to known URL fetches or blocked source discovery when unavailable. |
| `webfetch` | OpenCode | Research and verification workflows | Fetch known URLs for source inspection | Does not replace disk-first fetches for very large sources. |
| `opencode debug config` | OpenCode CLI | Contributing validation | Check resolved OpenCode configuration | Run after command, agent, or skill edits. |
| `opencode debug skill` | OpenCode CLI | Contributing validation | Check discovered skills | Run after skill edits. |
| `opencode debug agent` | OpenCode CLI | Operational checks | Inspect resolved agent tools | Useful for confirming `websearch` availability. |
| `opencode session list` | OpenCode CLI | `session-search` | List OpenCode sessions | If unavailable, search known OpenCode data paths when reachable. |
| `opencode export <sessionID>` | OpenCode CLI | `session-search` | Export session details | Suggest exact command when user needs full transcript. |
| `opencode debug paths` | OpenCode CLI | `session-search` | Locate OpenCode data directories | Fallback before direct file search. |
| `alpha` | External CLI | `alpha-research`, `researcher`, `eli5` | Academic paper search/read/Q&A/code inspection | Check `command -v alpha`; fallback to `websearch`/`webfetch` with degraded paper coverage. |
| `alpha search` | External CLI | `alpha-research` | Search academic papers | `websearch` can partially replace source discovery, not annotations or paper-specific local state. |
| `alpha get` / `alpha get --full-text` | External CLI | `alpha-research` | Fetch paper content | Use web metadata or known URLs if unavailable; mark full-text coverage degraded. |
| `alpha ask` | External CLI | `alpha-research` | Ask questions about a paper | Fallback is manual reading of available source material. |
| `alpha code` | External CLI | `alpha-research` | Inspect paper code repositories | Fallback is web/GitHub source inspection when URLs are available. |
| `alpha annotate` | External CLI | `alpha-research` | Manage paper annotations | No OpenCode-native equivalent in this repo. |
| `init_experiment` | External pi-autoresearch tooling | `autoresearch` | Initialize experiment metadata | If missing, produce a manual experiment-loop plan and stop unless manual execution is explicitly approved. |
| `run_experiment` | External pi-autoresearch tooling | `autoresearch` | Run benchmark and capture metrics | Manual benchmark execution is possible only with explicit user approval. |
| `log_experiment` | External pi-autoresearch tooling | `autoresearch` | Log result and commit/update dashboard when approved | Do not replace with implicit git commits without user approval. |
| `pi-processes` | External CLI | `jobs` | List managed background processes | Check `command -v pi-processes`; report blocked if unavailable. |
| `pi-schedule-prompt` | External CLI | `jobs`, `watch` | List or create scheduled research follow-ups | Check `command -v pi-schedule-prompt`; record blocked scheduling when unavailable. |
| `docker` | External CLI | `docker`, `replicate`, `autoresearch` | Run workloads in containers | Check install and daemon access before use. |
| `docker run` | External CLI | `docker`, `replicate`, `autoresearch` | Execute containerized commands | Ask before untrusted, installing, training, or long-running workloads. |
| `docker build` | External CLI | `docker` | Build a local experiment image | Check daemon access first. |
| `modal` | External CLI | `modal-compute`, `replicate`, `autoresearch` | Run Modal serverless compute workloads | Check `command -v modal`; ask before paid/long-running work. |
| `modal run` | External CLI | `modal-compute`, `replicate`, `autoresearch` | Run a Modal app/script | Ask before paid/long-running work. |
| `modal deploy` | External CLI | `modal-compute` | Deploy a Modal app | Ask before deployment. |
| `runpodctl` | External CLI | `runpod-compute`, `replicate`, `autoresearch` | Provision and manage RunPod GPU pods | Check install and authentication before paid/remote work. |
| `runpodctl get pod` | External CLI | `runpod-compute` | List existing RunPod pods | Requires configured RunPod credentials. |
| `runpodctl gpu list` | External CLI | `runpod-compute` | List available GPU options | Requires configured RunPod credentials. |
| `runpodctl create pod` | External CLI | `runpod-compute` | Provision a RunPod pod | Ask before paid compute. |
| `runpodctl stop pod` | External CLI | `runpod-compute` | Stop a RunPod pod | Include cleanup state in output. |
| `runpodctl remove pod` | External CLI | `runpod-compute` | Remove a RunPod pod | Ask before destructive cleanup if state could be lost. |
| `RUNPOD_API_KEY` | Environment variable | `runpod-compute`, `replicate` | RunPod authentication | Required when `runpodctl` is not otherwise configured. |
| `curl` | External CLI / system tool | `summarize` | Disk-first remote URL fetch for RLM summarization | Check `command -v curl`; use OpenCode fetch only for small safe sources. |
| `pdftotext` | External CLI / Poppler | `summarize` | Extract text from PDFs | Use equivalent extractor if available; otherwise mark PDF extraction blocked. |
| `pandoc` | External CLI | `preview` | Export/render documents | Check before use. |
| `pdflatex` | External CLI | `preview` | Build LaTeX/PDF artifacts | Check before use. |
| `xdg-open` | External CLI / desktop tool | `preview` | Open local previews | Check before use; report blocked viewer when unavailable. |
| Browser CLIs | External CLI / desktop tool | `preview` | Open rendered artifacts in a browser | Tool name depends on environment. |
| `git` | External CLI | `autoresearch`, contributing work | Inspect status and optionally commit when explicitly requested | Never run destructive git commands without explicit user approval. |
| `command -v` | Shell builtin / system shell | External-tool checks | Detect CLI availability | Use before relying on optional external tools. |
