#!/bin/sh
# Usage: api-key-helper.sh <provider>
# Reads from: ~/.config/private_secrets.d/cloud/{provider}.conf
# Falls back to: ~/.local/share/opencode/auth.json

if [ "$#" -ne 1 ]; then
  echo >&2 "Usage: ${0##*/} <provider>"
  exit 1
fi

PROVIDER="$1"
SECRETS_FILE="$HOME/.config/private_secrets.d/cloud/$PROVIDER.conf"
AUTH_FILE="$HOME/.local/share/opencode/auth.json"

case "$PROVIDER" in
zai) PLAN=zai-coding-plan ;;
esac

if [ -f "$SECRETS_FILE" ]; then
  # shellcheck source=/dev/null
  . "$SECRETS_FILE" 2>/dev/null || true
  KEY_VAR=$(printf '%s_API_KEY' "$PROVIDER" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
  eval "KEY_VALUE=\"\${$KEY_VAR:-}\""
  if [ -n "$KEY_VALUE" ]; then
    printf '%s' "$KEY_VALUE"
    exit 0
  fi
fi

if [ -f "$AUTH_FILE" ] && command -v yq >/dev/null 2>&1; then
  KEY=$(yq -r ".[\"${PLAN:-PROVIDER}\"].key" "$AUTH_FILE" 2>/dev/null)
  if [ "$KEY" != "null" ] && [ -n "$KEY" ]; then
    printf '%s' "$KEY"
    exit 0
  fi
fi

# Claude Code OAuth token fallback
if [ "$PROVIDER" = "anthropic" ]; then
  if command -v security >/dev/null 2>&1; then
    KEY=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null |
      jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
    if [ -n "$KEY" ] && [ "$KEY" != "null" ]; then
      printf '%s' "$KEY"
      exit 0
    fi
  fi
  creds="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.credentials.json"
  if [ -f "$creds" ] && command -v jq >/dev/null 2>&1; then
    KEY=$(jq -r '.claudeAiOauth.accessToken // empty' "$creds" 2>/dev/null)
    if [ -n "$KEY" ] && [ "$KEY" != "null" ]; then
      printf '%s' "$KEY"
      exit 0
    fi
  fi
fi

echo >&2 "${0##*/}: no key found for provider '$PROVIDER'"
exit 1
