OPEN_WEBUI_API="${OPEN_WEBUI_URL:-http://127.0.0.1:8503}/api/v1"

open_webui_auth() {
  OPEN_WEBUI_TOKEN="$(curl -sf "$OPEN_WEBUI_API/auths/signin" \
    -H 'Content-Type: application/json' \
    -d '{"email":"","password":""}' | jq -r '.token')"
  if [ -z "$OPEN_WEBUI_TOKEN" ] || [ "$OPEN_WEBUI_TOKEN" = "null" ]; then
    echo >&2 "warning: open-webui: could not authenticate"
    return 1
  fi
  echo >&2 "open-webui: authenticated"
}

open_webui_post() {
  _url="$OPEN_WEBUI_API/$1"
  echo >&2 "open-webui: POST $_url"
  curl -sf -X POST "$_url" \
    -H "Authorization: Bearer $OPEN_WEBUI_TOKEN" \
    -H "Content-Type: application/json" \
    -d @- >/dev/null
}
