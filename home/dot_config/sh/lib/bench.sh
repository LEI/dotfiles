# Named component timing for shell init
# Requires wrapping individual source/eval calls
# For per-line profiling, use script/profile instead
# For aggregate startup benchmarks, use script/startup
#
# Usage: SHELL_BENCH=true in local.sh or env, then:
#   bench . "$file"
#   BENCHFMT="mise" bench eval "$(mise activate bash)"

bench() {
  local label prefix start ret end elapsed
  if [ "${SHELL_BENCH:-}" != true ]; then
    "$@"
    return
  fi
  label="${BENCHFMT:-$*}"
  prefix="${SHELL_BENCH_PREFIX:-bench}"
  if [ -n "${SHELL_BENCH_PREFIX:-}" ]; then
    unset SHELL_BENCH_PREFIX
  fi
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
    echo "$prefix: $label: ${elapsed}s" >&2
  fi
  unset BENCHFMT
  return $ret
}

bench_source() {
  local file="$1"
  shift
  if [ ! -f "$file" ]; then
    echo "bench_source: file not found: $file" >&2
    return 1
  fi
  local home name
  home="$(realpath "$HOME")"
  name="${BENCHFMT:-${file#"$home/"}}"
  # local name="${file##*/}"
  # if [ "$name" = init.sh ]; then
  #   name="${file%/init.sh}"
  #   name="${name##*/}"
  # fi
  # shellcheck disable=SC1090
  BENCHFMT="$name" bench source "$file" "$@"
}
