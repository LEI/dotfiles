Prefer built-in tools over bash and MCP servers over built-in tools:

- Read with limit and offset instead of head, tail
- Glob instead of ls, find
- Write instead of echo, cat
- Edit instead of sed, awk
- Grep instead of bash grep (or use rg via bash when needed)
- Git MCP tools instead of git CLI
- Context7 for library docs instead of Google/WebFetch
- Task (explore agent) for codebase exploration instead of direct Glob/Grep
- PTY for interactive/long-running processes instead of bash &

Execute independent tool calls in parallel when possible.

Keep responses short and concise.
