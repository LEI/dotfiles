#!/bin/sh

# Edit-time gate so a real check failure blocks now, not at commit
# Disable with CLAUDE_HOOK_CHECK_DISABLED=1
[ "${CLAUDE_HOOK_CHECK_DISABLED:-0}" = "1" ] && exit 0

# Sandboxed child processes may fail to resolve cwd
cd "$(dirname "$0")" 2>/dev/null || cd /tmp || exit 0

FILE=$(jq -r '.tool_input.file_path // empty')
[ -n "$FILE" ] || exit 0
[ -f "$FILE" ] || exit 0

runner=$(command -v prek || command -v pre-commit) || exit 0
root=$(git -C "$(dirname "$FILE")" rev-parse --show-toplevel 2>/dev/null) || exit 0
[ -f "$root/.pre-commit-config.yaml" ] || exit 0
rel=${FILE#"$root"/}

# A fixer rewrite and a real failure both exit non-zero, so block only when the
# run left the file unchanged; a rewrite means it was auto-fixed, not failing
snapshot=$(mktemp) || exit 0
cp "$FILE" "$snapshot"
out=$(cd "$root" && "$runner" run --files "$rel" 2>&1)
status=$?

if [ "$status" -eq 0 ]; then
  rm -f "$snapshot"
  exit 0
fi

echo "$out" >&2
if cmp -s "$FILE" "$snapshot"; then
  rm -f "$snapshot"
  echo "check: $rel failed repo checks; fix before commit" >&2
  exit 2
fi
rm -f "$snapshot"
echo "check: $rel was auto-fixed; review the change" >&2
exit 0
