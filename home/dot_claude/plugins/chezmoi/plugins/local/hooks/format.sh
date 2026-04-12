#!/bin/sh

# Sandboxed child processes may fail to resolve cwd
if ! cd "$(dirname "$0")" 2>/dev/null; then
  echo "format: cwd fallback to /tmp" >&2
  cd /tmp || exit
fi

FILE=$(jq -r '.tool_input.file_path // empty')
if [ -z "$FILE" ] || ! [ -f "$FILE" ]; then
  exit 0
fi

case "$FILE" in
*.chezmoitemplates/* | */modify_* | *.tmpl) exit 0 ;;
esac

has() {
  command -v "$1" >/dev/null
}

case "$FILE" in
*.md | *.json | *.jsonc | *.yaml | *.yml)
  IGNORE_PATH=$(git -C "$(dirname "$FILE")" rev-parse --show-toplevel 2>/dev/null)
  IGNORE_ARGS=""
  LOCAL_IGNORE="$(dirname "$FILE")/.prettierignore"
  if [ -f "$LOCAL_IGNORE" ]; then
    IGNORE_ARGS="--ignore-path $LOCAL_IGNORE"
  fi
  if [ -n "$IGNORE_PATH" ] && [ -f "$IGNORE_PATH/.prettierignore" ]; then
    IGNORE_ARGS="$IGNORE_ARGS --ignore-path $IGNORE_PATH/.prettierignore"
  fi
  if has prettier; then
    # shellcheck disable=SC2086
    prettier $IGNORE_ARGS --write "$FILE" >/dev/null
  elif has npx; then
    # shellcheck disable=SC2086
    npx --yes prettier $IGNORE_ARGS --write "$FILE" >/dev/null
  fi
  ;;
*.sh)
  if has shfmt; then
    shfmt --write "$FILE"
  fi
  ;;
esac
