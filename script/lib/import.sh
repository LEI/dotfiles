#!/usr/bin/env bash

# import.sh

IMPORTED=()

import() {
	local path=$1
	# local ext=${2-sh}
	local name="${path##*/}"

	[[ ! -f "$DOT_SCRIPT/$path.sh" ]] && \
    die "$DOT_SCRIPT/$path.sh No such file" # return 1
	[[ ${IMPORTED[*]-} =~ $name ]] && return 0  # Already loaded

  # for file in $DOT_SCRIPT/$path*.sh; then ?

	source "$DOT_SCRIPT/$path.sh"
	IMPORTED+=("$path")

	return $?
}
