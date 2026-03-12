#!/bin/sh

FILE=$(jq -r '.tool_input.file_path // empty')
if [ -z "$FILE" ] || ! [ -f "$FILE" ]; then
  exit 0
fi

has() {
  command -v "$1" >/dev/null
}

case "$FILE" in
*.md)
  MD_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/markdownlint/claude.yaml"
  if has markdownlint; then
    markdownlint --config "$MD_CONFIG" "$FILE" >&2 || exit 2
  elif has npx; then
    npx --yes markdownlint-cli --config "$MD_CONFIG" "$FILE" >&2 || exit 2
  fi
  ;;
*.sh)
  if has shellcheck; then
    shellcheck --shell=bash --severity=warning "$FILE" >&2 || exit 2
  fi
  ;;
*.yaml | *.yml)
  if has yamllint; then
    yamllint -d "{extends: default, rules: {line-length: {max: 120}, comments: {min-spaces-from-content: 1}}}" "$FILE" >&2 || exit 2
  fi
  ;;
esac
