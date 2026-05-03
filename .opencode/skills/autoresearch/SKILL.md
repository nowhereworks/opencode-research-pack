---
name: autoresearch
description: Autonomous experiment loop that tries ideas, measures results, keeps what works, discards what does not, and repeats.
compatibility: opencode
metadata:
  args: <idea>
  section: Research Workflows
---

# Autoresearch

Start an autoresearch optimization loop for the user's idea.

This workflow depends on external pi-autoresearch tooling. Before relying on `init_experiment`, `run_experiment`, or `log_experiment`, check whether the corresponding tools or CLI commands are available. If they are unavailable, explain the missing dependency and produce a manual experiment-loop plan instead of pretending the loop is running.

## Step 1: Gather

If `autoresearch.md` and `autoresearch.jsonl` already exist, ask the user if they want to resume or start fresh.
If `CHANGELOG.md` exists, read the most recent relevant entries before resuming.

Otherwise, collect the following from the user before doing anything else:

- What to optimize: test speed, bundle size, training loss, build time, etc.
- The benchmark command to run
- The metric name, unit, and direction: lower or higher is better
- Files in scope for changes
- Maximum number of iterations, default 20

## Step 2: Environment

Ask the user where to run:

- Local: run in the current working directory
- New git branch: create a branch so main stays clean
- Virtual environment: create an isolated venv or conda env first
- Docker: run experiment code inside an isolated Docker container
- Modal: run on Modal's serverless GPU infrastructure with `modal run`; best for GPU-heavy benchmarks with no persistent state between iterations; requires `modal`
- RunPod: provision a GPU pod via `runpodctl` and run iterations over SSH; best for persistent state, large datasets, or SSH access; requires `runpodctl`

Do not proceed without a clear answer.

## Step 3: Confirm

Present the full plan to the user before starting:

```text
Optimization target: [metric] ([direction])
Benchmark command:   [command]
Files in scope:      [files]
Environment:         [chosen environment]
Max iterations:      [N]
```

Ask the user to confirm. Do not start the loop without explicit approval.

## Step 4: Run

Initialize the session: create `autoresearch.md` and `autoresearch.sh`, run the baseline, and start looping.

Each iteration: edit, commit, run the benchmark, log the experiment, keep or revert based on the metric, repeat. Do not stop unless interrupted or `maxIterations` is reached.

After the baseline and after meaningful iteration milestones, append a concise entry to `CHANGELOG.md` summarizing what changed, what metric result was observed, what failed, and the next step.

## Key Tools

- `init_experiment`: one-time session config with name, metric, unit, and direction
- `run_experiment`: run the benchmark command, capture output, and record wall-clock time
- `log_experiment`: record result, commit if appropriate, and update the dashboard

## Subcommands

- `/autoresearch <text>`: start or resume the loop
- `/autoresearch off`: stop the loop, keep data
- `/autoresearch clear`: delete all state and start fresh
