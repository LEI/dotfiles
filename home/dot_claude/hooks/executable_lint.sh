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

  # TODO: evaluate alternatives (remark-lint, mdformat) and per-directory config
  # MD007: list indent level
  # MD013: line-length
  # MD022: blanks around headings
  # MD031: blanks around fences (noisy for models)
  # MD032: blanks around lists
  # MD012: no multiple blanks
  # MD034: no bare URLs (friction for note-taking)
  # MD040: fenced-code-language
  # MD041: first-line-h1 (conflicts with YAML frontmatter)
  # MD047: single trailing newline (noisy for models)
  # MD060: table-column-style
  *.md) lint_markdown --disable MD007 MD012 MD013 MD022 MD031 MD032 MD034 MD040 MD041 MD047 MD060 -- "$1" >&2 ;;

  *.sh)
    if has shellcheck; then
      shellcheck "$1" >&2
    fi
    ;;

  # -d "{extends: default, rules: {line-length: {max: 120}}}"
  *.yaml | *.yml)
    if has yamllint; then
      yamllint "$1" >&2
    fi
    ;;

  esac
}

lint "$FILE" || exit 2
