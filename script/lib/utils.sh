#!/usr/bin/env bash

# utils.sh

import "lib/colors"

# Usage: debug <prefix>
# Prints names and values of variables starting with prefix
debug() {
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

now() {
	local date=""

	[[ ! -z "${TIMESTAMPS-}" ]] && \
		[[ "$TIMESTAMPS" = true ]] && \
		date="[$(date +%H:%M:%S)] "

	printf "%s" "$date"
}

# Usage: <cmd> | to_lower
to_lower() {
  while read str; do
    printf "%s" "$str" | tr '[:upper:]' '[:lower:]'
  done
}
