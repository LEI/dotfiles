#!/usr/bin/env bash

# import.sh

# Load a library file

# declare -A IMPORTED

import() {
	local path=${1-}
	local ext=${2-sh}
	# local name="${path##*/}"

	[[ -f "$DOT_SCRIPT/$path.$ext" ]] || return 1 # Must be a file
	# [[ ${IMPORTED[$name]-} = true ]] && return 0 # Do not source twice

	source "$DOT_SCRIPT/$path.$ext"
	# IMPORTED[$name]=true

	return $?
}
