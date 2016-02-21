#!/usr/bin/env bash

# utils.sh

import "lib/log"

die() {
  local message=${1:-Died}
  printf "%s\r\n" "${BASH_SOURCE[1]}: line ${BASH_LINENO[0]}: ${FUNCNAME[1]}: $message" >&2
  exit 1
}

dry_run() {
  local cmd="$@"

  if [[ "${DRY_RUN-}" != true ]]; then
    # Execute command
    #log_warn "EXECUTING" "$cmd"
    $cmd || die "Failed: $cmd"
  else
    log "$ $cmd" "(dry run)"
    # printf "%s\r\n" "$ $cmd"
  fi
}

is_function() {
  local fn=$1

  if [[ $(type -t $fn) == function ]]; then
    return 0
  else
    return 1
  fi
}

now() {
  local date=""

  [[ ! -z "${TIMESTAMPS-}" ]] && \
    [[ "$TIMESTAMPS" = true ]] && \
    date="[$(date +%H:%M:%S)]"

  printf "%s" "$date"
}

# Usage: echo <string> | to_lower_case
to_lower_case() {
  while read str; do
    printf "%s" "$str" | tr '[:upper:]' '[:lower:]'
  done
}

to_upper_case() {
  while read str; do
    printf "%s" "$str" | tr '[:lower:]' '[:upper:]'
  done
}

# Usage: var_dump <prefix>
# Prints names and values of variables starting with prefix
var_dump() {
  [[ $# -eq 0 ]] && die "Missing argument"
  [[ "${DEBUG-}" != true ]] && return 0

  local prefix=$1
  eval local variables=\${!${prefix}@}
  local var

  for var in $variables; do
    # Print arrays?
    printf "%s\n" "$var = ${!var}"
  done
}
