#!/usr/bin/env bash

# usage.sh

usage() {
	unset -f usage

	local code=${1-0}
	local message=${2-}

	[[ -n "$message" ]] && printf "%s\r\n" "$message"

	printf "%s\r\n" "
Usage: dot [---]

Commands: ...

	dot [install]
	"

	exit $code
}
