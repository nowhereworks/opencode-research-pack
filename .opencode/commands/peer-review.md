---
name: peer-review
description: Simulate a tough but constructive peer review of an AI research artifact. Use when the user asks for a review, critique, feedback on a paper or draft, or wants to identify weaknesses before submission.
---

# Peer Review

Call the `skill` tool with name `review`.

User arguments: `$ARGUMENTS`

After the skill loads, execute its workflow using the user arguments. If no artifact was provided, ask one concise question for the artifact to review before proceeding.

Agents used: `researcher`, `reviewer` when delegation is available and useful; otherwise lead-owned review.

Output: structured review in `outputs/`.
