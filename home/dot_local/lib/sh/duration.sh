# shellcheck shell=sh

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

# format_date <timestamp>
# Output: "<local date/time>" eg "Jul 5, 4:59am"
# Accepts ISO 8601 strings or bare Unix epoch integers
# Set DATE env var (eg "gdate") for BSD compat
format_date() {
  ts="$1"
  [ -z "$ts" ] && return 1
  # Bare epoch integers (9+ digits) need an @ prefix for GNU date
  case "$ts" in
  [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]*) ts="@$ts" ;;
  esac
  date_epoch=$(${DATE:-date} -d "$ts" +%s 2>/dev/null) || return 1
  date_fmt=$(${DATE:-date} -d "@$date_epoch" "+%b %-d, %-I:%M%P" 2>/dev/null) || return 1
  echo "$date_fmt"
}
