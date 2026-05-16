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

TMP_FILES=""
# shellcheck disable=SC2329
cleanup() {
  # shellcheck disable=SC2086
  rm -f $TMP_FILES
}
trap cleanup EXIT

[ ! -f "$AI_YAML" ] && tap_not_ok "ai.yaml not found" && exit 1
[ ! -f "$AUTH_FILE" ] && tap_not_ok "auth file not found" && exit 1
! command -v jq >/dev/null 2>&1 && tap_not_ok "jq not installed" && exit 1
! command -v yq >/dev/null 2>&1 && tap_not_ok "yq not installed" && exit 1

# GNU date for %3N (millisecond truncation); BSD date lacks this
if command -v gdate >/dev/null 2>&1; then
  DATE="gdate"
else
  DATE="date"
fi

provider_count=$(yq '.ai.providers | to_entries | .[] | select(.value.base_url != null) | .key' "$AI_YAML" 2>/dev/null | wc -l)
tap_plan "$provider_count"

# Reads TSV lines: label<TAB>pct<TAB>reset_iso_or_empty
show_quota() {
  while IFS="$(printf '\t')" read -r label pct reset; do
    if [ -n "$reset" ]; then
      reset_fmt=$($DATE -d "$reset" "+%Y-%m-%d %H:%M" 2>/dev/null || echo "unknown")
      tap_diag "$label: ${pct}% used, reset time: $reset_fmt"
    else
      tap_diag "$label: ${pct}% used"
    fi
  done
}

