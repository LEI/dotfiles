# shellcheck shell=sh

# Resolve a GNU-compatible date command once at source time
# BSD date (macOS) lacks GNU -d, so prefer gdate when it is installed
# Exported for callers that need GNU date directly, eg +%s%3N
if command -v gdate >/dev/null; then
  GNU_DATE='gdate'
else
  GNU_DATE='date'
fi

# humanize_secs <seconds>
# Output: "Xd Yh Zm" | "Xd Yh" | "Xh Zm" | "Xm" | "Xs"
# One-letter units (d/h/m/s) follow GNU timeout, systemd, Kubernetes conventions
# Minutes included when non-zero and duration >= 1 hour
humanize_secs() {
  secs=$1
  if [ "$secs" -ge 86400 ]; then
    d=$((secs / 86400))
    h=$(((secs % 86400) / 3600))
    m=$(((secs % 3600) / 60))
    out="${d}d"
    [ "$h" -gt 0 ] && out="$out ${h}h"
    [ "$m" -gt 0 ] && out="$out ${m}m"
    echo "$out"
  elif [ "$secs" -ge 3600 ]; then
    h=$((secs / 3600))
    m=$(((secs % 3600) / 60))
    out="${h}h"
    [ "$m" -gt 0 ] && out="$out ${m}m"
    echo "$out"
  elif [ "$secs" -ge 60 ]; then
    echo "$((secs / 60))m"
  else
    echo "${secs}s"
  fi
}

# parse_epoch <timestamp>
# Output: Unix epoch seconds
# Accepts ISO 8601 strings or bare Unix epoch integers
# Override the resolved date command with the DATE env var if needed
parse_epoch() {
  ts="$1"
  [ -z "$ts" ] && return 1
  # Bare epoch integers (9+ digits) need an @ prefix for GNU date
  case "$ts" in
  [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]*) ts="@$ts" ;;
  esac
  ${DATE:-$GNU_DATE} -d "$ts" +%s 2>/dev/null
}

# format_date <timestamp>
# Output: "<local date/time>" eg "Jul 5, 4:59am"
format_date() {
  epoch=$(parse_epoch "$1") || return 1
  ${DATE:-$GNU_DATE} -d "@$epoch" "+%b %-d, %-I:%M%P" 2>/dev/null
}

# format_date_relative <timestamp>
# Output: "<local date/time> (<relative duration>)" eg "Jul 5, 4:59am (2h50m)"
# Future timestamps count down; past timestamps get an " ago" suffix
format_date_relative() {
  epoch=$(parse_epoch "$1") || return 1
  abs=$(${DATE:-$GNU_DATE} -d "@$epoch" "+%b %-d, %-I:%M%P" 2>/dev/null) || return 1
  diff=$((epoch - $(date +%s)))
  if [ "$diff" -ge 0 ]; then
    printf '%s (%s)' "$abs" "$(humanize_secs "$diff")"
  else
    printf '%s (%s ago)' "$abs" "$(humanize_secs $((-diff)))"
  fi
}
