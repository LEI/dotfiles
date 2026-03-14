#!/bin/sh

FILE=$(jq -r '.tool_input.file_path // empty')
if [ -z "$FILE" ] || ! [ -f "$FILE" ]; then
  exit 0
fi

has() {
  command -v "$1" >/dev/null
}

case "$FILE" in
*.md | *.json | *.jsonc | *.yaml | *.yml)
  if has prettier; then
    prettier --write "$FILE" >/dev/null
  elif has npx; then
    npx --yes prettier --write "$FILE" >/dev/null
  fi
  ;;
*.sh)
  if has shfmt; then
    shfmt --write "$FILE"
  fi
  ;;
esac
