#!/usr/bin/env bash

# bootstrap.sh

import() {
	local path="${1-}"
	local name="${path##*/}"
	local extension="sh"

	[[ ${IMPORTED[$name]-} = true ]] && return 0 # Do not source twice
	[[ -f "$DOT_BOOTSTRAP/$path.$extension" ]] || return 1 # Must be a file

	source "$DOT_BOOTSTRAP/$path.$extension"
	IMPORTED[$name]=true

	return $?
}
