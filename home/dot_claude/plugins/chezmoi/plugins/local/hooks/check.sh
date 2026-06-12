#!/bin/sh

# Gate the repo's own pre-commit checks at edit time, before commit
[ "${CLAUDE_HOOK_CHECK_DISABLED:-0}" = "1" ] && exit 0

FILE=$(jq -r '.tool_input.file_path // empty')
[ -n "$FILE" ] || exit 0
[ -f "$FILE" ] || exit 0

root=$(git -C "$(dirname "$FILE")" rev-parse --show-toplevel 2>/dev/null) || exit 0
[ -f "$root/.pre-commit-config.yaml" ] || exit 0

# prek matches files relative to the repo root
if ! cd "$root" 2>/dev/null; then
  echo "check: cannot enter repo root $root" >&2
  exit 1
fi
runner=$(command -v prek || command -v pre-commit) || exit 0
rel=${FILE#"$root"/}

# Both exit non-zero; only an unchanged file is a real failure, a rewrite was auto-fixed
snapshot=$(mktemp) || exit 0
cp "$FILE" "$snapshot"
out=$("$runner" run --files "$rel" 2>&1)
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
