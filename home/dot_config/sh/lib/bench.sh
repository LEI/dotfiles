# Named component timing for shell init
# Requires wrapping individual source/eval calls
# For per-line profiling, use script/profile instead
# For aggregate startup benchmarks, use script/startup
#
# Usage: SHELL_BENCH=true in local.sh or env, then:
#   bench . "$file"
#   BENCHFMT="mise" bench eval "$(mise activate bash)"

bench() {
  if [ "${SHELL_BENCH:-}" != true ]; then
    "$@"
    return
  fi
  local label="${BENCHFMT:-$*}"
  local start end elapsed
  # EPOCHREALTIME: bash 5+, zsh needs zsh/datetime
  if [ -n "${ZSH_VERSION:-}" ] && [ -z "${EPOCHREALTIME:-}" ]; then
    zmodload zsh/datetime 2>/dev/null
  fi
  start="${EPOCHREALTIME:-}"
  "$@"
  local ret=$?
  end="${EPOCHREALTIME:-}"
  if [ -n "$start" ] && [ -n "$end" ]; then
    elapsed=$(awk "BEGIN {printf \"%.3f\", $end - $start}")
    echo "bench: $label: ${elapsed}s" >&2
  fi
  unset BENCHFMT
  return $ret
}
