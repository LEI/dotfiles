#!/bin/sh

# Sandboxed child processes may fail to resolve cwd
if ! cd "$(dirname "$0")" 2>/dev/null; then
  echo "lint: cwd fallback to /tmp" >&2
  cd /tmp || exit
fi

FILE=$(jq -r '.tool_input.file_path // empty')
if [ -z "$FILE" ]; then
  exit 0
fi
if ! [ -f "$FILE" ]; then
  echo "lint: file not found: $FILE" >&2
  exit 2
fi

has() {
  command -v "$1" >/dev/null
}

lint() {
  # Templates: markdownlint and shellcheck cannot parse chezmoi template syntax.
  # The repo's lint-templates hook covers them instead, via repo_checks below.
  case "$FILE" in
  *.chezmoitemplates/* | */modify_* | *.tmpl) return 0 ;;
  esac
  case "$FILE" in
  *.md)
    MD_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/markdownlint/claude.yaml"
    if has markdownlint; then
      markdownlint --config "$MD_CONFIG" "$FILE" >&2
    fi
    ;;
  *.sh)
    if has shellcheck; then
      shellcheck --shell=bash --severity=warning "$FILE" >&2
    fi
    ;;
  Dockerfile* | Containerfile*)
    if has hadolint; then
      hadolint "$FILE" >&2
    fi
    ;;
  *.yaml | *.yml)
    if has yamllint; then
      # Run from project root so .yamllint.yml (ignore lists, rules) is discovered
      PROJECT_ROOT=$(git -C "$(dirname "$FILE")" rev-parse --show-toplevel 2>/dev/null)
      if [ -n "$PROJECT_ROOT" ]; then
        REL=${FILE#"$PROJECT_ROOT"/}
        (cd "$PROJECT_ROOT" && yamllint --strict "$REL") >&2
      else
        yamllint --strict "$FILE" >&2
      fi
    fi
    ;;
  esac
}

# Run the file's own repo hooks (prek, else pre-commit) to catch checks the
# baseline misses. --files scopes hooks to this one file; snapshot and revert it
# so a fixer hook cannot make lint mutate the file.
repo_checks() {
  prek=$(command -v prek || command -v pre-commit) || return 0
  root=$(git -C "$(dirname "$FILE")" rev-parse --show-toplevel 2>/dev/null) || return 0
  [ -f "$root/.pre-commit-config.yaml" ] || return 0

  rel=${FILE#"$root"/}
  snapshot=$(mktemp) || return 0
  cp "$FILE" "$snapshot"

  (cd "$root" && "$prek" run --files "$rel") >&2
  rc=$?

  if ! cmp -s "$FILE" "$snapshot"; then
    cp "$snapshot" "$FILE"
  fi
  rm -f "$snapshot"
  return "$rc"
}

lint
lint_rc=$?
repo_checks
repo_rc=$?
exit_code=$lint_rc
[ "$repo_rc" -ne 0 ] && exit_code=$repo_rc
if [ "$exit_code" -ne 0 ]; then
  echo "lint: $(basename "$FILE") failed (exit $exit_code)" >&2
  exit 2
fi
