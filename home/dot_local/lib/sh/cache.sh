# shellcheck shell=sh

# cache_get <path> <max_age_seconds>
# Prints cached content and returns 0 if fresh
# Returns 1 if missing, stale, or unreadable
cache_get() {
  cache_path="$1" max_age="$2"
  [ -f "$cache_path" ] || return 1
  cache_age=$(($(date +%s) - $(stat -c %Y "$cache_path" 2>/dev/null || stat -f %m "$cache_path" 2>/dev/null || echo 0)))
  [ "$cache_age" -lt "$max_age" ] || return 1
  cat "$cache_path"
}

# cache_set <path>
# Reads stdin, writes to path with parent directory creation
cache_set() {
  cache_path="$1"
  mkdir -p "$(dirname "$cache_path")"
  cat >"$cache_path"
}

# cache_age_human <path>
# Prints human-readable age (eg "18m ago") or empty if file missing
# Context (eg "cached", "stale") belongs at the call site
cache_age_human() {
  cache_path="$1"
  [ -f "$cache_path" ] || return 0
  elapsed=$(($(date +%s) - $(stat -c %Y "$cache_path" 2>/dev/null || stat -f %m "$cache_path" 2>/dev/null || echo 0)))
  if [ "$elapsed" -lt 60 ]; then
    printf "%ds ago" "$elapsed"
  elif [ "$elapsed" -lt 3600 ]; then
    printf "%dm ago" "$((elapsed / 60))"
  elif [ "$elapsed" -lt 86400 ]; then
    printf "%dh ago" "$((elapsed / 3600))"
  else
    printf "%dd ago" "$((elapsed / 86400))"
  fi
}

# cache_mark_failed <path>
# Records a fetch failure timestamp next to path, for cache_backoff_active
cache_mark_failed() {
  fail_path="$1.failed"
  mkdir -p "$(dirname "$fail_path")"
  : >"$fail_path"
}

# cache_clear_failed <path>
# Clears a recorded failure, so the next one starts a fresh cooldown
cache_clear_failed() {
  rm -f "$1.failed"
}

# cache_backoff_active <path> <backoff_seconds>
# Returns 0 if a failure was recorded within backoff_seconds (skip network)
cache_backoff_active() {
  fail_path="$1.failed" backoff="$2"
  [ -f "$fail_path" ] || return 1
  fail_age=$(($(date +%s) - $(stat -c %Y "$fail_path" 2>/dev/null || stat -f %m "$fail_path" 2>/dev/null || echo 0)))
  [ "$fail_age" -lt "$backoff" ]
}
