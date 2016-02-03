#!/usr/bin/env bash

# import.sh

IMPORTED=()

import() {
	local path=${1-}
	# local ext=${2-sh}
	local name="${path##*/}"

	[[ -f "$DOT_SCRIPT/lib/$path.sh" ]] || return 1 # Not a file
	[[ ${IMPORTED[*]-} =~ $name ]] && return 0  # Already loaded

	source "$DOT_SCRIPT/lib/$path.sh"
	IMPORTED+=("$path")

	return $?
}
