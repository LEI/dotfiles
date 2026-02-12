In Bash: fd over find, rg over grep, trash over rm.
Preserve existing style and comments unless incorrect.
In comments, avoid dashes and trailing dots.

# Orchestration

Orchestrator plans, delegates, synthesizes.
Delegate any task requiring 2+ tool calls.

Parallelize when tasks are independent.
Parallel subagents must touch disjoint files.

Subagents return concise results with file:line refs.

Subagent model selection:
- haiku: search, inspection, mechanical edits
- sonnet: implementation, multi-file work
- opus: architecture, ambiguity

Never retry the same failing approach.
Escalate to the user or delegate fresh.
