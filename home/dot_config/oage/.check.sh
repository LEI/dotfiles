#!/usr/bin/env bash

set -euo pipefail

data="$(chezmoi data --format=json)"
test_num=0
failures=0

jqr() { printf '%s' "$data" | jq --raw-output "$@"; }

post() {
  curl --silent --fail --max-time 10 "$1" \
    --header 'Content-Type: application/json' \
    --data "$2"
}

# Emit TAP 14 YAML diagnostic block (2-space indented, --- to ...)
diagnostic() {
  printf '  ---\n'
  printf '  %s\n' "$@"
  printf '  ...\n'
}

check() {
  local label="$1" assert="$2" diag_expr="$3" url="$4" body="$5"
  local response rc=0
  test_num=$((test_num + 1))
  SECONDS=0
  response="$(post "$url" "$body")" || rc=$?
  if [[ $rc -ne 0 ]]; then
    printf 'not ok %d - %s # time=%dms\n' "$test_num" "$label" "$((SECONDS * 1000))"
    diagnostic \
      "severity: fail" \
      "message: curl exit $rc" \
      "url: $url"
    printf 'Bail out! %s unreachable\n' "$url"
    exit 1
  fi
  if ! printf '%s' "$response" | jq --exit-status "$assert" >/dev/null 2>&1; then
    printf 'not ok %d - %s # time=%dms\n' "$test_num" "$label" "$((SECONDS * 1000))"
    printf '  ---\n'
    printf '  severity: fail\n'
    printf '  message: assertion failed\n'
    printf '%s' "$response" | jq --raw-output 'to_entries[] | "  \(.key): \(.value | tostring | .[0:80])"'
    printf '  ...\n'
    failures=$((failures + 1))
    return 0
  fi
  printf 'ok %d - %s # time=%dms\n' "$test_num" "$label" "$((SECONDS * 1000))"
  printf '  ---\n'
  printf '%s' "$response" | jq --raw-output "$diag_expr"
  printf '  ...\n'
}

chat() {
  local label="$1" assert="$2" diag_expr="$3" body="$4"
  check "$label" "$assert" "$diag_expr" \
    "$chat_url/v1/chat/completions" \
    "$(printf '%s' "$body" | jq --compact-output --arg m "$chat_model" '. + {model: $m}')"
}

# Setup

local_provider="$(jqr '.ai.localProvider')"

if [[ -z "$local_provider" ]]; then
  printf 'TAP version 14\n1..0 # SKIP local provider disabled\n'
  exit 0
fi

port="$(jqr --arg p "$local_provider" '.ai.providers[$p].port')"
fast="$(jqr '.ai.profiles.local.fast')"
chat_model="$(jqr --arg m "$fast" --arg p "$local_provider" '.ai.models[$m][$p]')"
chat_url="http://localhost:$port"

embed_ref="$(jqr '.ai.profiles[.ai.localProfile].embedding')"
embed_provider="${embed_ref%%/*}"
embed_model="${embed_ref#*/}"
embed_port="$(jqr --arg p "$embed_provider" '.ai.providers[$p].port')"

# Tests

printf 'TAP version 14\n1..4\n'

chat "chat completion returns assistant message" \
  '.choices[0] | has("finish_reason") and .message.role == "assistant"' \
  '"  model: \(.model)\n  finish_reason: \(.choices[0].finish_reason)"' \
  '{"messages": [{"role": "user", "content": "hi"}], "max_tokens": 2}'

chat "reasoning produces correct answer" \
  '.choices[0].message |
    has("reasoning", "content", "role") and
    (.reasoning | length > 0) and
    (.content | test("2"))' \
  '"  model: \(.model)\n  content: \"\(.choices[0].message.content | gsub("\\n";" ") | gsub("\""; "\\\"") | .[0:50])\""' \
  '{"messages": [{"role": "user", "content": "What is 1+1?"}], "max_tokens": 500}'

chat "tool call extracts function arguments" \
  '.choices[0].message |
    has("tool_calls") and
    (.tool_calls | length > 0) and
    .tool_calls[0].function.name == "get_weather" and
    (.tool_calls[0].function.arguments | fromjson | has("city"))' \
  '"  model: \(.model)\n  calls: \(.choices[0].message.tool_calls | length)\n  function: \(.choices[0].message.tool_calls[0].function.name)"' \
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

check "embedding returns vector dimensions" \
  '(.data | length > 0) and (.data[0].embedding | length > 0) and .model' \
  '"  model: \(.model)\n  dimensions: \(.data[0].embedding | length)"' \
  "http://localhost:$embed_port/v1/embeddings" \
  "{\"model\": \"$embed_model\", \"input\": \"test\"}"

# Restart hung services on failure (KeepAlive restarts them)
if [[ "$failures" -gt 0 ]] && command -v launchctl >/dev/null 2>&1; then
  gui="gui/$(id -u)"
  label="$(jqr --arg p "$local_provider" '.ai.providers[$p].label')"
  if [[ -n "$label" ]] && launchctl print "$gui/$label" 2>/dev/null | grep -q 'pid ='; then
    printf '# restarting %s\n' "$label"
    launchctl kill SIGTERM "$gui/$label"
  fi
fi

exit "$failures"
