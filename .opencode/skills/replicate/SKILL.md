---
name: replicate
description: Plan or execute a replication workflow for a paper, claim, or benchmark.
compatibility: opencode
metadata:
  args: <paper>
  section: Research Workflows
---

# Replication

Design a replication plan for the user's target paper, claim, or benchmark.

Derive a short slug from the target: lowercase, hyphens, no filler words, at most 5 words. Create `outputs/.plans`, `outputs/replications/<slug>`, and `outputs` before writing artifacts.

Required artifacts:

- `outputs/.plans/<slug>-replication-plan.md`
- `outputs/replications/<slug>/notes.md`
- `outputs/<slug>-replication.md`

## Workflow

1. Extract: use the `researcher` agent to pull implementation details from the target paper and any linked code. If the task tool or researcher agent is unavailable or fails, extract lead-owned with available search/fetch tools and mark the limitation in the plan. If `CHANGELOG.md` exists, read the most recent relevant entries before planning or resuming.
2. Plan: determine what code, datasets, metrics, and environment are needed. Be explicit about what is verified, what is inferred, what is still missing, and which checks or test oracles will be used to decide whether the replication succeeded. Write the plan to `outputs/.plans/<slug>-replication-plan.md`.
3. Environment: before running anything, ask the user where to execute.
4. Execute: if the user chose an execution environment, implement and run the replication steps there. Save notes, scripts, raw outputs, and results under `outputs/replications/<slug>/`. Do not call the outcome replicated unless the planned checks actually passed.
5. Log: for multi-step or resumable replication work, append concise entries to `CHANGELOG.md` after meaningful progress, failed attempts, major verification outcomes, and before stopping. Record the active objective, what changed, what was checked, and the next step.
6. Report: write `outputs/<slug>-replication.md` and end with a `Sources` section containing paper and repository URLs. If execution is blocked or plan-only, still write the report with the blocked checks. Before responding, verify on disk that `outputs/<slug>-replication.md` exists.

## Execution Environments

Ask the user to choose one:

- Local: run in the current working directory
- Virtual environment: create an isolated venv or conda env first
- Docker: run experiment code inside an isolated Docker container
- Modal: run on Modal's serverless GPU infrastructure with a Modal-decorated Python script and `modal run <script.py>`; best for burst GPU jobs that do not need persistent state; requires `modal`
- RunPod: provision a GPU pod on RunPod and SSH in for execution; use `runpodctl` to create pods, transfer files, and manage lifecycle; best for long-running experiments or persistent storage; requires `runpodctl` and `RUNPOD_API_KEY`
- Plan only: produce the replication plan without executing

Before executing a Docker, Modal, or RunPod environment choice, check the corresponding runtime prerequisites such as `command -v docker`, `command -v modal`, `command -v runpodctl`, daemon access, and required authentication. If the chosen environment is unavailable, stop and ask the user whether to switch environments or continue with a plan-only report.

Do not install packages, run training, or execute experiments without confirming the execution environment first.
