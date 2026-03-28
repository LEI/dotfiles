#!/bin/sh

# Sandboxed child processes may fail to resolve cwd
if ! cd "$(dirname "$0")" 2>/dev/null; then
  echo >&2 "lint: cwd fallback to /tmp"
  cd /tmp || exit
fi

FILE=$(jq -r '.tool_input.file_path // empty')
if [ -z "$FILE" ]; then
  exit 0
fi
if ! [ -f "$FILE" ]; then
  echo >&2 "lint: file not found: $FILE"
  exit 2
fi

has() {
  command -v "$1" >/dev/null
}

case "$FILE" in
*.chezmoitemplates/* | */modify_* | *.tmpl) exit 0 ;;
esac

lint() {
  case "$FILE" in
  *.md)
    MD_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/markdownlint/claude.yaml"
    if has markdownlint; then
      markdownlint --config "$MD_CONFIG" "$FILE" >&2
    elif has npx; then
      npx --yes markdownlint-cli --config "$MD_CONFIG" "$FILE" >&2
    fi
    ;;
  *.sh)
    if has shellcheck; then
      shellcheck --shell=bash --severity=warning "$FILE" >&2
    fi
    ;;
  *.yaml | *.yml)
    if has yamllint; then
      yamllint --strict "$FILE" >&2
    fi
    ;;
  esac
}

lint
rc=$?
if [ "$rc" -ne 0 ]; then
  echo >&2 "lint: $(basename "$FILE") failed (exit $rc)"
  exit 2
fi
