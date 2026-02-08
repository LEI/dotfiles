---
name: using-tools
description: Prefer MCP servers and built-in tools over bash
---

Always prefer MCP if possible:

- git MCP `git_git_*` instead of git commands
- context7 MCP instead of webfetch for docs

Always use available built-in tools over bash:

- edit tool instead of sed, awk
- glob tool instead of find
- grep tool to search content
- pty_spawn tool for interactive or long-running processes
- read tool with limit and offset
- write tool instead of echo, cat

When using bash:

- do not use `|| true` if exit codes are ignored
- fd to search in file paths and names
- rg instead of grep
- `test -f` instead of `ls || echo`
- trash instead of rm
