#!/usr/bin/env bash

# import.sh

IMPORTED=()

import() {
	local path=$1
	# local ext=${2-sh}
	local name="${path##*/}"

	if [[ ! -f "$DOT_SCRIPT/$path.sh" ]]; then
    die "$DOT_SCRIPT/$path.sh No such file" # return 1
  elif [[ ${IMPORTED[*]-} =~ $name ]]; then
    return 0  # Already loaded
  else
    IMPORTED+=("$path")
  	source "$DOT_SCRIPT/$path.sh"
  fi
  # for file in $DOT_SCRIPT/$path*.sh; then ?
	return $?
}
