---
name: modal-compute
description: Prepare or run GPU workloads on Modal serverless compute when the Modal CLI is available.
compatibility: opencode
metadata:
  args: <workload>
  section: Compute
---

# Modal Compute

Prepare or run the user's Modal workload.

## Requirements

- Check `command -v modal` before relying on Modal.
- If Modal is unavailable, explain the missing dependency and provide setup or a local/Docker alternative instead of pretending the workload ran.
- Ask before installing packages, authenticating, launching paid compute, or running long jobs.
- Prefer Modal for stateless burst GPU jobs that do not need persistent state between runs.
- For persistent SSH-style workflows, recommend RunPod or another persistent environment instead.

## Script Pattern

```python
import modal

app = modal.App("experiment")
image = modal.Image.debian_slim(python_version="3.11").pip_install("torch")

@app.function(gpu="A100", image=image, timeout=600)
def train():
    pass

@app.local_entrypoint()
def main():
    train.remote()
```

## Output

- Write any generated Modal script to disk before running it.
- Report the exact `modal run`, `modal deploy`, or blocked setup step.
