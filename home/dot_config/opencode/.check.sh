#!/usr/bin/env bash

set -eu

DEBUG=""
for arg in "$@"; do
  case "$arg" in
  --debug) DEBUG=1 ;;
  --format=* | --bars | --no-bars) ;; # consumed by output_init
  *)
    echo "Unknown: $arg" >&2
    exit 2
    ;;
  esac
done

if [ -n "${CHEZMOI_WORKING_TREE:-}" ]; then
  lib_dir="$CHEZMOI_WORKING_TREE/home/dot_local/lib"
else
  lib_dir="$HOME/.local/lib"
fi
# shellcheck source=home/dot_local/lib/sh/cache.sh
. "$lib_dir/sh/cache.sh"
# shellcheck source=home/dot_local/lib/sh/duration.sh
. "$lib_dir/sh/duration.sh"
# shellcheck source=home/dot_local/lib/sh/log.sh
. "$lib_dir/sh/log.sh"
# shellcheck source=home/dot_local/lib/sh/tap.sh
. "$lib_dir/sh/tap.sh"
# shellcheck source=home/dot_local/lib/sh/anthropic.sh
. "$lib_dir/sh/anthropic.sh"
# shellcheck source=home/dot_local/lib/bash/output.sh
. "$lib_dir/bash/output.sh"
output_init "$@"

output_diag_json_file() {
  local path="$1"
  case "$OUTPUT_FORMAT" in
  json) jq --compact-output '{type:"diag",data:.}' "$path" 2>/dev/null ;;
  *) while IFS= read -r line; do output_diag "$line"; done < <(jq '.' "$path" 2>/dev/null) ;;
  esac
}

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
AI_YAML="$XDG_DATA_HOME/chezmoi/home/dot_config/ai/.chezmoidata.yaml"
AUTH_FILE="$XDG_DATA_HOME/opencode/auth.json"

TMP_FILES=""
# shellcheck disable=SC2329
cleanup() {
  # shellcheck disable=SC2086
  rm -f $TMP_FILES
}
trap cleanup EXIT

if [ ! -f "$AI_YAML" ]; then
  output_not_ok "ai data not found"
  exit 1
fi
if [ ! -f "$AUTH_FILE" ]; then
  output_not_ok "auth file not found"
  exit 1
fi
if ! command -v jq >/dev/null 2>&1; then
  output_not_ok "jq not installed"
  exit 1
fi
if ! command -v yq >/dev/null 2>&1; then
  output_not_ok "yq not installed"
  exit 1
fi

# GNU date supports %3N for millisecond precision, BSD date does not
if command -v gdate >/dev/null 2>&1; then
  DATE="gdate"
else
  DATE="date"
fi

provider_count=$(yq '.ai.providers | to_entries | .[] | select(.value.base_url != null) | .key' "$AI_YAML" 2>/dev/null | wc -l)
output_plan "$provider_count"

show_quota() {
  while IFS="$(printf '\t')" read -r label pct reset; do
    line="$label: ${pct}% used"
    if [ -n "$reset" ]; then
      note=$(format_date_relative "$reset")
      if [ -n "$note" ]; then
        case "$note" in *" (0s)") ;; *) line="$line, resets $note" ;; esac
      fi
    fi
    if [ "$OUTPUT_BARS" = "1" ]; then
      line="$(output_bar "$pct") $line"
    fi
    if [ "$pct" -ge 100 ]; then
      QUOTA_WARN=1
    fi
    output_diag "$line"
  done
}

