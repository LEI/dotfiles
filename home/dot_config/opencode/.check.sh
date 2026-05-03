#!/bin/sh

set -eu

lib_dir="$HOME/.local/lib"
# shellcheck source=home/dot_local/lib/sh/log.sh
. "$lib_dir/sh/log.sh"
# shellcheck source=home/dot_local/lib/sh/tap.sh
. "$lib_dir/sh/tap.sh"

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
AI_YAML="$XDG_DATA_HOME/chezmoi/home/.chezmoidata/ai.yaml"
AUTH_FILE="$XDG_DATA_HOME/opencode/auth.json"

# Global temp file cleanup
TMP_FILES=""
cleanup() {
  rm -f $TMP_FILES
}
trap cleanup EXIT

# Pre-flight checks
[ ! -f "$AI_YAML" ] && tap_not_ok "ai.yaml not found" && exit 1
[ ! -f "$AUTH_FILE" ] && tap_not_ok "auth file not found" && exit 1
! command -v jq >/dev/null 2>&1 && tap_not_ok "jq not installed" && exit 1
! command -v yq >/dev/null 2>&1 && tap_not_ok "yq not installed" && exit 1

# Count providers
provider_count=$(yq '.ai.providers | to_entries | .[] | select(.value.base_url != null) | .key' "$AI_YAML" 2>/dev/null | wc -l)
tap_plan "$provider_count"

check_endpoint() {
  url="$1"
  name="$2"
  api_type="$3"
  env_var="$4"

  # Look up auth key
  key=""
  [ -n "$env_var" ] && key=$(printenv "$env_var" 2>/dev/null || true)
  [ -z "$key" ] && key=$(jq -r --arg name "$name" '.[$name].key // empty' "$AUTH_FILE" 2>/dev/null)

  if [ -z "$key" ]; then
    tap_ok "$name" "SKIP No auth key"
    return
  fi

  tmpfile=$(mktemp)
  tmpheaders="${tmpfile}.headers"
  tmpbody="${tmpfile}.body"
  TMP_FILES="$TMP_FILES $tmpfile $tmpheaders $tmpbody"

  start=$(date +%s%3N)
  curl -sS -D "$tmpheaders" -o "$tmpbody" --header "Authorization: Bearer $key" "$url" 2>&1 || true
  status=$(head -n 1 "$tmpheaders" | awk '{print $2}')
  end=$(date +%s%3N)
  duration=$((end - start))

  # Count models
  model_count=""
  model_field=""
  if [ -s "$tmpbody" ] && jq empty "$tmpbody" 2>/dev/null; then
    for field in "data" "models" "results" "items"; do
      count=$(jq -r ".${field} | length // 0" "$tmpbody" 2>/dev/null || echo "")
      if [ "$count" != "0" ]; then
        model_count="$count"
        model_field="$field"
        break
      fi
    done
  fi

  # FAIL conditions
  if [ "$status" != "200" ]; then
    tap_not_ok "$name"
    [ "$status" = "401" ] && tap_diag "Authentication failed" || tap_diag "HTTP error"

    if [ -s "$tmpbody" ] && jq empty "$tmpbody" 2>/dev/null; then
      error_msg=$(jq -r '.error // .message // .detail // empty' "$tmpbody" 2>/dev/null)
      [ -n "$error_msg" ] && tap_diag "API error: $error_msg"
    fi

    tap_diag_kv "status: $status" "duration: ${duration}ms" "url: $url"
    return
  fi

  # Model count check
  if [ "$name" = "synthetic" ] && [ -z "$model_count" ]; then
    tap_not_ok "$name"
    tap_diag "No models in response"
    tap_diag_kv "tried: data, models, results, items" "status: $status" "duration: ${duration}ms" "url: $url"
    return
  fi

  # PASS with diagnostics
  tap_ok "$name"

  # First YAML block - models response (only show response for errors)
  set -- "status: $status" "duration: ${duration}ms"
  [ -n "$model_count" ] && set -- "$@" "models: $model_count"
  [ -n "$model_field" ] && set -- "$@" "field: $model_field"

  # Only show response preview for non-200 or missing models
  if [ "$status" != "200" ] || [ -z "$model_count" ]; then
    if [ -s "$tmpbody" ] && jq empty "$tmpbody" 2>/dev/null; then
      body_preview=$(jq -c '.' "$tmpbody" 2>/dev/null | head -c 500)
      set -- "$@" "response: $body_preview"
    fi
  fi

  tap_diag_kv "$@"

  if [ "$name" = "zai" ]; then
    quota=$(curl -sS -H "Authorization: Bearer $key" "https://api.z.ai/api/monitor/usage/quota/limit" 2>/dev/null || true)
    if [ -n "$quota" ] && echo "$quota" | jq empty 2>/dev/null; then
      echo "$quota" | jq -r '.data.limits[]? | [.unit, (.percentage // 0), (.nextResetTime // 0)] | @tsv' 2>/dev/null | while IFS=$'\t' read -r unit pct reset; do
        case "$unit" in
        3) label="5 hours quota" ;;
        5) label="monthly web" ;;
        6) label="weekly quota" ;;
        *) label="unit $unit" ;;
        esac
        if [ "$reset" -gt 0 ] 2>/dev/null; then
          reset_fmt=$(date -d "@$((reset / 1000))" "+%Y-%m-%d %H:%M" 2>/dev/null || echo "unknown")
          tap_diag "$label: ${pct}% used, reset time: ${reset_fmt}"
        else
          tap_diag "$label: ${pct}% used"
        fi
      done

      level=$(echo "$quota" | jq -r '.data.level // empty' 2>/dev/null || true)
      [ -n "$level" ] && tap_diag "plan: $level"
    fi
  fi
}

# Map api type to endpoint
get_endpoint() {
  case "$1" in
  ollama) echo "/tags" ;;
  *) echo "/models" ;;
  esac
}

# Main loop
yq '.ai.providers | to_entries | .[] | select(.value.base_url != null) | [.value.base_url, .key, .value.api, .value.env] | @tsv' "$AI_YAML" 2>/dev/null | while IFS="$(printf '\t')" read -r base_url name api env; do
  endpoint=$(get_endpoint "$api")
  url="${base_url}${endpoint}"
  check_endpoint "$url" "$name" "$api" "$env"
done

exit "$TAP_FAILS"
