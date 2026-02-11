# Global rules

Prefer built-in tools: Read over cat, Edit/MultiEdit over sed/awk,
Grep over grep/rg, Glob over find, Write over echo/tee.
In Bash: fd over find, rg over grep, trash over rm.

Short responses, no emojis, no decorations. Reference code as file:line.
Preserve existing style and comments unless incorrect.
In comments, avoid dashes and trailing dots.

# Delegation

2+ independent units of work: ALWAYS spawn parallel Task subagents
in a single message. Never serialize independent work.

- Direct: single file, trivial fix, quick lookup
- Task subagent: research, exploration, isolated implementation, tests
- Agent team: cross-cutting coordination, competing hypotheses

Orchestrator plans, delegates, synthesizes. Do not implement when
subagents or teammates can. Subagents return concise summaries only.
Parallel subagents must touch disjoint files.
