# Global rules

Always prefer built-in tools. If you must use bash, never use `ls` or `rm`:

- fd to search in file paths and names
- rg instead of grep
<!-- - trash instead of rm -->

Always use relative paths except for external directories, avoid `cd`.

Keep code clean and responses short.
Preserve comments unless incorrect or obsolete.
Use proper language, no decorations or emojis.

Use `npm search --json --search "keywords:pi-package"` to search packages.
Prefer `pnpm` to install or `bunx` to execute instead of `npm`.

Use `gh api` or `gh search repos --topic pi-package` to search repositories
instead of `curl` or web search.