# cached_fetch <name> <ttl> <jq_test> <curl_args...>
# Writes the response body to stdout and reports the outcome in caller scope:
#   fetch_source  cache | live | stale | none
#   fetch_age     human cache age for cache and stale, empty otherwise
#   fetch_reason  failure reason for stale and none (eg "HTTP 429"), empty on success
# A fresh cache hit skips the network. On any failure the most recent cache is
# still served, labelled stale, so a real reading is never dropped for a bare
# "unavailable". Use: cached_fetch ... > file; var=$(cat file)
cached_fetch() {
  provider_name="$1" ttl="$2" jq_test="$3"
  shift 3
  cache_path="${XDG_CACHE_HOME:-$HOME/.cache}/opencode/${provider_name}-quota.json"
  fetch_source="" fetch_age="" fetch_reason=""

  if data=$(cache_get "$cache_path" "$ttl"); then
    fetch_source="cache"
    fetch_age=$(cache_age_human "$cache_path")
    printf '%s' "$data"
    return
  fi

  if cache_backoff_active "$cache_path" "$((ttl * 3))"; then
    fetch_reason="backing off after recent failure"
    if [ -f "$cache_path" ]; then
      fetch_source="stale"
      fetch_age=$(cache_age_human "$cache_path")
      cat "$cache_path"
    else
      fetch_source="none"
    fi
    return
  fi

  tmp=$(mktemp)
  curl_err=$(mktemp)
  rc=0
  http_code=$(curl --silent --show-error --max-time 10 --write-out '%{http_code}' \
    --output "$tmp" "$@" 2>"$curl_err") || rc=$?

  if [ "$rc" -ne 0 ]; then
    fetch_reason="curl exit $rc: $(tr '\n' ' ' <"$curl_err")"
  elif [ -n "$http_code" ] && [ "${http_code#2}" = "$http_code" ]; then
    fetch_reason="HTTP $http_code"
    err_msg=$(jq -r '.error.message // .error // .message // .detail // empty' "$tmp" 2>/dev/null | head -c 100) || err_msg=""
    if [ -n "$err_msg" ]; then
      fetch_reason="HTTP $http_code: $err_msg"
    fi
  elif ! jq --exit-status "$jq_test" "$tmp" >/dev/null 2>&1; then
    fetch_reason="unexpected response"
  fi
  rm -f "$curl_err"

  if [ -z "$fetch_reason" ]; then
    mkdir -p "$(dirname "$cache_path")"
    mv "$tmp" "$cache_path"
    fetch_source="live"
    cache_clear_failed "$cache_path"
    cat "$cache_path"
    return
  fi

  cache_mark_failed "$cache_path"
  warn "$provider_name quota fetch failed: $fetch_reason"
  rm -f "$tmp"
  if [ -f "$cache_path" ]; then
    fetch_source="stale"
    fetch_age=$(cache_age_human "$cache_path")
    cat "$cache_path"
  else
    fetch_source="none"
  fi
}

# quota_note: a parenthetical freshness or failure note for the last cached_fetch
# Reads fetch_source/fetch_age/fetch_reason from caller scope, empty when live
quota_note() {
  case "$fetch_source" in
  cache)
    if [ -n "$fetch_age" ]; then
      printf '(cached %s)' "$fetch_age"
    fi
    ;;
  stale) printf '(cached %s, live failed: %s)' "${fetch_age:-unknown age}" "${fetch_reason:-unknown}" ;;
  esac
}

# Per-provider quota handlers called from inside the { } >"$quota_diag" group
# in check_endpoint. Bash dynamic scope lets them read name, key, quota_file,
# fetch_source, fetch_age, fetch_reason, QUOTA_WARN, and OUTPUT_BARS from the caller

