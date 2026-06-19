#!/bin/sh

# Sequence the PostToolUse workers so they don't race: a repo with its own
# pre-commit config goes to check.sh, otherwise format then lint

dir=$(dirname "$0")
payload=$(cat)
file=$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty')

has_runner() { command -v prek >/dev/null || command -v pre-commit >/dev/null; }

managed=0
if [ -n "$file" ] && [ "${CLAUDE_HOOK_CHECK_DISABLED:-0}" != "1" ] && has_runner; then
  root=$(git -C "$(dirname "$file")" rev-parse --show-toplevel 2>/dev/null)
  [ -n "$root" ] && [ -f "$root/.pre-commit-config.yaml" ] && managed=1
fi

rc=0
# block (2) wins; otherwise surface any non-zero
run() {
  printf '%s' "$payload" | sh "$dir/$1"
  status=$?
  if [ "$status" -eq 2 ]; then
    rc=2
  elif [ "$status" -ne 0 ] && [ "$rc" -ne 2 ]; then
    rc=$status
  fi
}

if [ "$managed" -eq 1 ]; then
  run check.sh
else
  run format.sh
  run lint.sh
fi

exit "$rc"
