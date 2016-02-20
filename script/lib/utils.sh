#!/usr/bin/env bash

# utils.sh

import "lib/log"

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

now() {
	local date=""

	[[ ! -z "${TIMESTAMPS-}" ]] && \
		[[ "$TIMESTAMPS" = true ]] && \
		date="[$(date +%H:%M:%S)] "

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