quota_anthropic() {
  local quota note
  cached_fetch anthropic 300 '.five_hour' \
    --header "Authorization: Bearer $key" \
    --header "anthropic-beta: oauth-2025-04-20" \
    "https://api.anthropic.com/api/oauth/usage" >"$quota_file"
  quota=$(cat "$quota_file")
  if [ -z "$quota" ] || ! echo "$quota" | jq --exit-status '.five_hour' >/dev/null 2>&1; then
    output_diag "quota: unavailable${fetch_reason:+ ($fetch_reason)}"
    return
  fi
  show_quota < <(echo "$quota" | jq -r 'to_entries[] |
  select(.key != "extra_usage" and .value != null and (.value.utilization | type) == "number") |
  [.key, (.value.utilization | round), (.value.resets_at // "")] | @tsv' 2>/dev/null |
    while IFS="$(printf '\t')" read -r entry_key pct reset; do
      printf '%s\t%s\t%s\n' "$(anthropic_quota_label "$entry_key")" "$pct" "$reset"
    done)
  show_quota < <(echo "$quota" | jq -r '.limits[]? | select(.scope.model != null) |
  [.group, .scope.model.display_name, (.percent // 0 | round), (.resets_at // "")] | @tsv' 2>/dev/null |
    while IFS="$(printf '\t')" read -r scope_group scope_name pct reset; do
      printf '%s %s\t%s\t%s\n' "$(anthropic_scope_prefix "$scope_group")" "$scope_name" "$pct" "$reset"
    done)
  echo "$quota" | jq -r '
  .extra_usage |
  if . == null then empty
  elif .is_enabled and (.utilization | type) == "number" then
    ["on", (.utilization | round), ((.used_credits // 0) / 100), ((.monthly_limit // 0) / 100), (.currency // ""), (.resets_at // "")] | @tsv
  else
    ["off", (.disabled_reason // "unknown"), "", "", "", ""] | @tsv
  end' 2>/dev/null | while IFS="$(printf '\t')" read -r state val a b currency reset; do
    if [ "$state" = "off" ]; then
      output_diag "extra usage: off ($val)"
    else
      line="extra usage: ${val}% used, ${a}/${b} ${currency}"
      if [ -n "$reset" ]; then
        line="$line, resets $(format_date_relative "$reset")"
      fi
      if [ "$OUTPUT_BARS" = "1" ]; then
        line="$(output_bar "$val") $line"
      fi
      output_diag "$line"
    fi
  done
  note=$(quota_note)
  if [ -n "$note" ]; then
    output_diag "$note"
  fi
}

quota_synthetic() {
  local quota limit requests reset pct note
  cached_fetch synthetic 60 true \
    --header "Authorization: Bearer $key" \
    "https://api.synthetic.new/v2/quotas" >"$quota_file"
  quota=$(cat "$quota_file")
  if [ -z "$quota" ] || ! echo "$quota" | jq empty >/dev/null 2>&1; then
    if [ -n "$fetch_reason" ]; then
      output_diag "quota: unavailable ($fetch_reason)"
    fi
    return
  fi
  limit=$(echo "$quota" | jq -r '.subscription.limit // 0' 2>/dev/null || echo 0)
  requests=$(echo "$quota" | jq -r '.subscription.requests // 0' 2>/dev/null || echo 0)
  reset=$(echo "$quota" | jq -r '.subscription.renewsAt // ""' 2>/dev/null || true)
  if [ "$limit" -gt 0 ]; then
    pct=$((requests * 100 / limit))
    show_quota < <(printf '%s\t%s\t%s\n' "subscription" "$pct" "$reset")
  elif [ "$quota" != "{}" ]; then
    output_diag "subscription: unlimited"
  fi
  note=$(quota_note)
  if [ -n "$note" ]; then
    output_diag "$note"
  fi
}

quota_kimi() {
  local quota balance note
  cached_fetch kimi 300 '.data' \
    --header "Authorization: Bearer $key" \
    "https://api.moonshot.ai/v1/users/me/balance" >"$quota_file"
  quota=$(cat "$quota_file")
  if [ -z "$quota" ] || ! echo "$quota" | jq --exit-status '.data' >/dev/null 2>&1; then
    if [ -n "$fetch_reason" ]; then
      output_diag "quota: unavailable ($fetch_reason)"
    fi
    return
  fi
  balance=$(echo "$quota" | jq -r '.data.available_balance // empty' 2>/dev/null)
  if [ -n "$balance" ]; then
    output_diag "$(printf 'balance: $%.2f' "$balance")"
  fi
  note=$(quota_note)
  if [ -n "$note" ]; then
    output_diag "$note"
  fi
}

quota_openrouter() {
  local quota data limit remaining pct note
  quota=$(cat "$quota_file")
  if [ -z "$quota" ] || ! echo "$quota" | jq empty >/dev/null 2>&1; then
    if [ -n "$fetch_reason" ]; then
      output_diag "quota: unavailable ($fetch_reason)"
    fi
    return
  fi
  data=$(echo "$quota" | jq -r '.data // empty' 2>/dev/null || true)
  if [ -n "$data" ]; then
    limit=$(echo "$quota" | jq -r '.data.limit // "null"' 2>/dev/null || true)
    remaining=$(echo "$quota" | jq -r '.data.limit_remaining // "null"' 2>/dev/null || true)
    if [ "$limit" != "null" ] && [ "$remaining" != "null" ]; then
      pct=$(echo "$quota" | jq -r '(((.data.limit // 0) - (.data.limit_remaining // 0)) / (.data.limit // 1) * 100 | floor)' 2>/dev/null || echo 0)
      show_quota < <(printf '%s\t%s\t%s\n' "credits" "$pct" "")
    fi
    echo "$quota" | jq -r '
    .data |
    if .label then "label: \(.label)" else empty end,
    "usage: total=\(.usage // 0) daily=\(.usage_daily // 0) weekly=\(.usage_weekly // 0) monthly=\(.usage_monthly // 0)",
    "byok: total=\(.byok_usage // 0) daily=\(.byok_usage_daily // 0) weekly=\(.byok_usage_weekly // 0) monthly=\(.byok_usage_monthly // 0)"
  ' 2>/dev/null | while IFS= read -r line; do
      output_diag "$line"
    done
  fi
  note=$(quota_note)
  if [ -n "$note" ]; then
    output_diag "$note"
  fi
}

# openai: quota check via codex auth, no models endpoint
quota_openai() {
  local auth_file token quota plan pct reset openai_diag note QUOTA_WARN
  auth_file="$HOME/.codex/auth.json"
  if [ ! -f "$auth_file" ]; then
    output_ok "openai" "SKIP no auth file"
    return
  fi
  token=$(jq -r '.tokens.access_token // empty' "$auth_file" 2>/dev/null || true)
  if [ -z "$token" ]; then
    output_ok "openai" "SKIP no access token"
    return
  fi
  cached_fetch openai 60 true \
    --header "Authorization: Bearer $token" \
    "https://chatgpt.com/backend-api/wham/usage" >"$quota_file"
  quota=$(cat "$quota_file")
  if [ -z "$quota" ]; then
    output_not_ok "openai" "$fetch_reason"
    return
  fi
  plan=$(echo "$quota" | jq -r '.plan_type // empty' 2>/dev/null)
  pct=$(echo "$quota" | jq -r '.rate_limit.primary_window.used_percent // empty' 2>/dev/null)
  reset=$(echo "$quota" | jq -r '.rate_limit.primary_window.reset_at // empty' 2>/dev/null)
  QUOTA_WARN=""
  openai_diag=$(mktemp)
  TMP_FILES="$TMP_FILES $openai_diag"
  {
    if [ -n "$pct" ]; then
      if [ -n "$reset" ]; then
        show_quota < <(printf '%s\t%s\t%s\n' "quota" "$pct" "@$reset")
      else
        show_quota < <(printf '%s\t%s\t%s\n' "quota" "$pct" "")
      fi
      note=$(quota_note)
      if [ -n "$note" ]; then
        output_diag "$note"
      fi
    fi
  } >"$openai_diag"
  if [ -n "$QUOTA_WARN" ]; then
    output_not_ok "openai" "${plan:+plan: $plan}"
  else
    output_ok "openai" "${plan:+plan: $plan}"
  fi
  cat "$openai_diag"
  if [ -n "$DEBUG" ] && [ -f "${XDG_CACHE_HOME:-$HOME/.cache}/opencode/openai-quota.json" ]; then
    output_diag_json_file "${XDG_CACHE_HOME:-$HOME/.cache}/opencode/openai-quota.json"
  fi
}

# Resolve an API key into the caller-scope `key` from env, secrets.d, the
# opencode auth file, then the claude helper, in that order
resolve_key() {
  key=""
  if [ -n "$env_var" ]; then
    key="$(printenv "$env_var")" || key=""
  fi
  if [ -z "$key" ] && [ -f "$HOME/.config/secrets.d/${name}.conf" ]; then
    # shellcheck source=/dev/null
    . "$HOME/.config/secrets.d/${name}.conf"
    # shellcheck disable=SC2163
    if [ -n "$env_var" ]; then
      export "$env_var"
    fi
    key="$(printenv "$env_var")" || key=""
  fi
  if [ -z "$key" ]; then
    key="$(jq -r --arg name "$name" '.[$name].key // empty' "$AUTH_FILE" 2>/dev/null)"
  fi
  if [ -z "$key" ]; then
    key="$("$HOME/.claude/api-key-helper.sh" "$name" 2>/dev/null)" || key=""
  fi
}

# Fetch the models endpoint into caller-scope `body`, setting `status`,
# `duration`, `from_models_cache`, and `models_cache`. Serves a fresh cache hit
# without a network call
fetch_models() {
  tmp=$(mktemp)
  headers="${tmp}.headers"
  body="${tmp}.body"
  TMP_FILES="$TMP_FILES $tmp $headers $body"

  models_cache="${XDG_CACHE_HOME:-$HOME/.cache}/opencode/models/${name}.json"
  models_cache_ttl=3600
  from_models_cache=0

  cached_body=$(cache_get "$models_cache" "$models_cache_ttl") || true
  if [ -n "$cached_body" ]; then
    printf '%s' "$cached_body" >"$body"
    from_models_cache=1
    status=200
    duration=0
  else
    start=$($DATE +%s%3N)
    curl_err=$(mktemp)
    rc=0
    if [ "$name" = "anthropic" ]; then
      curl --silent --show-error --max-time 10 --dump-header "$headers" --output "$body" \
        --header "Authorization: Bearer $key" \
        --header 'anthropic-version: 2023-06-01' \
        "$url" 2>"$curl_err" || rc=$?
    else
      curl --silent --show-error --max-time 10 --dump-header "$headers" --output "$body" \
        --header "Authorization: Bearer $key" \
        "$url" 2>"$curl_err" || rc=$?
    fi
    if [ "$rc" -ne 0 ]; then
      warn "$name models fetch failed (curl exit $rc): $(tr '\n' ' ' <"$curl_err")"
    fi
    rm -f "$curl_err"
    status=$(head -n 1 "$headers" | awk '{print $2}')
    end=$($DATE +%s%3N)
    duration=$((end - start))
  fi
}

check_endpoint() {
  url="$1"
  name="$2"
  env_var="$3"
  quota_file=$(mktemp)
  TMP_FILES="$TMP_FILES $quota_file"

  if [ "$name" = "openai" ]; then
    quota_openai
    return
  fi

  resolve_key
  if [ -z "$key" ]; then
    output_ok "$name" "SKIP No auth key"
    return
  fi

  fetch_models

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
    output_not_ok "$name"
    desc=""
    if [ "$status" = "401" ]; then
      desc="Authentication failed"
    else
      desc="HTTP error"
    fi
    if [ -s "$body" ] && jq empty "$body" 2>/dev/null; then
      error_msg=$(jq -r '.error // .message // .detail // empty' "$body" 2>/dev/null)
      if [ -n "$error_msg" ]; then
        desc="$desc: $error_msg"
      fi
    fi
    output_diag_kv "models" "status=$status" "duration=${duration}ms" "error=$desc" "url=$url"
    return
  fi

  if [ "$name" = "synthetic" ] && [ -z "$model_count" ]; then
    output_not_ok "$name"
    output_diag_kv "models" "status=$status" "duration=${duration}ms" "error=no models found" "url=$url"
    return
  fi

  if [ "$from_models_cache" = "0" ] && [ -s "$body" ] && jq empty "$body" 2>/dev/null; then
    cache_set "$models_cache" <"$body"
  fi

  # Models diagnostic, omit status and duration when served from cache
  if [ "$from_models_cache" = "1" ]; then
    set --
  else
    set -- "status=$status" "duration=${duration}ms"
  fi
  if [ -n "$model_count" ]; then
    set -- "$@" "models=$model_count"
  fi
  if [ -n "$model_field" ]; then
    set -- "$@" "source=$model_field"
  fi
  if [ "$from_models_cache" = "1" ]; then
    cache_note=$(cache_age_human "$models_cache")
    if [ -n "$cache_note" ]; then
      set -- "$@" "(cached $cache_note)"
    fi
  fi
  # Pre-fetch the coding-plan quota so the tier can be on the provider line.
  # The monitor/usage endpoint reports the coding-plan subscription, so it
  # belongs on zai-coding-plan, not the standard paas/v4 zai provider
  zai_plan=""
  zai_quota=""
  if [ "$name" = "zai-coding-plan" ] && [ -n "$key" ]; then
    cached_fetch zai-coding-plan 60 '.data' \
      --header "Authorization: Bearer $key" \
      "https://api.z.ai/api/monitor/usage/quota/limit" >"$quota_file"
    zai_quota=$(cat "$quota_file")
    if [ -n "$zai_quota" ] && echo "$zai_quota" | jq --exit-status '.data' >/dev/null 2>&1; then
      zai_plan=$(echo "$zai_quota" | jq -r '.data.level // empty' 2>/dev/null || true)
    fi
  fi

  # Pre-fetch openrouter plan for provider directive
  or_plan=""
  if [ "$name" = "openrouter" ] && [ -n "$key" ]; then
    cached_fetch openrouter 300 '.data' \
      --header "Authorization: Bearer $key" \
      "https://openrouter.ai/api/v1/key" >"$quota_file"
    if [ -s "$quota_file" ]; then
      is_free=$(jq -r '.data.is_free_tier // ""' "$quota_file" 2>/dev/null)
      if [ "$is_free" = "true" ]; then
        or_plan="free"
      fi
    fi
  fi

  # Combine directives, only one provider matches per call
  directive="${zai_plan:+plan: $zai_plan}"
  if [ -z "$directive" ]; then
    directive="${or_plan:+plan: $or_plan}"
  fi
  QUOTA_WARN=""
  quota_diag=$(mktemp)
  TMP_FILES="$TMP_FILES $quota_diag"
  {

    if [ "$name" = "zai-coding-plan" ] && [ -n "$zai_quota" ]; then
      show_quota < <(echo "$zai_quota" | jq -r '.data.limits[]? | [
      (if .unit == 3 then "5h quota"
       elif .unit == 5 then "monthly"
       elif .unit == 6 then "7d quota"
       else "unit \(.unit)" end),
      (.percentage // 0),
      (if .nextResetTime > 0 then (.nextResetTime / 1000 | floor | strftime("%Y-%m-%dT%H:%M:%SZ")) else "" end)
    ] | @tsv' 2>/dev/null)
      note=$(quota_note)
      if [ -n "$note" ]; then
        output_diag "$note"
      fi
    fi

    case "$name" in
    anthropic) quota_anthropic ;;
    kimi) quota_kimi ;;
    synthetic) quota_synthetic ;;
    openrouter) quota_openrouter ;;
    esac

  } >"$quota_diag"

  if [ -n "$QUOTA_WARN" ]; then
    output_not_ok "$name" "$directive"
  else
    output_ok "$name" "$directive"
  fi
  output_diag_kv "models" "$@"
  cat "$quota_diag"
  if [ -n "$DEBUG" ] && [ -f "${XDG_CACHE_HOME:-$HOME/.cache}/opencode/${name}-quota.json" ]; then
    output_diag_json_file "${XDG_CACHE_HOME:-$HOME/.cache}/opencode/${name}-quota.json"
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
