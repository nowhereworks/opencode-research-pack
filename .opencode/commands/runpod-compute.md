---
name: runpod-compute
description: Provision and manage GPU pods on RunPod for long-running experiments. Use when the user needs persistent GPU compute with SSH access, large datasets, or multi-step experiments.
---

# RunPod Compute

Call the `skill` tool with name `runpod-compute`.

User arguments: `$ARGUMENTS`

After the skill loads, execute its workflow using the user arguments. If no workload was provided, ask one concise question for the RunPod workload before proceeding.
