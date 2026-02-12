#!/bin/sh

export OPENCODE_EXPERIMENTAL=true
export OPENCODE_EXPERIMENTAL_LSP_TOOL=true

# FIXME: disable auto loading
# https://github.com/anomalyco/opencode/blob/dev/packages/opencode/src/flag/flag.ts
# OPENCODE_DISABLE_CLAUDE_CODE=true
# OPENCODE_DISABLE_CLAUDE_CODE_PROMPT=true
# OPENCODE_DISABLE_CLAUDE_CODE_SKILLS=true
# OPENCODE_DISABLE_EXTERNAL_SKILLS=true
opencode() { env opencode "${@:---continue}"; }
# if command -v opencode >/dev/null; then
# opencode() {
#   if [ $# -eq 0 ]; then
#     env opencode --continue
#   else
#     env opencode "$@"
#   fi
# }
alias oc=opencode
# fi
