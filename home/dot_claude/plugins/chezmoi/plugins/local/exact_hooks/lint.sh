#!/bin/sh

FILE=$(jq -r '.tool_input.file_path // empty')
if [ -z "$FILE" ]; then
  exit 0
fi
if ! [ -f "$FILE" ]; then
  echo "lint: file not found: $FILE" >&2
  exit 2
fi

# Repo root for repo-pinned tooling; abs paths let /tmp serve as fallback
root=$(git -C "$(dirname "$FILE")" rev-parse --show-toplevel 2>/dev/null)
if ! cd "${root:-$(dirname "$FILE")}" 2>/dev/null; then
  cd /tmp || exit 1
fi

has() {
  command -v "$1" >/dev/null
}

lint() {
  # Templates: markdownlint and shellcheck cannot parse chezmoi template syntax;
  # the commit-time hooks cover them instead.
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

# prek has no read-only mode, so repo hooks are not run here; the commit-time
# hook run is the gate for them. This pass only reports, never modifies.
if ! lint; then
  echo "lint: $(basename "$FILE") failed" >&2
  exit 2
fi
