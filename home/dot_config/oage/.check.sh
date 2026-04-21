#!/usr/bin/env bash

set -euo pipefail

if ((BASH_VERSINFO[0] < 5)); then
  echo "bash 5+ required, found $BASH_VERSION" >&2
  exit 1
fi

# shellcheck disable=SC1091
. "${XDG_CONFIG_HOME:-$HOME/.config}/sh/lib/tap.sh"

# Oage check

if [[ "$(hostname)" == fr* ]]; then
  tap_plan 0 "oage check"
  exit 0
fi

MAX_TIME="${MAX_TIME:-60}"

data="$(chezmoi data --format=json)"

jqr() { printf '%s' "$data" | jq --raw-output "$@"; }

post() {
  local url="$1" body="$2"
  shift 2
  curl --silent --fail --max-time "$MAX_TIME" "$url" \
    --header 'Content-Type: application/json' \
    --data "$body" "$@"
}

# shellcheck disable=SC2016
metrics_filter='def elapsed: ($t1|tonumber) - ($t0|tonumber);
def round2: (. * 100 | round / 100);
FIELDS + {url: $url, elapsed_s: (elapsed | round2)}
+ if .usage then
    { prompt_tokens: .usage.prompt_tokens,
      completion_tokens: .usage.completion_tokens }
    + if .usage.completion_tokens > 0 and elapsed > 0 then
        {tok_per_s: ((.usage.completion_tokens / elapsed) | round2)}
      else {} end
  else {} end'

check() {
  local label="$1" assert="$2" fields="$3" url="$4" body="$5"
  local response rc=0 t0 t1
  t0=$EPOCHREALTIME
  response="$(post "$url" "$body")" || rc=$?
  t1=$EPOCHREALTIME
  if [[ $rc -ne 0 ]]; then
    tap_not_ok "$label"
    tap_diag_kv "severity: fail" "message: curl exit $rc" "url: $url"
    tap_bail "$url unreachable"
    exit 1
  fi
  if ! printf '%s' "$response" | jq --exit-status "$assert" >/dev/null 2>&1; then
    tap_not_ok "$label"
    tap_diag_kv "severity: fail" "message: assertion failed" "url: $url"
    return 0
  fi
  tap_ok "$label"
  printf '%s' "$response" | jq --raw-output \
    --arg t0 "$t0" --arg t1 "$t1" --arg url "$url" \
    "${metrics_filter//FIELDS/(${fields})}" | tap_diag_json
}

chat() {
  local label="$1" assert="$2" fields="$3" body="$4"
  check "$label" "$assert" "$fields" \
    "$chat_url/v1/chat/completions" \
    "$(printf '%s' "$body" | jq --compact-output --arg m "$chat_model" '. + {model: $m}')"
}

# Setup

local_provider="$(jqr '.ai.localProvider')"

if [[ -z "$local_provider" ]]; then
  tap_plan 0 "local provider disabled"
  exit 0
fi

# shellcheck disable=SC2016
port="$(jqr --arg p "$local_provider" '.ai.providers[$p].port')"
fast="$(jqr '.ai.profiles.local.fast')"
# shellcheck disable=SC2016
chat_model="$(jqr --arg m "$fast" --arg p "$local_provider" '.ai.models[$m][$p]')"
chat_url="http://localhost:$port"

embed_ref="$(jqr '.ai.profiles[.ai.localProfile].embedding')"
embed_provider="${embed_ref%%/*}"
embed_model="${embed_ref#*/}"
# shellcheck disable=SC2016
embed_port="$(jqr --arg p "$embed_provider" '.ai.providers[$p].port')"

# Tests

tap_plan 4

chat "completions" \
  '.choices[0] | has("finish_reason") and .message.role == "assistant"' \
  '{model, finish_reason: .choices[0].finish_reason}' \
  '{"messages": [{"role": "user", "content": "hi"}], "max_tokens": 2}'

chat "reasoning" \
  '.choices[0].message |
    has("reasoning", "content", "role") and
    (.reasoning | length > 0) and
    (.content | test("2"))' \
  '{model, content: .choices[0].message.content[0:50]}' \
  '{"messages": [{"role": "user", "content": "What is 1+1?"}], "max_tokens": 500}'

chat "tool calling" \
  '.choices[0].message |
    has("tool_calls") and
    (.tool_calls | length > 0) and
    .tool_calls[0].function.name == "get_weather" and
    (.tool_calls[0].function.arguments | fromjson | has("city"))' \
  '{model,
    calls: (.choices[0].message.tool_calls | length),
    function: .choices[0].message.tool_calls[0].function.name}' \
  '{
    "messages": [{"role": "user", "content": "Get weather in Paris"}],
    "max_tokens": 100,
    "tools": [{
      "type": "function",
      "function": {
        "name": "get_weather",
        "description": "Get current weather for a city",
        "parameters": {
          "type": "object",
          "properties": {"city": {"type": "string"}},
          "required": ["city"]
        }
      }
    }]
  }'

check "embeddings" \
  '(.data | length > 0) and (.data[0].embedding | length > 0) and .model' \
  '{model, dimensions: (.data[0].embedding | length)}' \
  "http://localhost:$embed_port/v1/embeddings" \
  "{\"model\": \"$embed_model\", \"input\": \"test\"}"

# Restart hung services on failure (KeepAlive restarts them)
# shellcheck disable=SC2154 # failures is set by tap.sh
if [[ "$failures" -gt 0 ]] && command -v launchctl >/dev/null 2>&1; then
  gui="gui/$(id -u)"
  # shellcheck disable=SC2016
  label="$(jqr --arg p "$local_provider" '.ai.providers[$p].label')"
  if [[ -n "$label" ]] && launchctl print "$gui/$label" 2>/dev/null | grep -q 'pid ='; then
    printf '# restarting %s\n' "$label"
    launchctl kill SIGTERM "$gui/$label"
  fi
fi

exit "$failures"
