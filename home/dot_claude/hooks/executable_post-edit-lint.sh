#!/bin/bash

# PostToolUse hook: lint edited files by extension
# Exit 0: success | Exit 2: violations (stderr fed to Claude)

FILE=$(jq -r '.tool_input.file_path // empty')
[[ -z "$FILE" || ! -f "$FILE" ]] && exit 0

has() {
  command -v "$1" >/dev/null
}

lint_markdown() {
  if has markdownlint; then
    markdownlint "$@"
  else
    npx --yes markdownlint-cli "$@"
  fi
}

lint() {
  case "$1" in

  # MD007: list indent level
  # MD013: line-length
  # MD022: blanks around headings
  # MD032: blanks around lists
  # MD040: fenced-code-language
  # MD060: table-column-style
  *.md) lint_markdown --disable MD007 MD013 MD022 MD032 MD040 MD060 -- "$1" ;;

  *.sh) has shellcheck && shellcheck "$1" ;;

  # -d "{extends: default, rules: {line-length: {max: 120}}}"
  *.yaml | *.yml) has yamllint && yamllint "$1" ;;

  esac
}

lint "$FILE" || exit 2
