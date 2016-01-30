#!/bin/bash
# logger.sh

# . lib/colors.sh

# Usage:
# $1	Message string
# $2	Additional info
# $3	Optional end of line

log() {
	local message=$1
	local path=${2-}
	local crlf=${3-"\r\n"}
	# echo "$@"
	print $blue"›"$end "$message" "$path" "$crlf"
}

info() {
	local message=$1
	local path=${2-}
	local crlf=${3-"\r\n"}
	# ›
	print $blue"i"$end "$message" "$path" "$crlf"
}

ask() {
	local message=$1
	local path=${2-}
	local crlf=${3-"\r\n"}
	# ?
	print $yellow"?"$end "$message" "$path" "$crlf"
}

debug() {
	local message=$1
	local path=${2-}
	local crlf=${3-"\r\n"}

	# * >
	if [[ "$DEBUG" = true ]]; then
		print $cyan">" "$message"$end "$path" "$crlf"
	fi
}

success() {
	local message=$1
	local path=${2-}
	local crlf=${3-"\r\n"}
	# ✓ ✔
	print $green"✔"$end "$message" "$path" "$crlf"
}

error() {
	local message=$1
	local path=${2-}
	local crlf=${3-"\r\n"}
	# × ✕ ✖ ✗ ✘
	print $red"✘"$end "$message" "$path" "$crlf"
}

warn() {
	local message=$1
	local path=${2-}
	local crlf=${3-"\r\n"}
	# ⚠ !
	print $yellow"!"$end "$message" "$path" "$crlf"
}

print() {
	local symbol=$1 # log level
	local message=$2
	local path=$3
	local crlf=$4

	local date=""
	[[ "$TIMESTAMPS" = true ]] && date="[$(date +%H:%M:%S)] "

	# Build indentation
	local i=${indent_level-0}
	local unit=${indent_unit- }
	local indent=""
	while [[ $i -gt 0 ]]; do
		((i-=1))
		indent+="$unit"
	done

	printf "$date%b%b %b %b%b" "$indent" "$symbol" "$message" "$path" "$crlf"

	# printf -v line '%*s' "$level"
	# echo ${line// /-}
}

# carriage_return() {
# 	printf "\r"
# }
#
# line_feed() {
# 	printf "\n"
# }
