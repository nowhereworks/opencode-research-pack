---
name: runpod-compute
description: Provision or manage RunPod GPU pods for persistent experiments when runpodctl is available.
compatibility: opencode
metadata:
  args: <workload>
  section: Compute
---

# RunPod Compute

Prepare or manage a RunPod workflow for the user's workload.

## Requirements

- Check `command -v runpodctl` before relying on RunPod.
- Check for required authentication such as `RUNPOD_API_KEY` or configured runpodctl credentials before creating resources.
- Ask before provisioning paid compute, opening SSH sessions, transferring large files, or starting long jobs.
- Prefer RunPod for persistent GPU pods, large datasets, SSH access, or multi-step experiments.
- If RunPod tooling or credentials are unavailable, explain the missing dependency and provide a manual plan or alternate environment instead of pretending a pod exists.
- Always include a cleanup reminder for stopping or removing pods.

## Useful Commands

Use these only after confirming `runpodctl` is installed and configured:

```bash
runpodctl get pod
runpodctl gpu list
runpodctl create pod --name experiment
runpodctl stop pod <id>
runpodctl remove pod <id>
```

## Output

- Report pod IDs, connection details, and cleanup state when available.
- Save run scripts and notes under `outputs/runpod/<slug>/` for reproducibility, and create that directory before writing.
