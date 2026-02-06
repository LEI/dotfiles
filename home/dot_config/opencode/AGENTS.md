# Global rules

Use task tool to run subagents for specialized work.
Execute independent tool calls in parallel.

Prefer MCP over built-in over bash:

- grep tool to search content, or rg as last resort
- read tool with limit and offset to avoid loading large files
- glob tool or fd instead of find
- list tool or `test -f` instead of ls
- write tool instead of echo, cat
- edit tool instead of sed, awk
- multiedit tool to group changes
- or batch similar edits once the first is accepted
- trash instead of rm
- git MCP `git_git_*` instead of git commands
- context7 MCP instead of webfetch for docs
- pty_spawn tool for interactive/long-running processes

Use todoread and todowrite extensively:

- track progress and follow-up ideas
- group similar items to use multiedit
- end with pending todos if follow-up exists

Keep code, comments, and responses short and concise.
Preserve comments unless incorrect or obsolete.
Use proper language structure, avoid emojis.

For feature work in projects without `openspec/` dir, suggest `openspec init --tools opencode`.
