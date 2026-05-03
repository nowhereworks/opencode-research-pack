---
name: modal-compute
description: Run GPU workloads on Modal's serverless infrastructure. Use when the user needs remote GPU compute for training, inference, benchmarks, or batch processing and Modal CLI is available.
---

# Modal Compute

Call the `skill` tool with name `modal-compute`.

User arguments: `$ARGUMENTS`

After the skill loads, execute its workflow using the user arguments. If no workload was provided, ask one concise question for the Modal workload before proceeding.
