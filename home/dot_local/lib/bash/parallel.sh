# shellcheck shell=bash

lib_dir="${BASH_SOURCE[0]%/*}/.."
# shellcheck source=home/dot_local/lib/bash/log.sh
source "$lib_dir/bash/log.sh"
# shellcheck source=home/dot_local/lib/sh/clamp.sh
source "$lib_dir/sh/clamp.sh"

# Get CPU count from system, respecting NPROC override
get_cpu_count() {
  local cpu_count

  if [ -n "${NPROC:-}" ]; then
    cpu_count="$NPROC"
  elif command -v nproc >/dev/null 2>&1; then
    cpu_count=$(nproc 2>/dev/null) || cpu_count=
  elif command -v sysctl >/dev/null 2>&1; then
    cpu_count=$(sysctl -n hw.ncpu 2>/dev/null) || cpu_count=
  elif command -v getconf >/dev/null 2>&1; then
    cpu_count=$(getconf _NPROCESSORS_ONLN 2>/dev/null) || cpu_count=
  fi

  if [[ "$cpu_count" =~ ^[0-9]+$ ]] && [ "$cpu_count" -gt 0 ]; then
    printf '%d\n' "$cpu_count"
  else
    printf '%d\n' 1
  fi
}

# Default job count with 32-job cap for safety
default_jobs() {
  local cpu_count
  cpu_count=$(get_cpu_count)
  clamp "$cpu_count" 1 32
}
