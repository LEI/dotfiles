#!/bin/sh

# Claude-scoped PATH, not the global shell: resolves project-pinned mise tools
# shellcheck disable=SC2016
echo 'export PATH="$HOME/.local/share/mise/shims:$PATH"' >>"$CLAUDE_ENV_FILE"
