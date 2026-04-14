#!/usr/bin/env bash

set -euo pipefail

data="$(chezmoi data --format=json)"
test_num=0
failures=0

jqr() { printf '%s' "$data" | jq -r "$@"; }

post() {
  curl --silent --fail --max-time 60 "$1" \
    -H 'Content-Type: application/json' \
    -d "$2"
}

check() {
  local label="$1" assert="$2" summary="$3" url="$4" body="$5"
  local response rc=0
  test_num=$((test_num + 1))
  SECONDS=0
  response="$(post "$url" "$body")" || rc=$?
  if [[ $rc -ne 0 ]]; then
    printf 'not ok %d - %s # time=%ds\n' "$test_num" "$label" "$SECONDS"
    printf '  ---\n  message: curl exit %d\n  url: %s\n  ...\n' "$rc" "$url"
    failures=$((failures + 1))
    return 0
  fi
  if ! printf '%s' "$response" | jq -e "$assert" >/dev/null 2>&1; then
    printf 'not ok %d - %s # time=%ds\n' "$test_num" "$label" "$SECONDS"
    printf '  ---\n  message: assertion failed\n'
    printf '%s' "$response" | jq -r 'to_entries[] | "  \(.key): \(.value | tostring | .[0:80])"'
    printf '\n  ...\n'
    failures=$((failures + 1))
    return 0
  fi
  local info
  info="$(printf '%s' "$response" | jq -r "$summary")"
  printf 'ok %d - %s # time=%ds %s\n' "$test_num" "$label" "$SECONDS" "$info"
}

chat() {
  local label="$1" assert="$2" summary="$3" body="$4"
  check "$label" "$assert" "$summary" \
    "$chat_url/v1/chat/completions" \
    "$(printf '%s' "$body" | jq -c --arg m "$chat_model" '. + {model: $m}')"
}

# Setup

local_provider="$(jqr '.ai.localProvider')"
enabled="$(jqr --arg p "$local_provider" '.ai.providers[$p].enabled')"

if [[ "$enabled" != "true" ]]; then
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

chat "completions" \
  '.choices[0] | has("finish_reason") and .message.role == "assistant"' \
  '"model=\(.model) finish_reason=\(.choices[0].finish_reason)"' \
  '{"messages": [{"role": "user", "content": "hi"}], "max_tokens": 2}'

chat "reasoning" \
  '.choices[0].message |
    has("reasoning", "content", "role") and
    (.reasoning | length > 0) and
    (.content | test("2"))' \
  '"model=\(.model) content=\(.choices[0].message.content | gsub("\\n";" ") | .[0:50])"' \
  '{"messages": [{"role": "user", "content": "What is 1+1?"}], "max_tokens": 500}'

chat "tool-calling" \
  '.choices[0].message |
    has("tool_calls") and
    (.tool_calls | length > 0) and
    .tool_calls[0].function.name == "get_weather" and
    (.tool_calls[0].function.arguments | fromjson | has("city"))' \
  '"model=\(.model) calls=\(.choices[0].message.tool_calls | length) fn=\(.choices[0].message.tool_calls[0].function.name)"' \
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
  '"model=\(.model) dimensions=\(.data[0].embedding | length)"' \
  "http://localhost:$embed_port/v1/embeddings" \
  "{\"model\": \"$embed_model\", \"input\": \"test\"}"

exit "$failures"
