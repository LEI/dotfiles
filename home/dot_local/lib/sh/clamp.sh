# shellcheck shell=sh

# Clamp value between min and max
clamp() {
  value="$1"
  min="${2:-1}"
  max="${3:-32}"

  if [ "$value" -lt "$min" ]; then
    printf '%d\n' "$min"
  elif [ "$value" -gt "$max" ]; then
    printf '%d\n' "$max"
  else
    printf '%d\n' "$value"
  fi
}
