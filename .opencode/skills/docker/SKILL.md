---
name: docker
description: Run research code in Docker containers for isolated replication, experiments, and benchmarks.
compatibility: opencode
metadata:
  args: <objective-or-command>
  section: Compute
---

# Docker Sandbox

Run or plan containerized work for the user's objective.

## Requirements

- Check `command -v docker` before relying on Docker.
- If Docker is installed, check daemon access with a lightweight status command before running workloads.
- If Docker is unavailable or inaccessible, explain the missing dependency and provide a manual container plan instead of pretending the work ran.
- Ask before running untrusted code, installing packages, training models, or starting long-running jobs.
- Mount only the needed workspace paths and keep outputs under project directories such as `outputs/`, `experiments/`, or `results/`.
- Prefer `--rm` for one-shot containers and named containers only when persistence is needed.

## Common Patterns

```bash
docker run --rm -v "$(pwd)":/workspace -w /workspace python:3.11 bash -c "python --version"
```

```bash
docker build -t opencode-experiment .
docker run --rm -v "$(pwd)/results":/workspace/results opencode-experiment
```

For GPU workloads, use `--gpus all` only when the host has NVIDIA Container Toolkit configured.

## Output

- Report the exact Docker command used or the blocked reason.
- Save important scripts, logs, and outputs to disk when executing multi-step work.
