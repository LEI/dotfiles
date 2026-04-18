# Named component timing for shell init
# Requires wrapping individual source/eval calls
# For per-line profiling, use script/profile instead
# For aggregate startup benchmarks, use script/startup
#
# Usage: SHELL_BENCH=true, then:
#   bench label command args...
#   bench mise eval "$(mise activate bash)"
#   bench_source "$file"

bench() {
  local label="$1"
  shift
  if [ "${SHELL_BENCH:-}" != true ]; then
    "$@"
    return
  fi
  # EPOCHREALTIME: bash 5+, zsh needs zsh/datetime
  if [ -n "${ZSH_VERSION:-}" ] && [ -z "${EPOCHREALTIME:-}" ]; then
    zmodload zsh/datetime 2>/dev/null
  fi
  local start="${EPOCHREALTIME:-}"
  "$@"
  local ret=$?
  local end="${EPOCHREALTIME:-}"
  if [ -n "$start" ] && [ -n "$end" ]; then
    local elapsed
    elapsed=$(awk "BEGIN {printf \"%.3f\", $end - $start}")
    echo "bench: $label: ${elapsed}s" >&2
  fi
  return $ret
}

bench_source() {
  local file="$1"
  shift
  if [ ! -f "$file" ]; then
    echo "bench_source: file not found: $file" >&2
    return 1
  fi
  local name
  name="${file#"$(realpath "$HOME")/"}"
  # shellcheck disable=SC1090
  bench "$name" source "$file" "$@"
}
