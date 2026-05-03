---
name: docker
description: Execute research code inside isolated Docker containers for safe replication, experiments, and benchmarks. Use when the user selects Docker as the execution environment or asks to run code safely, in isolation, or in a sandbox.
---

# Docker Sandbox

Call the `skill` tool with name `docker`.

User arguments: `$ARGUMENTS`

After the skill loads, execute its workflow using the user arguments. If no command or objective was provided, ask one concise question for the containerized task before proceeding.