check_endpoint() {
  url="$1"
  name="$2"
  env_var="$3"

  key=""
  if [ -n "$env_var" ]; then
    key="$(printenv "$env_var")" || key=""
  fi
  if [ -z "$key" ]; then
    key="$(jq -r --arg name "$name" '.[$name].key // empty' "$AUTH_FILE" 2>/dev/null)"
  fi
  if [ -z "$key" ]; then
    key="$("$HOME/.claude/api-key-helper.sh" "$name" 2>/dev/null)" || key=""
  fi

  if [ -z "$key" ]; then
    tap_ok "$name" "SKIP No auth key"
    return
  fi

  tmp=$(mktemp)
  headers="${tmp}.headers"
  body="${tmp}.body"
  TMP_FILES="$TMP_FILES $tmp $headers $body"

  start=$($DATE +%s%3N)
  if [ "$name" = "anthropic" ]; then
    curl -sS -D "$headers" -o "$body" \
      --header "Authorization: Bearer $key" \
      --header 'anthropic-version: 2023-06-01' \
      "$url" 2>&1 || true
  else
    curl -sS -D "$headers" -o "$body" \
      --header "Authorization: Bearer $key" \
      "$url" 2>&1 || true
  fi
  status=$(head -n 1 "$headers" | awk '{print $2}')
  end=$($DATE +%s%3N)
  duration=$((end - start))

  model_count=""
  model_field=""
  if [ -s "$body" ] && jq empty "$body" 2>/dev/null; then
    for field in "data" "models" "results" "items"; do
      count=$(jq -r ".${field} | length // 0" "$body" 2>/dev/null || echo "")
      if [ "$count" != "0" ]; then
        model_count="$count"
        model_field="$field"
        break
      fi
    done
  fi

  if [ "$status" != "200" ]; then
    tap_not_ok "$name"
    if [ "$status" = "401" ]; then
      tap_diag "Authentication failed"
    else
      tap_diag "HTTP error"
    fi
    if [ -s "$body" ] && jq empty "$body" 2>/dev/null; then
      error_msg=$(jq -r '.error // .message // .detail // empty' "$body" 2>/dev/null)
      [ -n "$error_msg" ] && tap_diag "API error: $error_msg"
    fi
    tap_diag_kv "status: $status" "duration: ${duration}ms" "url: $url"
    return
  fi

  if [ "$name" = "synthetic" ] && [ -z "$model_count" ]; then
    tap_not_ok "$name"
    tap_diag "No models in response"
    tap_diag_kv "tried: data, models, results, items" "status: $status" "duration: ${duration}ms" "url: $url"
    return
  fi

  tap_ok "$name"

  set -- "status: $status" "duration: ${duration}ms"
  [ -n "$model_count" ] && set -- "$@" "models: $model_count"
  [ -n "$model_field" ] && set -- "$@" "field: $model_field"
  tap_diag_kv "$@"

  if [ "$name" = "zai" ]; then
    quota=$(curl -sS \
      --header "Authorization: Bearer $key" \
      "https://api.z.ai/api/monitor/usage/quota/limit" 2>/dev/null || true)
    if [ -n "$quota" ] && echo "$quota" | jq --exit-status '.data' >/dev/null 2>&1; then
      echo "$quota" | jq -r '.data.limits[]? | [
        (if .unit == 3 then "5h quota"
         elif .unit == 5 then "monthly"
         elif .unit == 6 then "7d quota"
         else "unit \(.unit)" end),
        (.percentage // 0),
        (if .nextResetTime > 0 then (.nextResetTime / 1000 | floor | strftime("%Y-%m-%dT%H:%M:%SZ")) else "" end)
      ] | @tsv' 2>/dev/null | show_quota
      level=$(echo "$quota" | jq -r '.data.level // empty' 2>/dev/null || true)
      [ -n "$level" ] && tap_diag "plan: $level"
    fi
  fi

  if [ "$name" = "anthropic" ]; then
    cache="${XDG_CACHE_HOME:-$HOME/.cache}/opencode/anthropic-quota.json"
    quota=""
    stale=""
    if [ -f "$cache" ]; then
      age=$(($(date +%s) - $(stat -c %Y "$cache" 2>/dev/null || echo 0)))
      if [ "$age" -lt 300 ]; then
        quota=$(cat "$cache")
      else
        stale=$(cat "$cache")
      fi
    fi
    if [ -z "$quota" ]; then
      quota=$(curl -sS \
        --header "Authorization: Bearer $key" \
        --header "anthropic-beta: oauth-2025-04-20" \
        "https://api.anthropic.com/api/oauth/usage" 2>/dev/null || true)
      if echo "$quota" | jq --exit-status '.five_hour' >/dev/null 2>&1; then
        mkdir -p "$(dirname "$cache")"
        printf '%s' "$quota" >"$cache"
      else
        quota="$stale"
      fi
    fi
    if [ -n "$quota" ] && echo "$quota" | jq --exit-status '.five_hour' >/dev/null 2>&1; then
      echo "$quota" | jq -r 'to_entries[] |
        select(.key != "extra_usage" and .value != null and (.value.utilization | type) == "number") |
        [
          (if .key == "five_hour" then "5h quota"
           elif .key == "seven_day" then "7d all models"
           elif .key == "seven_day_sonnet" then "7d sonnet"
           elif .key == "seven_day_opus" then "7d opus"
           elif .key == "seven_day_omelette" then "7d design"
           elif .key == "seven_day_oauth_apps" then "7d oauth apps"
           elif .key == "seven_day_cowork" then "7d cowork"
           elif .key == "omelette_promotional" then "design promo"
           else .key end),
          (.value.utilization | round),
          (.value.resets_at // "")
        ] | @tsv' 2>/dev/null | show_quota
      echo "$quota" | jq -r '
        .extra_usage |
        if . == null then empty
        elif .is_enabled and (.utilization | type) == "number" then
          ["on", (.utilization | round), (.used_credits // "?"), (.monthly_limit // "?"), (.currency // ""), (.resets_at // "")] | @tsv
        else
          ["off", (.disabled_reason // "unknown"), "", "", "", ""] | @tsv
        end' 2>/dev/null | while IFS="$(printf '\t')" read -r state val a b currency reset; do
        if [ "$state" = "off" ]; then
          tap_diag "extra usage: off ($val)"
        elif [ -n "$reset" ]; then
          reset_fmt=$($DATE -d "$reset" "+%Y-%m-%d %H:%M" 2>/dev/null || echo "unknown")
          tap_diag "extra usage: ${val}% used, ${a}/${b} ${currency}, reset time: $reset_fmt"
        else
          tap_diag "extra usage: ${val}% used, ${a}/${b} ${currency}"
        fi
      done
    fi
  fi
}

get_endpoint() {
  case "$1" in
  ollama) echo "/tags" ;;
  *) echo "/models" ;;
  esac
}

yq '.ai.providers | to_entries | .[] | select(.value.base_url != null) | [.value.base_url, .key, .value.api, .value.env] | @tsv' "$AI_YAML" 2>/dev/null | while IFS="$(printf '\t')" read -r base_url name api env; do
  endpoint=$(get_endpoint "$api")
  url="${base_url}${endpoint}"
  check_endpoint "$url" "$name" "$env"
done

exit "$TAP_FAILS"
