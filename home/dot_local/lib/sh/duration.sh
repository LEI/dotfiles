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

# format_reset <timestamp> [<now_epoch>]
# Output: "until YYYY-MM-DD HH:MM (human_duration)"
# Set DATE env var (eg "gdate") for BSD compat
format_reset() {
  ts="$1"
  [ -z "$ts" ] && return 1
  now="${2:-$(date +%s)}"
  reset_epoch=$(${DATE:-date} -d "$ts" +%s 2>/dev/null) || return 1
  reset_fmt=$(${DATE:-date} -d "$ts" "+%Y-%m-%d %H:%M" 2>/dev/null) || return 1
  diff=$((reset_epoch - now))
  [ "$diff" -lt 0 ] && diff=0
  echo "until $reset_fmt ($(humanize_secs $diff))"
}
