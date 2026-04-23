#!/bin/sh
# Claude Code API key helper
# Usage: ~/.claude/api-key-helper.sh <provider>
# Example: ~/.claude/api-key-helper.sh zai-coding-plan
# Reads from: ~/.config/private_secrets.d/cloud/{provider}.conf
# Falls back to: ~/.local/share/opencode/auth.json

SCRIPT_NAME="${0##*/}"

log_info() {
  echo "$SCRIPT_NAME: $*" >&2
}

try_secrets_file() {
  SECRETS_FILE="$1"
  PROVIDER="$2"

  if [ ! -f "$SECRETS_FILE" ]; then
    return 1
  fi

  log_info "trying secrets file: $SECRETS_FILE"

  # shellcheck disable=SC1090
  . "$SECRETS_FILE" 2>/dev/null || true

  # Convert hyphens to underscores for env var name
  KEY_VAR=$(printf '%s_API_KEY' "$PROVIDER" | tr '[:lower:]' '[:upper:]' | tr '-' '_')

  # Use eval for indirect expansion (POSIX-compatible)
  eval "KEY_VALUE=\"\${$KEY_VAR:-}\""

  if [ -n "$KEY_VALUE" ]; then
    log_info "found key: $KEY_VAR"
    printf '%s' "$KEY_VALUE"
    return 0
  else
    log_info "key not found: $KEY_VAR"
    return 1
  fi
}

try_auth_file() {
  AUTH_FILE="$1"
  PROVIDER="$2"

  if [ ! -f "$AUTH_FILE" ]; then
    return 1
  fi

  log_info "trying auth file: $AUTH_FILE"

  if ! command -v yq >/dev/null 2>&1; then
    log_info "yq not found, cannot read auth.json"
    return 1
  fi

  KEY=$(yq -r ".[\"$PROVIDER\"].key" "$AUTH_FILE" 2>/dev/null)
  if [ "$KEY" != "null" ] && [ -n "$KEY" ]; then
    log_info "found key in auth.json"
    printf '%s' "$KEY"
    return 0
  else
    log_info "key not found in auth.json for provider: $PROVIDER"
    return 1
  fi
}

main() {
  if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <provider>" >&2
    exit 1
  fi

  PROVIDER="$1"
  SECRETS_FILE="$HOME/.config/private_secrets.d/cloud/$PROVIDER.conf"
  AUTH_FILE="$HOME/.local/share/opencode/auth.json"

  # Try secrets file first
  if try_secrets_file "$SECRETS_FILE" "$PROVIDER"; then
    return
  fi

  # Fallback to opencode auth.json
  if try_auth_file "$AUTH_FILE" "$PROVIDER"; then
    return
  fi

  log_info "no secrets file or auth.json found for provider: $PROVIDER"
}

main "$@"
