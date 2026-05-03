#!/bin/sh

# Health check script for AI provider endpoints
# Reads auth from opencode auth.json and providers from ai.yaml

set -eu

lib_dir="$HOME/.local/lib"
# shellcheck source=home/dot_local/lib/sh/log.sh
. "$lib_dir/sh/log.sh"

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
AI_YAML="$XDG_DATA_HOME/chezmoi/home/.chezmoidata/ai.yaml"
AUTH_FILE="$XDG_DATA_HOME/opencode/auth.json"

FAILED=0

if [ ! -f "$AI_YAML" ]; then
  log "missing file: $AI_YAML"
  exit 1
fi
if ! command -v jq >/dev/null; then
  log "missing jq"
  exit 1
fi
if ! command -v yq >/dev/null; then
  log "missing yq"
  exit 1
fi

# Check if auth file exists
if [ ! -f "$AUTH_FILE" ]; then
  log "auth file not found: $AUTH_FILE"
  exit 1
fi

# Function to check a single endpoint
check_endpoint() {
  url="$1"
  name="$2"
  auth_name="${3:-$2}"

  auth_header=""
  key=$(jq -r --arg name "$auth_name" '.[$name].key // empty' "$AUTH_FILE" 2>/dev/null)
  if [ -n "$key" ]; then
    auth_header="--header Authorization: Bearer $key"
  fi

  # shellcheck disable=2086
  status=$(curl -s -o /dev/null -w "%{http_code}" $auth_header "$url" 2>/dev/null)

  if [ "$status" = "200" ] || [ "$status" = "401" ]; then
    echo "OK $name: $url ($status)"
  else
    echo "FAIL $name: $url ($status)"
    FAILED=$((FAILED + 1))
  fi
}

# Use yq to parse yaml and extract providers with base_url
providers=$(yq '.ai.providers | to_entries | .[] | select(.value.base_url != null) | [.value.base_url, .key, (.value.endpoint // "/models")] | @tsv' "$AI_YAML" 2>/dev/null)
if [ -z "$providers" ]; then
  log "missing providers"
  exit 1
fi

echo "$providers" | while IFS="$(printf '\t')" read -r base_url name endpoint; do
  # Construct URL
  url="${base_url}${endpoint}"
  check_endpoint "$url" "$name"
done

# echo ""
if [ "$FAILED" -eq 0 ]; then
  echo "All endpoints are reachable"
else
  echo "$FAILED endpoint(s) failed"
  exit 1
fi
