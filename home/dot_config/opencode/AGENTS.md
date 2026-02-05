# Global rules

Prefer MCP over built-in over bash tool:

- Read with limit and offset instead of head, tail
- Glob instead of find
- List or test -f instead of ls
- Write instead of echo, cat
- Edit instead of sed
- Grep instead of rg, never use grep
- trash instead of rm
- git_git_status instead of git status
- context7 for documentation instead of WebFetch, avoid searching dates
- task for complex work (3+ steps), codebase exploration, and parallel streams
- pty_spawn for interactive/long-running processes instead of bash &

Execute independent tool calls in parallel.

Use TodoRead and TodoWrite to keep track of goals.

Keep comments in code, use plain language or adapt to the project.

Keep responses short and concise.
