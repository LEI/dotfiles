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
*.json | *.jsonc | *.md)
  PROJECT_ROOT=$(git -C "$(dirname "$FILE")" rev-parse --show-toplevel 2>/dev/null)
  IGNORE_ARGS=""
  LOCAL_IGNORE="$(dirname "$FILE")/.prettierignore"
  if [ -f "$LOCAL_IGNORE" ]; then
    IGNORE_ARGS="$IGNORE_ARGS --ignore-path $LOCAL_IGNORE"
  fi
  if [ -n "$PROJECT_ROOT" ] && [ -f "$PROJECT_ROOT/.prettierignore" ]; then
    IGNORE_ARGS="$IGNORE_ARGS --ignore-path $PROJECT_ROOT/.prettierignore"
  fi
  if has prettier; then
    # shellcheck disable=SC2086
    prettier $IGNORE_ARGS --write "$FILE" >/dev/null
  fi
  ;;
*.sh)
  if has shfmt; then
    shfmt --write "$FILE"
  fi
  ;;
*.toml)
  if has taplo; then
    taplo format "$FILE" >/dev/null
  fi
  ;;
*.yaml | *.yml)
  if has yamlfmt; then
    # Run from project root so .yamlfmt.yml is discovered. The -dstar flag
    # makes yamlfmt honor `exclude:` for explicit file args (it would
    # otherwise be applied only to directory walks).
    PROJECT_ROOT=$(git -C "$(dirname "$FILE")" rev-parse --show-toplevel 2>/dev/null)
    if [ -n "$PROJECT_ROOT" ]; then
      REL=${FILE#"$PROJECT_ROOT"/}
      (cd "$PROJECT_ROOT" && yamlfmt -dstar "$REL") >/dev/null 2>&1
    else
      yamlfmt -dstar "$FILE" >/dev/null 2>&1
    fi
  fi
  ;;
esac
