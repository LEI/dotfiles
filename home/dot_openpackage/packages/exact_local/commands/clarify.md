---
description: Ask the user precise clarifying questions before proceeding
allowed-tools: AskUserQuestion
agent: plan
---

Ask precise, plainly-worded questions before acting on an ambiguous request,
per the AskUserQuestion structure rules: one concern per question, single-select
only for a genuine fork, recommend an option with its reason. Stay clear even
under a terse output style; a real fork must not collapse into a vague one-liner.

If nothing actually needs clarifying, say so and continue.

$ARGUMENTS
