# Global rules

Preserve existing style and comments unless incorrect.
In comments, avoid dashes and trailing dots.

Prefer fd over find for file search, always -L for symlinks.
Prefer rg over grep for content search, always -L for symlinks, -r means --replace not recursive.
Prefer trash over rm for deletion, rmdir for empty directories.
Keep shell commands simple; avoid piping and inline scripting.
Subagents return concise results with file:line refs.
